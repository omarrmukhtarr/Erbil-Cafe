import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

/// Name and phone number.
///
/// The API has always accepted these edits; the app offered no way to make
/// them, so a typo in a name at sign-up was permanent. Email is shown but not
/// editable — it is the sign-in identity, and changing it safely needs a
/// verification step the API does not have yet.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    _name = TextEditingController(text: user?.name ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<AuthCubit>();
    final user = cubit.state.user;

    final name = _name.text.trim();
    final phone = _phone.text.trim().replaceAll(' ', '');

    FocusScope.of(context).unfocus();
    setState(() => _saving = true);

    final ok = await cubit.updateProfile(
      name: name != user?.name ? name : null,
      // Only a changed, non-empty number is sent: the API has no way to
      // remove one, and resending the same number would un-verify it.
      phone: phone.isNotEmpty && phone != user?.phone ? phone : null,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
      context.pop();
    } else {
      final failure = cubit.state.failure;
      if (failure != null) {
        messenger.showSnackBar(SnackBar(content: Text(failure.message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = context.watch<AuthCubit>().state.user;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editProfile)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  decoration: InputDecoration(
                    labelText: l10n.fullName,
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (v) => Validators.name(v, l10n),
                ),
                const Gap.lg(),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  onFieldSubmitted: (_) => _save(),
                  decoration: InputDecoration(
                    labelText: '${l10n.phoneNumber} (${l10n.optional})',
                    hintText: '+9647501234567',
                    helperText: l10n.phoneChangeNote,
                    helperMaxLines: 2,
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  validator: (v) => Validators.phone(v, l10n, required: false),
                ),
                if (user?.email != null) ...[
                  const Gap.lg(),
                  TextFormField(
                    initialValue: user!.email,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      helperText: l10n.emailCannotChange,
                      helperMaxLines: 3,
                      prefixIcon: const Icon(Icons.mail_outline),
                    ),
                  ),
                ],
                const Gap.xxl(),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
