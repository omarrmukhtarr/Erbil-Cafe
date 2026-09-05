import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/auth_cubit.dart';

/// Sign-in.
///
/// v1's form called `AuthServise.signInAnon()`, a stub that printed to console
/// and then navigated to the success screen regardless of what was typed. This
/// authenticates for real and surfaces the API's error.
class SignInScreen extends StatefulWidget {
  const SignInScreen({this.redirectTo, super.key});

  /// Where to go after signing in, when the user was bounced here by a guard.
  final String? redirectTo;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final success = await context.read<AuthCubit>().login(
          _email.text.trim(),
          _password.text,
        );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      context.go(widget.redirectTo ?? Routes.home);
    } else {
      final failure = context.read<AuthCubit>().state.failure;
      if (failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      }
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                Text(l10n.signIn, style: theme.textTheme.displayLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  l10n.appTagline,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.onCreamMuted),
                ),
                const SizedBox(height: AppSpacing.huge),

                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.mail_outline),
                  ),
                  validator: (value) => Validators.email(value, l10n),
                ),
                const SizedBox(height: AppSpacing.lg),

                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                      ),
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  // Only presence is checked here. Enforcing the strength rules
                  // on sign-in would lock out anyone whose password predates them.
                  validator: (value) => (value == null || value.isEmpty)
                      ? l10n.passwordRequired
                      : null,
                ),

                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () => context.push(Routes.forgotPassword),
                    child: Text(l10n.forgotPassword),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.signIn),
                ),
                const SizedBox(height: AppSpacing.lg),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.noAccount, style: theme.textTheme.bodySmall),
                    TextButton(
                      onPressed: () => context.push(Routes.signUp),
                      child: Text(l10n.signUp),
                    ),
                  ],
                ),

                // Browsing does not require an account, so guests get a way past.
                TextButton(
                  onPressed: () => context.go(Routes.home),
                  child: Text(l10n.continueAsGuest),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
