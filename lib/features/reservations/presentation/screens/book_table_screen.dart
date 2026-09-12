import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cafes/data/repositories/cafe_repository.dart';
import '../../data/models/reservation.dart';
import '../../data/repositories/reservation_repository.dart';
import '../../../notifications/data/push_service.dart';

/// Book a table.
///
/// This is the screen v1 shipped as "Sorry, Service Not Availabe For Now (:".
/// Slots come from the café's real opening hours and remaining capacity.
class BookTableScreen extends StatefulWidget {
  const BookTableScreen({required this.slug, super.key});

  final String slug;

  @override
  State<BookTableScreen> createState() => _BookTableScreenState();
}

class _BookTableScreenState extends State<BookTableScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _note = TextEditingController();

  DateTime _date = DateTime.now().add(const Duration(days: 1));
  int _partySize = 2;
  String? _time;

  Future<Availability>? _availability;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    // Prefill from the signed-in profile so the common case is one tap.
    final user = sl<AuthCubit>().state.user;
    _name.text = user?.name ?? '';
    _phone.text = user?.phone ?? '';

    _loadAvailability();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  void _loadAvailability() {
    setState(() {
      _time = null;
      _availability = sl<ReservationRepository>().availability(
        widget.slug,
        date: _date,
        partySize: _partySize,
      );
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: now,
      // The API accepts bookings up to 90 days ahead.
      lastDate: now.add(const Duration(days: 90)),
    );

    if (picked != null) {
      _date = picked;
      _loadAvailability();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _time == null) return;

    setState(() => _submitting = true);

    try {
      final cafe = await sl<CafeRepository>().detail(widget.slug);

      final reservation = await sl<ReservationRepository>().create(
        cafe.cafe.id,
        date: _date,
        time: _time!,
        partySize: _partySize,
        contactName: _name.text.trim(),
        contactPhone: _phone.text.trim(),
        note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      );

      if (!mounted) return;

      // The one moment where asking to send notifications explains itself:
      // the café has to answer this booking, and the notification is how the
      // answer arrives. iOS shows this dialog once per install, so spending it
      // at cold start — on nothing in particular — wastes it for good.
      unawaited(sl<PushService>().requestPermission().then((granted) {
        if (granted) sl<PushService>().registerDevice();
      }));

      await _showConfirmation(reservation);
    } on Failure catch (f) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message)));
      // Capacity may have changed since the preview, so refresh the slots.
      _loadAvailability();
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showConfirmation(Reservation reservation) async {
    final l10n = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline,
            color: AppColors.success, size: 40),
        title: Text(l10n.bookingPending),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${reservation.cafeName}\n'
              '${Formatters.date(reservation.date)} · ${reservation.time}\n'
              '${reservation.partySize} ${l10n.partySize.toLowerCase()}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.12),
                borderRadius: AppRadius.chipR,
              ),
              child: Text(
                '${l10n.bookingReference}: ${reservation.reference}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: Text(l10n.done),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookTable)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.page),
          children: [
            // ─── Date ─────────────────────────────────────────────
            Text(l10n.selectDate, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            InkWell(
              onTap: _pickDate,
              borderRadius: AppRadius.inputR,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.inputR,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        size: 18, color: AppColors.accent),
                    const SizedBox(width: AppSpacing.md),
                    Text(Formatters.date(_date),
                        style: theme.textTheme.bodyLarge),
                    const Spacer(),
                    const Icon(Icons.chevron_right,
                        color: AppColors.onCreamMuted),
                  ],
                ),
              ),
            ),

            // ─── Party size ───────────────────────────────────────
            const SizedBox(height: AppSpacing.xxl),
            Text(l10n.partySize, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            // Wrap, not Row: eight options overflow a phone's width, and a
            // horizontal scroller would hide the larger party sizes.
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final size in [1, 2, 3, 4, 5, 6, 8, 10])
                  _Pill(
                    label: '$size',
                    selected: _partySize == size,
                    onTap: () {
                      _partySize = size;
                      // Availability depends on party size, so refetch.
                      _loadAvailability();
                    },
                  ),
              ],
            ),

            // ─── Time ─────────────────────────────────────────────
            const SizedBox(height: AppSpacing.xxl),
            Text(l10n.selectTime, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            FutureBuilder<Availability>(
              future: _availability,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  final error = snapshot.error;
                  return Text(
                    error is Failure ? error.message : l10n.errorGeneric,
                    style: const TextStyle(color: AppColors.error),
                  );
                }

                final availability = snapshot.data!;

                if (availability.isClosed) {
                  return _Notice(text: l10n.closedOnDay, color: AppColors.warning);
                }

                if (!availability.hasAnyAvailable) {
                  return _Notice(text: l10n.fullyBooked, color: AppColors.error);
                }

                return Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final slot in availability.slots)
                      _Pill(
                        label: slot.time,
                        selected: _time == slot.time,
                        // A full slot stays visible but unselectable, so the
                        // café's hours are still legible.
                        enabled: slot.available,
                        onTap: () => setState(() => _time = slot.time),
                      ),
                  ],
                );
              },
            ),

            // ─── Contact ──────────────────────────────────────────
            const SizedBox(height: AppSpacing.xxl),
            TextFormField(
              controller: _name,
              decoration: InputDecoration(labelText: l10n.contactName),
              validator: (v) => Validators.name(v, l10n),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: l10n.contactPhone,
                hintText: '+9647501234567',
              ),
              validator: (v) => Validators.phone(v, l10n),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _note,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: l10n.specialRequest,
                hintText: l10n.specialRequestHint,
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: _submitting || _time == null ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.confirmBooking),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: selected
            ? AppColors.accent
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.pillR,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.onCreamMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.inputR,
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }
}
