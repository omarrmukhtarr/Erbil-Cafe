import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../cafes/data/models/cafe.dart';
import '../../data/models/reservation.dart';
import '../../data/repositories/reservation_repository.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late Future<Paginated<Reservation>> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<ReservationRepository>().mine();
  }

  Future<void> _reload() async {
    setState(() => _future = sl<ReservationRepository>().mine());
    await _future;
  }

  Future<void> _cancel(Reservation reservation) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelBookingConfirm),
        content: Text(
          '${reservation.cafeName}\n'
          '${Formatters.date(reservation.date)} · ${reservation.time}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.close),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.cancelBooking),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      try {
        await sl<ReservationRepository>().cancel(reservation.id);
        await _reload();
      } on Failure catch (f) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(f.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myBookings)),
      body: FutureBuilder<Paginated<Reservation>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.page),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, __) =>
                  const AppSkeleton(height: 120, radius: AppRadius.card),
            );
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            return ErrorView(
              failure: error is Failure
                  ? error
                  : const ServerFailure('Could not load your bookings'),
              onRetry: _reload,
            );
          }

          final bookings = snapshot.data!.items;

          if (bookings.isEmpty) {
            return EmptyView(
              icon: Icons.event_seat_outlined,
              title: l10n.noBookings,
              message: l10n.noBookingsBody,
              action: FilledButton(
                onPressed: () => context.go(Routes.explore),
                child: Text(l10n.explore),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.accent,
            onRefresh: _reload,
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.page),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) => _BookingCard(
                reservation: bookings[index],
                onCancel: () => _cancel(bookings[index]),
                onTapCafe: () =>
                    context.push(Routes.cafe(bookings[index].cafeSlug)),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.reservation,
    required this.onCancel,
    required this.onTapCafe,
  });

  final Reservation reservation;
  final VoidCallback onCancel;
  final VoidCallback onTapCafe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final (label, color) = switch (reservation.status) {
      ReservationStatus.pending => (l10n.bookingPending, AppColors.warning),
      ReservationStatus.confirmed => (l10n.bookingConfirmed, AppColors.success),
      ReservationStatus.declined => (l10n.bookingDeclined, AppColors.error),
      ReservationStatus.cancelled => (l10n.bookingCancelled, AppColors.textMuted),
      ReservationStatus.completed => (l10n.bookingCompleted, AppColors.textMuted),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.cardR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onTapCafe,
                  child: Text(reservation.cafeName,
                      style: theme.textTheme.titleMedium),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: AppRadius.pillR,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(Formatters.date(reservation.date),
                  style: theme.textTheme.bodySmall),
              const SizedBox(width: AppSpacing.lg),
              const Icon(Icons.schedule, size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Text(reservation.time, style: theme.textTheme.bodySmall),
              const SizedBox(width: AppSpacing.lg),
              const Icon(Icons.people_outline,
                  size: 14, color: AppColors.accent),
              const SizedBox(width: 6),
              Text('${reservation.partySize}',
                  style: theme.textTheme.bodySmall),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),
          Text(
            '${l10n.bookingReference}: ${reservation.reference}',
            style: theme.textTheme.labelSmall,
          ),

          if (reservation.declineReason != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              reservation.declineReason!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.error),
            ),
          ],

          if (reservation.status.isActive) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: Text(l10n.cancelBooking),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
