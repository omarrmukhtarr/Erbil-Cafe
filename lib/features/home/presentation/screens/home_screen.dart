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
import '../../../../core/widgets/app_card.dart';
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
/// tree that opened one shared detail page whichever item was tapped.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CafeListCubit _featured;
  late Future<List<PopularItem>> _popular;

  /// Image + text block, matching `_PopularTile`'s own geometry.
  static const _popularTileHeight = 244.0;
  static const _popularImageHeight = 130.0;

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
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.lg,
                  AppSpacing.md,
                  0,
                ),
                sliver: SliverToBoxAdapter(
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Gap.xs(),
                            Text(l10n.appTagline,
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const HGap.sm(),
                      _RoundAction(
                        icon: Icons.search,
                        tooltip: l10n.searchHint,
                        onTap: () => context.go(Routes.explore),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Featured cafés ───────────────────────────────────
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: l10n.featured,
                  actionLabel: l10n.seeAll,
                  onAction: () => context.go(Routes.explore),
                ),
              ),
              SliverToBoxAdapter(
                child: BlocBuilder<CafeListCubit, CafeListState>(
                  bloc: _featured,
                  builder: (context, state) {
                    if (state.status == ListStatus.loading) {
                      return const SizedBox(
                        height: CafeCard.compactHeight,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.page),
                          child: CafeCardSkeleton(compact: true),
                        ),
                      );
                    }

                    if (state.cafes.isEmpty) return const SizedBox.shrink();

                    return SizedBox(
                      height: CafeCard.compactHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.page),
                        itemCount: state.cafes.length,
                        separatorBuilder: (_, __) => const HGap.lg(),
                        itemBuilder: (context, index) {
                          final cafe = state.cafes[index];
                          return SizedBox(
                            width: 272,
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
              SliverToBoxAdapter(child: SectionHeader(title: l10n.popular)),
              SliverToBoxAdapter(
                child: FutureBuilder<List<PopularItem>>(
                  future: _popular,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: _popularTileHeight,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.page),
                          child: AppSkeleton(
                            height: _popularImageHeight,
                            radius: AppRadius.card,
                          ),
                        ),
                      );
                    }

                    final items = snapshot.data ?? const <PopularItem>[];
                    if (items.isEmpty) return const SizedBox.shrink();

                    return SizedBox(
                      height: _popularTileHeight,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.page),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const HGap.md(),
                        itemBuilder: (context, index) => _PopularTile(
                          item: items[index],
                          imageHeight: _popularImageHeight,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Clears the translucent tab bar.
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.bottomBarClearance),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, size: 22, color: theme.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}

/// A popular menu item — v1's coffee tile: dark surface, image on top, the
/// price in copper with the currency label before the amount.
class _PopularTile extends StatelessWidget {
  const _PopularTile({required this.item, required this.imageHeight});

  final PopularItem item;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: 158,
      child: AppCard(
        onTap: () => context.push(Routes.menu(item.cafeSlug)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: imageHeight,
              width: double.infinity,
              child: item.item.thumbUrl == null
                  ? const ColoredBox(
                      color: AppColors.cardDarkAlt,
                      child: Icon(Icons.local_cafe_outlined,
                          color: AppColors.onCardDisabled),
                    )
                  : CachedNetworkImage(
                      imageUrl: item.item.thumbUrl!,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (context, _) =>
                          const ColoredBox(color: AppColors.cardDarkAlt),
                      errorWidget: (context, _, __) =>
                          const ColoredBox(color: AppColors.cardDarkAlt),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.item.name,
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: AppColors.onCard),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap.xxs(),
                  Text(
                    item.cafeName,
                    style: const TextStyle(
                        color: AppColors.onCardMuted, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap.sm(),
                  Text(
                    Formatters.price(item.item.priceIqd, l10n.currencyIqd),
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: AppColors.accent),
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
