import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_motion.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../data/unread_notifications.dart';

/// The bell on Home, with the unread count on it.
///
/// Only signed-in users have an inbox, so a guest sees no bell rather than one
/// that leads to a sign-in wall.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final signedIn =
        context.select<AuthCubit, bool>((c) => c.state.isAuthenticated);
    if (!signedIn) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<int>(
      valueListenable: UnreadNotifications.instance,
      builder: (context, count, _) => Semantics(
        button: true,
        label:
            count > 0 ? '${l10n.notifications} ($count)' : l10n.notifications,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () async {
                  await context.push(Routes.notifications);
                  // Whatever was read in there, the badge follows.
                  await UnreadNotifications.instance.refresh();
                },
                child: SizedBox.square(
                  dimension: 46,
                  child: Icon(
                    count > 0
                        ? Icons.notifications_rounded
                        : Icons.notifications_none_rounded,
                    size: 22,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              end: -2,
              top: -2,
              child: AnimatedScale(
                duration: AppMotion.medium,
                curve: AppMotion.spring,
                scale: count > 0 ? 1 : 0,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 20),
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: theme.scaffoldBackgroundColor, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
