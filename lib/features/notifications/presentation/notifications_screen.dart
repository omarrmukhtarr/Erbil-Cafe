import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/di/injector.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_motion.dart';
import '../../../app/theme/app_radius.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/error/failure.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_states.dart';
import '../../../l10n/app_localizations.dart';
import '../data/app_notification.dart';
import '../data/notification_repository.dart';
import '../data/unread_notifications.dart';
import 'notification_target.dart';

/// The notification inbox.
///
/// Every notification the API sends is also stored, so this works whether or
/// not push delivery is set up: a booking confirmed while the phone was off,
/// or on a build with no Firebase project, is still here to read.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repository = sl<NotificationRepository>();
  final _scroll = ScrollController();
  final _reveal = RevealTracker();

  List<AppNotification>? _items;
  Failure? _failure;
  String? _cursor;
  bool _hasMore = false;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _load();
    _scroll.addListener(() {
      final position = _scroll.position;
      if (position.pixels > position.maxScrollExtent - 400) _loadMore();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final page = await _repository.inbox();
      if (!mounted) return;
      _reveal.reset();
      setState(() {
        _items = page.items;
        _cursor = page.nextCursor;
        _hasMore = page.hasMore;
        _failure = null;
      });
      UnreadNotifications.instance.value = page.unreadCount;
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _failure = failure);
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore || _cursor == null) return;
    setState(() => _loadingMore = true);

    try {
      final page = await _repository.inbox(cursor: _cursor);
      if (!mounted) return;
      setState(() {
        _items = [...?_items, ...page.items];
        _cursor = page.nextCursor;
        _hasMore = page.hasMore;
      });
    } on Failure {
      // The page on screen is still good; the next scroll tries again.
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _replace(AppNotification updated) {
    setState(() {
      _items = [
        for (final item in _items ?? const <AppNotification>[])
          item.id == updated.id ? updated : item,
      ];
    });
  }

  Future<void> _open(AppNotification notification) async {
    if (!notification.isRead) {
      // Marked read the moment it is tapped; the request catches up.
      _replace(notification.markedRead());
      final unread = UnreadNotifications.instance;
      if (unread.value > 0) unread.value = unread.value - 1;
      _repository.markRead(notification.id).catchError((_) {});
    }

    final route = routeForNotification(notification.data);
    if (route != null && mounted) await context.push(route);
  }

  Future<void> _markAllRead() async {
    setState(() {
      _items = [
        for (final item in _items ?? const <AppNotification>[])
          item.markedRead()
      ];
    });
    UnreadNotifications.instance.value = 0;

    try {
      await _repository.markAllRead();
    } on Failure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = _items;
    final hasUnread = items?.any((n) => !n.isRead) ?? false;

    final Widget body;
    if (items == null && _failure != null) {
      body = ErrorView(
          key: const ValueKey('error'), failure: _failure!, onRetry: _load);
    } else if (items == null) {
      body = SkeletonGroup(
        key: const ValueKey('loading'),
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.page),
          itemCount: 6,
          separatorBuilder: (_, __) => const Gap.md(),
          itemBuilder: (_, __) =>
              const AppSkeleton(height: 84, radius: AppRadius.card),
        ),
      );
    } else if (items.isEmpty) {
      body = RefreshIndicator(
        key: const ValueKey('empty'),
        color: AppColors.accent,
        onRefresh: _load,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: constraints.maxHeight,
              child: EmptyView(
                icon: Icons.notifications_none_rounded,
                title: l10n.noNotifications,
                message: l10n.noNotificationsBody,
              ),
            ),
          ),
        ),
      );
    } else {
      body = RefreshIndicator(
        key: const ValueKey('list'),
        color: AppColors.accent,
        onRefresh: _load,
        child: ListView.separated(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.huge,
          ),
          itemCount: items.length + (_loadingMore ? 1 : 0),
          separatorBuilder: (_, __) => const Gap.sm(),
          itemBuilder: (context, index) {
            if (index >= items.length) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.accent)),
              );
            }
            final item = items[index];
            return FadeSlideIn(
              index: index,
              animate: _reveal.shouldAnimate(item.id, index),
              child: _NotificationTile(
                  notification: item, onTap: () => _open(item)),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notifications),
        actions: [
          SafeSwitcher(
            duration: AppMotion.fast,
            child: hasUnread
                ? TextButton(
                    key: const ValueKey('mark-all'),
                    onPressed: _markAllRead,
                    child: Text(l10n.markAllRead),
                  )
                : const SizedBox.shrink(),
          ),
          const HGap.sm(),
        ],
      ),
      body: FadeSwitcher(child: body),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  static IconData iconFor(String type) => switch (type) {
        'RESERVATION_CONFIRMED' => Icons.event_available_rounded,
        'RESERVATION_DECLINED' => Icons.event_busy_rounded,
        'RESERVATION_REMINDER' => Icons.alarm_rounded,
        'RESERVATION_REQUESTED' => Icons.event_seat_outlined,
        'REVIEW_REPLY' => Icons.reply_rounded,
        'REVIEW_APPROVED' => Icons.rate_review_outlined,
        'CAMPAIGN' => Icons.campaign_outlined,
        _ => Icons.notifications_none_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final unread = !notification.isRead;

    return Material(
      color: unread
          ? AppColors.accent.withValues(alpha: 0.10)
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: AppRadius.cardR,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconFor(notification.type),
                    size: 20, color: AppColors.accent),
              ),
              const HGap.md(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AnimatedDefaultTextStyle(
                            duration: AppMotion.fast,
                            style: (theme.textTheme.labelLarge ??
                                    const TextStyle())
                                .copyWith(
                              fontWeight:
                                  unread ? FontWeight.w800 : FontWeight.w600,
                            ),
                            child: Text(notification.title),
                          ),
                        ),
                        const HGap.sm(),
                        AnimatedScale(
                          duration: AppMotion.fast,
                          scale: unread ? 1 : 0,
                          child: Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (notification.body.isNotEmpty) ...[
                      const Gap.xs(),
                      Text(
                        notification.body,
                        style: theme.textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Gap.sm(),
                    Text(
                      Formatters.ago(notification.createdAt, l10n),
                      style: theme.textTheme.labelSmall,
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
