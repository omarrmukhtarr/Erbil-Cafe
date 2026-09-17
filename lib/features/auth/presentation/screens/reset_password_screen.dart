import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/repositories/auth_repository.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/code_field.dart';

/// The second half of "forgot password": the emailed code and the new password
/// on one screen, then straight into the app.
///
/// The flow this replaced sent the code, verified it under the wrong purpose —
/// so it was always rejected — and never called the reset endpoint at all. No
/// password was ever changed by it.
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({required this.email, this.devCode, super.key});

  final String email;

  /// Returned by the API outside production, where no email is sent.
  final String? devCode;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;

  late String? _devCode = widget.devCode;
  Timer? _timer;
  int _resendIn = 60;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _resendIn = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _resendIn--);
      if (_resendIn <= 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _resend() async {
    try {
      final code = await sl<AuthRepository>()
          .requestOtp(widget.email, purpose: 'PASSWORD_RESET');
      if (!mounted) return;
      setState(() => _devCode = code);
      _startCountdown();
    } on Failure catch (failure) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<AuthCubit>();
    final router = GoRouter.of(context);

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    try {
      await sl<AuthRepository>().resetPassword(
        identifier: widget.email,
        code: _code.text,
        newPassword: _password.text,
      );

      // Signed straight in with the new password: having just proved who they
      // are, making them type it all again would be a formality.
      final signedIn = await cubit.login(widget.email, _password.text);
      messenger.showSnackBar(SnackBar(content: Text(l10n.passwordResetDone)));
      router.go(signedIn ? Routes.home : Routes.signIn);
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Gap.xl(),
                  Text(l10n.resetPasswordTitle,
                      style: theme.textTheme.headlineMedium),
                  const Gap.sm(),
                  Text(l10n.otpSentTo(widget.email),
                      style: theme.textTheme.bodyMedium),
                  if (kDebugMode && _devCode != null) ...[
                    const Gap.sm(),
                    Text(l10n.devCodeHint(_devCode!),
                        style: theme.textTheme.labelSmall),
                  ],
                  const Gap.xxl(),
                  CodeField(
                    controller: _code,
                    onCompleted: (_) => FocusScope.of(context).nextFocus(),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: _resendIn > 0 ? null : _resend,
                      child: Text(
                        _resendIn > 0
                            ? l10n.resendIn(_resendIn)
                            : l10n.resendCode,
                      ),
                    ),
                  ),
                  const Gap.md(),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: l10n.newPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) => Validators.password(v, l10n),
                  ),
                  const Gap.lg(),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: l10n.confirmPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (v) =>
                        Validators.confirmPassword(v, _password.text, l10n),
                  ),
                  const Gap.xxl(),
                  ElevatedButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.changePassword),
                  ),
                  const Gap.xxl(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
