import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/app_localizations.dart';

/// A six-digit one-time code.
///
/// One field rather than six boxes: a code pasted from an email, or offered by
/// the keyboard's "from Mail" suggestion, lands whole instead of in the first
/// box only, and deleting works the way it does everywhere else.
class CodeField extends StatelessWidget {
  const CodeField({
    required this.controller,
    this.onCompleted,
    this.length = 6,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;
  final int length;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return TextFormField(
      controller: controller,
      autofocus: true,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ],
      textAlign: TextAlign.center,
      // Digits read left to right in every language the app speaks.
      textDirection: TextDirection.ltr,
      style: theme.textTheme.headlineMedium?.copyWith(letterSpacing: 12),
      decoration: InputDecoration(
        labelText: l10n.verificationCode,
        counterText: '',
      ),
      onChanged: (value) {
        if (value.length == length) onCompleted?.call(value);
      },
      validator: (value) =>
          (value ?? '').length == length ? null : l10n.codeIncomplete,
    );
  }
}
