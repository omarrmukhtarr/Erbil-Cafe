import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/cafe_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cafes/data/models/cafe.dart';
import '../../data/favorite_sync.dart';
import '../../data/favorites_repository.dart';
import '../toggle_favorite.dart';

/// The Saved tab.
///
/// Unsaving used to await the request and then refetch the whole list, so the
/// page blanked to skeletons and came back one card shorter. The card now
/// folds away the moment the heart is tapped. And because the tab shell keeps
/// this screen alive for the life of the app, it also listens for cafés saved
/// anywhere else — before, a café saved on its own page only showed up here
/// after a manual pull to refresh.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  /// Replaced on every load, for the reason in `MyReviewsScreen`: a pull to
  /// refresh after the last card folded away left the list stuck at zero.
  var _listKey = GlobalKey<AnimatedListState>();
  final _reveal = RevealTracker();

  List<Cafe>? _cafes;
  Failure? _failure;
  late final StreamSubscription<FavoriteChange> _changes;

  @override
  void initState() {
    super.initState();
    _load();
    _changes = FavoriteSync.instance.changes.listen(_onChange);
  }

  @override
  void dispose() {
    _changes.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final page = await sl<FavoritesRepository>().list();
      if (!mounted) return;
      _reveal.reset();
      setState(() {
        _listKey = GlobalKey<AnimatedListState>();
        _cafes = [...page.items];
        _failure = null;
      });
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _failure = failure);
    }
  }

  Future<void> _retry() async {
    setState(() {
      _cafes = null;
      _failure = null;
    });
    await _load();
  }

  void _onChange(FavoriteChange change) {
    final cafes = _cafes;
    if (cafes == null || !mounted) return;

    final index = cafes.indexWhere((c) => c.id == change.cafeId);

    if (!change.isFavorited && index != -1) {
      final removed = cafes.removeAt(index);
      _listKey.currentState?.removeItem(
        index,
        (context, animation) => _RemovedCard(
          animation: animation,
          child: _card(removed.copyWith(isFavorited: false)),
        ),
        duration: AppMotion.medium,
      );
      // The empty state takes over once the last card has gone.
      if (cafes.isEmpty) {
        Future<void>.delayed(AppMotion.medium, () {
          if (mounted) setState(() {});
        });
      }
    } else if (change.isFavorited && index == -1 && change.cafe != null) {
      final wasEmpty = cafes.isEmpty;
      cafes.insert(0, change.cafe!.copyWith(isFavorited: true));
      if (wasEmpty) {
        setState(() {});
      } else {
        _listKey.currentState?.insertItem(0, duration: AppMotion.medium);
      }
    }
  }

  Widget _card(Cafe cafe) => CafeCard(
        cafe: cafe,
        onTap: () => context.push(Routes.cafe(cafe.slug), extra: cafe),
        onFavoriteTap: () => toggleFavorite(context, cafe),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cafes = _cafes;

    final Widget body;
    if (cafes == null && _failure != null) {
      body = ErrorView(
        key: const ValueKey('error'),
        failure: _failure!,
        onRetry: _retry,
      );
    } else if (cafes == null) {
      body = SkeletonGroup(
        key: const ValueKey('loading'),
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.page),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.xl),
          itemBuilder: (_, __) => const CafeCardSkeleton(),
        ),
      );
    } else if (cafes.isEmpty) {
      body = EmptyView(
        key: const ValueKey('empty'),
        icon: Icons.favorite_border,
        title: l10n.noFavorites,
        message: l10n.noFavoritesBody,
        action: FilledButton(
          onPressed: () => context.go(Routes.explore),
          child: Text(l10n.explore),
        ),
      );
    } else {
      body = RefreshIndicator(
        key: const ValueKey('list'),
        color: AppColors.accent,
        onRefresh: _load,
        child: AnimatedList(
          key: _listKey,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.bottomBarClearance,
          ),
          initialItemCount: cafes.length,
          itemBuilder: (context, index, animation) {
            final cafe = cafes[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: SizeTransition(
                sizeFactor: CurvedAnimation(
                  parent: animation,
                  curve: AppMotion.standard,
                ),
                child: FadeSlideIn(
                  index: index,
                  animate: _reveal.shouldAnimate(cafe.id, index),
                  child: _card(cafe),
                ),
              ),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.savedCafes)),
      // A different account has different saved cafés; this tab outlives a
      // sign-out, so it has to notice.
      body: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            previous.user?.id != current.user?.id && current.user != null,
        listener: (context, _) => _retry(),
        child: FadeSwitcher(child: body),
      ),
    );
  }
}

/// A card on its way out: it fades and folds up, and the cards below close
/// the gap.
class _RemovedCard extends StatelessWidget {
  const _RemovedCard({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: AppMotion.standard);

    return FadeTransition(
      opacity: curved,
      child: SizeTransition(
        sizeFactor: curved,
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: IgnorePointer(child: child),
        ),
      ),
    );
  }
}
