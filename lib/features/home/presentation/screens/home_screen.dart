import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/cafe_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cafes/data/repositories/cafe_repository.dart';
import '../../../cafes/presentation/cubit/cafe_list_cubit.dart';
import '../../../favorites/data/favorites_repository.dart';
import '../../../menu/data/models/menu.dart';
import '../../../menu/data/repositories/menu_repository.dart';

/// The Home tab.
///
/// Replaces v1's `PopularScreen`, whose coffee tiles were a hardcoded widget
/// tree that opened one shared detail page regardless of which item was tapped.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CafeListCubit _featured;
  late Future<List<PopularItem>> _popular;

  @override
  void initState() {
    super.initState();
    _featured = CafeListCubit(sl<CafeRepository>())
      ..load(query: const CafeQuery(featured: true, limit: 6));
    _popular = sl<MenuRepository>().popular();
  }

  @override
  void dispose() {
    _featured.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _popular = sl<MenuRepository>().popular());
    await _featured.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = context.watch<AuthCubit>().state.user;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.lg,
                    AppSpacing.page,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user == null
                                  ? l10n.appName
                                  : 'Hi, ${user.name.split(' ').first}',
                              style: theme.textTheme.displayLarge,
                            ),
                            const SizedBox(height: 2),
                            Text(l10n.appTagline,
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => context.go(Routes.explore),
                        icon: const Icon(Icons.search),
                        tooltip: l10n.searchHint,
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Featured cafés ───────────────────────────────────
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: l10n.featured,
                  onSeeAll: () => context.go(Routes.explore),
                  seeAllLabel: l10n.seeAll,
                ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<CafeListCubit, CafeListState>(
                  bloc: _featured,
                  builder: (context, state) {
                    if (state.status == ListStatus.loading) {
                      return const SizedBox(
                        height: 250,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.page),
                          child: CafeCardSkeleton(),
                        ),
                      );
                    }

                    if (state.cafes.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return SizedBox(
                      height: 272,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.page),
                        itemCount: state.cafes.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.lg),
                        itemBuilder: (context, index) {
                          final cafe = state.cafes[index];
                          return SizedBox(
                            width: 280,
                            child: CafeCard(
                              cafe: cafe,
                              compact: true,
                              onTap: () => context.push(Routes.cafe(cafe.slug)),
                              onFavoriteTap: () => requireAuth(
                                context,
                                reason: l10n.signInToFavorite,
                                action: () async {
                                  final result = await sl<FavoritesRepository>()
                                      .toggle(cafe.id);
                                  _featured.applyFavorite(cafe.id,
                                      isFavorited: result);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // ─── Popular items ────────────────────────────────────
              SliverToBoxAdapter(
                child: _SectionHeader(title: l10n.popular),
              ),
              SliverToBoxAdapter(
                child: FutureBuilder<List<PopularItem>>(
                  future: _popular,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 250,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.page),
                          child: AppSkeleton(height: 190, radius: AppRadius.card),
                        ),
                      );
                    }

                    final items = snapshot.data ?? const <PopularItem>[];
                    if (items.isEmpty) return const SizedBox.shrink();

                    return SizedBox(
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.page),
                        itemCount: items.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: AppSpacing.md),
                        itemBuilder: (context, index) =>
                            _PopularTile(item: items[index]),
                      ),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onSeeAll, this.seeAllLabel});

  final String title;
  final VoidCallback? onSeeAll;
  final String? seeAllLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xxl,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: Text(seeAllLabel ?? '')),
        ],
      ),
    );
  }
}

/// A popular menu item.
///
/// Keeps v1's coffee tile: dark surface, image on top, the price in copper with
/// the IQD label before the amount.
class _PopularTile extends StatelessWidget {
  const _PopularTile({required this.item});

  final PopularItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: 160,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.cardR,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(Routes.menu(item.cafeSlug)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 124,
                width: double.infinity,
                child: item.item.thumbUrl == null
                    ? ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.local_cafe_outlined,
                            color: AppColors.textDisabled),
                      )
                    : CachedNetworkImage(
                        imageUrl: item.item.thumbUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, _) => ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        errorWidget: (context, _, __) => ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.item.name,
                      style: theme.textTheme.labelLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.cafeName,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      Formatters.price(item.item.priceIqd, l10n.currencyIqd),
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
