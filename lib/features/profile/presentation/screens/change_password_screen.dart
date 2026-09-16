import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

/// Change the password from inside the app.
///
/// The only route before was "forgot password", which meant emailing yourself
/// a code to change a password you still knew.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure = true;
  bool _saving = false;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<AuthCubit>();

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    try {
      await cubit.changePassword(
        currentPassword: _current.text,
        newPassword: _next.text,
      );
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(l10n.passwordChanged)));
      context.pop();
    } on Failure catch (failure) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    InputDecoration field(String label, {bool toggle = false}) =>
        InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: toggle
              ? IconButton(
                  icon:
                      Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePassword)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l10n.passwordChangeExplain,
                      style: theme.textTheme.bodySmall),
                  const Gap.xl(),
                  TextFormField(
                    controller: _current,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.password],
                    decoration: field(l10n.currentPassword, toggle: true),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? l10n.passwordRequired : null,
                  ),
                  const Gap.lg(),
                  TextFormField(
                    controller: _next,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: field(l10n.newPassword),
                    validator: (v) {
                      final problem = Validators.password(v, l10n);
                      if (problem != null) return problem;
                      return v == _current.text
                          ? l10n.newPasswordSameAsOld
                          : null;
                    },
                  ),
                  const Gap.lg(),
                  TextFormField(
                    controller: _confirm,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: field(l10n.confirmPassword),
                    validator: (v) =>
                        Validators.confirmPassword(v, _next.text, l10n),
                  ),
                  const Gap.xxl(),
                  ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.changePassword),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
