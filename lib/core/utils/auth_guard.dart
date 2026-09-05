import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../l10n/app_localizations.dart';

/// Runs [action] only when someone is signed in.
///
/// Browsing is open to guests, so the sign-in prompt appears at the moment an
/// account is actually needed — saving, reviewing or booking — rather than
/// blocking the whole app behind a login wall as v1 did.
Future<void> requireAuth(
  BuildContext context, {
  required String reason,
  required Future<void> Function() action,
}) async {
  if (context.read<AuthCubit>().state.isAuthenticated) {
    await action();
    return;
  }

  final l10n = AppLocalizations.of(context);

  final signIn = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.signInRequired),
      content: Text(reason),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.signIn),
        ),
      ],
    ),
  );

  if (signIn ?? false) {
    if (context.mounted) context.push(Routes.signIn);
  }
}
