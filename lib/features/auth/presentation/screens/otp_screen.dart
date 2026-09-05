import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/repositories/auth_repository.dart';

/// Verification-code entry.
///
/// v1 had this screen but it was decorative — nothing was ever sent or checked.
/// Outside production the API echoes the code back so the flow can be completed
/// without an SMS provider; that value is shown here as a hint.
class OtpScreen extends StatefulWidget {
  const OtpScreen({required this.identifier, this.devCode, super.key});

  final String identifier;
  final String? devCode;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _length = 6;

  final _controllers = List.generate(_length, (_) => TextEditingController());
  final _focusNodes = List.generate(_length, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = 60;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();

    // Prefill in development so the flow is walkable without an SMS provider.
    final code = widget.devCode;
    if (code != null && code.length == _length) {
      for (var i = 0; i < _length; i++) {
        _controllers[i].text = code[i];
      }
    }
  }

  void _startCountdown() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        if (mounted) setState(() => _secondsLeft = 0);
      } else if (mounted) {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length < _length) return;

    setState(() => _submitting = true);
    try {
      await sl<AuthRepository>().verifyOtp(widget.identifier, _code);
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Verified')));
      context.pop(true);
    } on Failure catch (f) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _resend() async {
    try {
      final code = await sl<AuthRepository>().requestOtp(widget.identifier);
      if (!mounted) return;
      _startCountdown();
      if (code != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Code: $code')));
      }
    } on Failure catch (f) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(l10n.verifyPhone, style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.otpSentTo(widget.identifier),
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: AppColors.onCreamMuted),
              ),
              const SizedBox(height: AppSpacing.huge),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_length, (index) {
                  return SizedBox(
                    width: 48,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: theme.textTheme.titleLarge,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onChanged: (value) {
                        // Advance on entry, retreat on delete, so the whole
                        // code can be typed without tapping between boxes.
                        if (value.isNotEmpty && index < _length - 1) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_code.length == _length) _verify();
                        setState(() {});
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.xxl),

              ElevatedButton(
                onPressed:
                    _submitting || _code.length < _length ? null : _verify,
                child: Text(l10n.verify),
              ),
              const SizedBox(height: AppSpacing.lg),

              Center(
                child: _secondsLeft > 0
                    ? Text(
                        l10n.resendIn(_secondsLeft),
                        style: theme.textTheme.bodySmall,
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: Text(l10n.resendCode),
                      ),
              ),

              if (widget.devCode != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: AppRadius.chipR,
                  ),
                  child: Text(
                    'Development build — code: ${widget.devCode}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.warning),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
