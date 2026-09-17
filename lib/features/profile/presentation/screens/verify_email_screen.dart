import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/widgets/code_field.dart';

/// Confirms the account's email with a code sent to it.
///
/// The API has supported this since sign-up was built, and the app never asked,
/// so every account's email sat unverified — including the address password
/// resets are sent to.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();

  bool _sent = false;
  bool _busy = false;
  String? _devCode;
  Timer? _timer;
  int _resendIn = 0;

  String? get _email => context.read<AuthCubit>().state.user?.email;

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _email;
    if (email == null) return;

    setState(() => _busy = true);
    try {
      final code =
          await sl<AuthRepository>().requestOtp(email, purpose: 'EMAIL_VERIFY');
      if (!mounted) return;
      setState(() {
        _sent = true;
        _devCode = code;
        _resendIn = 60;
      });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return timer.cancel();
        setState(() => _resendIn--);
        if (_resendIn <= 0) timer.cancel();
      });
    } on Failure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final email = _email;
    if (email == null || !_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<AuthCubit>();

    setState(() => _busy = true);
    try {
      await sl<AuthRepository>()
          .verifyOtp(email, _code.text, purpose: 'EMAIL_VERIFY');
      await cubit.refreshProfile();
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.emailVerifiedDone)));
      Navigator.of(context).pop();
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _busy = false);
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final email = context.watch<AuthCubit>().state.user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.verifyEmail)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.verifyEmailBody, style: theme.textTheme.bodyMedium),
                const Gap.md(),
                Text(email,
                    style: theme.textTheme.titleMedium,
                    textDirection: TextDirection.ltr),
                const Gap.xxl(),
                AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  alignment: AlignmentDirectional.topStart,
                  child: !_sent
                      ? ElevatedButton(
                          onPressed: _busy ? null : _send,
                          child: Text(l10n.sendCode),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(l10n.otpSentTo(email),
                                style: theme.textTheme.bodySmall),
                            if (kDebugMode && _devCode != null) ...[
                              const Gap.xs(),
                              Text(l10n.devCodeHint(_devCode!),
                                  style: theme.textTheme.labelSmall),
                            ],
                            const Gap.lg(),
                            CodeField(
                                controller: _code,
                                onCompleted: (_) => _verify()),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton(
                                onPressed:
                                    _resendIn > 0 || _busy ? null : _send,
                                child: Text(
                                  _resendIn > 0
                                      ? l10n.resendIn(_resendIn)
                                      : l10n.resendCode,
                                ),
                              ),
                            ),
                            const Gap.md(),
                            ElevatedButton(
                              onPressed: _busy ? null : _verify,
                              child: Text(l10n.verify),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
