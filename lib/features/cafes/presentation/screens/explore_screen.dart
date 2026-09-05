import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/cafe_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../favorites/data/favorites_repository.dart';
import '../../data/models/cafe.dart';
import '../../data/repositories/cafe_repository.dart';
import '../cubit/cafe_list_cubit.dart';

/// Browse and search.
///
/// v1's shop screen had a decorative search field and four hardcoded entries.
/// This searches the API across Kurdish, Arabic and English and filters by
/// area, price and open-now.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final CafeListCubit _cubit;
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cubit = CafeListCubit(sl<CafeRepository>())
      ..load()
      ..loadAreas();

    _scrollController.addListener(() {
      // Prefetch before the bottom so scrolling stays smooth.
      final position = _scrollController.position;
      if (position.pixels >= position.maxScrollExtent - 500) {
        _cubit.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _cubit.close();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<CafeListCubit, CafeListState>(
          bloc: _cubit,
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.lg,
                    AppSpacing.page,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.explore, style: theme.textTheme.displayLarge),
                      const Gap.md(),
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          _cubit.search(value);
                          setState(() {}); // toggles the clear button
                        },
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: l10n.searchHint,
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close, size: 18),
                                  tooltip: l10n.clearFilters,
                                  onPressed: () {
                                    _searchController.clear();
                                    _cubit.search('');
                                    setState(() {});
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),

                _FilterBar(cubit: _cubit, state: state),
                const Gap.md(),

                Expanded(
                  child: switch (state.status) {
                    ListStatus.loading => ListView.separated(
                        padding: _listPadding,
                        itemCount: 4,
                        separatorBuilder: (_, __) => const Gap.xxl(),
                        itemBuilder: (_, __) => const CafeCardSkeleton(),
                      ),
                    ListStatus.failure when state.cafes.isEmpty => ErrorView(
                        failure: state.failure!,
                        onRetry: () => _cubit.load(),
                      ),
                    _ when state.isEmpty => EmptyView(
                        icon: Icons.search_off,
                        title: l10n.noResults,
                        message: l10n.noResultsBody,
                        action: state.query.hasFilters
                            ? OutlinedButton(
                                onPressed: () {
                                  _searchController.clear();
                                  _cubit.clearFilters();
                                  setState(() {});
                                },
                                child: Text(l10n.clearFilters),
                              )
                            : null,
                      ),
                    _ => RefreshIndicator(
                        color: AppColors.accent,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        onRefresh: () => _cubit.load(),
                        child: ListView.separated(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: _listPadding,
                          itemCount: state.cafes.length +
                              (state.status == ListStatus.loadingMore ? 1 : 0),
                          separatorBuilder: (_, __) => const Gap.xxl(),
                          itemBuilder: (context, index) {
                            if (index >= state.cafes.length) {
                              return const Padding(
                                padding: EdgeInsets.all(AppSpacing.xl),
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: AppColors.accent),
                                ),
                              );
                            }

                            final cafe = state.cafes[index];
                            return CafeCard(
                              cafe: cafe,
                              onTap: () => context.push(Routes.cafe(cafe.slug)),
                              onFavoriteTap: () => requireAuth(
                                context,
                                reason: l10n.signInToFavorite,
                                action: () async {
                                  final result = await sl<FavoritesRepository>()
                                      .toggle(cafe.id);
                                  _cubit.applyFavorite(cafe.id,
                                      isFavorited: result);
                                },
                              ),
                            );
                          },
                        ),
                      ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static const _listPadding = EdgeInsets.fromLTRB(
    AppSpacing.page,
    0,
    AppSpacing.page,
    AppSpacing.bottomBarClearance,
  );
}

/// Filter chips in one scrollable row above the results.
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.cubit, required this.state});

  final CafeListCubit cubit;
  final CafeListState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final query = state.query;

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        children: [
          _Chip(
            label: l10n.openNow,
            selected: query.openNow == true,
            onTap: () => cubit.setOpenNow(query.openNow == true ? null : true),
          ),
          const HGap.sm(),
          for (final price in PriceRange.values) ...[
            _Chip(
              label: price.symbol,
              selected: query.priceRange == price,
              onTap: () => cubit.setPriceRange(
                query.priceRange == price ? null : price,
              ),
            ),
            const HGap.sm(),
          ],
          _Chip(
            label: l10n.allAreas,
            selected: query.area == null,
            onTap: () => cubit.setArea(null),
          ),
          for (final area in state.areas) ...[
            const HGap.sm(),
            _Chip(
              label: '${area.area} · ${area.count}',
              selected: query.area == area.area,
              onTap: () => cubit.setArea(area.area),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected
              ? AppColors.accent
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.pillR,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
