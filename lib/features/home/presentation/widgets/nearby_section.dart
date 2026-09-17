import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/cafe_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cafes/data/repositories/cafe_repository.dart';
import '../../../cafes/presentation/cubit/cafe_list_cubit.dart';
import '../../../favorites/presentation/toggle_favorite.dart';

/// "Near you": the closest cafés, or an invitation to share a location.
///
/// Nothing is asked at launch. If location is already allowed the section
/// fills in by itself; otherwise it is a card that says what location is for,
/// and the system dialog appears only when that card's button is pressed. A
/// permanent refusal turns the button into a way to Settings instead of a
/// button that silently does nothing.
class NearbySection extends StatefulWidget {
  const NearbySection({super.key});

  /// Nearest first, within walking-and-a-short-drive distance.
  static const radiusKm = 5.0;

  @override
  State<NearbySection> createState() => NearbySectionState();
}

class NearbySectionState extends State<NearbySection> {
  late final CafeListCubit _cubit = CafeListCubit(sl<CafeRepository>());
  final _reveal = RevealTracker();

  LocationAccess? _access;
  bool _locating = false;

  /// Whether the person has pressed the button at least once. A location
  /// that could not be found is only worth mentioning if they asked for it.
  bool _asked = false;

  LocationService get _location => LocationService.instance;

  @override
  void initState() {
    super.initState();
    _checkQuietly();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  /// Loads nearby cafés only if location is already allowed — no prompt.
  Future<void> _checkQuietly() async {
    final access = await _location.access();
    if (!mounted) return;
    setState(() => _access = access);
    if (access == LocationAccess.granted) await _locate(prompt: false);
  }

  Future<void> _locate({required bool prompt}) async {
    setState(() {
      _locating = true;
      _asked = _asked || prompt;
    });
    final (access, where) = await _location.locate(prompt: prompt);
    if (!mounted) return;
    setState(() {
      _access = access;
      _locating = false;
    });

    if (where != null) {
      await _cubit.load(
        query: CafeQuery(
          lat: where.lat,
          lng: where.lng,
          radiusKm: NearbySection.radiusKm,
          sort: 'distance',
          limit: 10,
        ),
      );
    }
  }

  /// Pull-to-refresh on Home re-reads the location as well as the list.
  Future<void> refresh() async {
    if (_access == LocationAccess.granted) await _locate(prompt: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final access = _access;

    // Still reading the permission, or a platform with no location at all
    // (a widget test, a web build) that nobody has asked about yet.
    if (access == null ||
        (access == LocationAccess.unavailable && !_asked && !_locating)) {
      return const SizedBox.shrink();
    }

    final Widget body;
    if (access != LocationAccess.granted ||
        _locating && _cubit.state.cafes.isEmpty) {
      body = _Prompt(
        key: ValueKey('prompt-$access-$_locating'),
        access: access,
        locating: _locating,
        onAllow: () => _locate(prompt: true),
        onSettings: () => _location.openSettingsFor(access),
      );
    } else {
      body = BlocBuilder<CafeListCubit, CafeListState>(
        key: const ValueKey('list'),
        bloc: _cubit,
        builder: (context, state) {
          if (state.isFirstLoad || state.status == ListStatus.initial) {
            return SizedBox(
              height: CafeCard.compactHeight,
              child: SkeletonGroup(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  itemCount: 2,
                  separatorBuilder: (_, __) => const HGap.lg(),
                  itemBuilder: (_, __) => const SizedBox(
                    width: 272,
                    child: CafeCardSkeleton(compact: true),
                  ),
                ),
              ),
            );
          }

          if (state.cafes.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Text(
                l10n.noCafesNearby(NearbySection.radiusKm.round()),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            );
          }

          return SizedBox(
            height: CafeCard.compactHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              itemCount: state.cafes.length,
              separatorBuilder: (_, __) => const HGap.lg(),
              itemBuilder: (context, index) {
                final cafe = state.cafes[index];
                return FadeSlideIn(
                  index: index,
                  animate: _reveal.shouldAnimate(cafe.id, index),
                  child: SizedBox(
                    width: 272,
                    child: CafeCard(
                      cafe: cafe,
                      compact: true,
                      onTap: () =>
                          context.push(Routes.cafe(cafe.slug), extra: cafe),
                      onFavoriteTap: () => toggleFavorite(context, cafe),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.nearYou,
          subtitle: l10n.nearYouSubtitle,
          actionLabel: access == LocationAccess.granted ? l10n.seeAll : null,
          onAction: access == LocationAccess.granted
              ? () => context.go(Routes.exploreWith(nearMe: true))
              : null,
        ),
        FadeSwitcher(child: body),
      ],
    );
  }
}

/// The card that asks — or, once refused for good, points to Settings.
class _Prompt extends StatelessWidget {
  const _Prompt({
    required this.access,
    required this.locating,
    required this.onAllow,
    required this.onSettings,
    super.key,
  });

  final LocationAccess access;
  final bool locating;
  final VoidCallback onAllow;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final blocked = access == LocationAccess.deniedForever ||
        access == LocationAccess.serviceOff;

    final body = switch (access) {
      LocationAccess.deniedForever => l10n.locationDeniedBody,
      LocationAccess.serviceOff => l10n.locationServiceOffBody,
      LocationAccess.unavailable => l10n.locationUnavailable,
      _ => l10n.locationPromptBody,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.near_me_rounded, color: AppColors.accent),
            ),
            const HGap.lg(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.locationPromptTitle,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: AppColors.onCard),
                  ),
                  const Gap.xs(),
                  Text(
                    body,
                    style: const TextStyle(
                        color: AppColors.onCardMuted,
                        fontSize: 13,
                        height: 1.45),
                  ),
                  const Gap.md(),
                  SafeSwitcher(
                    duration: AppMotion.fast,
                    child: locating
                        ? Row(
                            key: const ValueKey('locating'),
                            children: [
                              const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: AppColors.accent),
                              ),
                              const HGap.sm(),
                              Flexible(
                                child: Text(
                                  l10n.locating,
                                  style: const TextStyle(
                                      color: AppColors.onCardMuted,
                                      fontSize: 13),
                                ),
                              ),
                            ],
                          )
                        : FilledButton.icon(
                            key: ValueKey(blocked),
                            onPressed: blocked ? onSettings : onAllow,
                            icon: Icon(
                              blocked
                                  ? Icons.settings_outlined
                                  : Icons.my_location_rounded,
                              size: 18,
                            ),
                            label: Text(blocked
                                ? l10n.openSettings
                                : l10n.useMyLocation),
                          ),
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
