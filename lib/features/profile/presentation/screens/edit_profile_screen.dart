import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';

/// Edit the current user's first name, last name and username — reuses
/// the same fields/validators as the onboarding profile-info step.
///
/// CURRENT STATE: presentation only. [ProfileScreen]'s displayed name and
/// username are still hardcoded literals (no profile state/provider
/// exists yet), so "Save" validates the form and confirms locally but
/// can't actually update what Profile shows — that wiring comes once a
/// real profile data layer exists.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController(text: 'Aziz');
  final TextEditingController _lastNameController = TextEditingController(text: 'Karimov');
  final TextEditingController _usernameController = TextEditingController(text: 'aziz_karimov');

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  void _save(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.showSnack(context.t.editProfile.updated);
    _goBack(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.profile.editProfile, onBack: () => _goBack(context)),
              AppSpacing.xl.vGap,
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppTextField(
                      label: context.t.onboarding.firstNameLabel,
                      hint: context.t.onboarding.firstNameHint,
                      controller: _firstNameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.givenName],
                      validator: Validators.personName,
                    ),
                    AppSpacing.md.vGap,
                    AppTextField(
                      label: context.t.onboarding.lastNameLabel,
                      hint: context.t.onboarding.lastNameHint,
                      controller: _lastNameController,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.familyName],
                      validator: Validators.personName,
                    ),
                    AppSpacing.md.vGap,
                    AppTextField(
                      label: context.t.onboarding.usernameLabel,
                      hint: context.t.onboarding.usernameHint,
                      controller: _usernameController,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newUsername],
                      validator: Validators.username,
                    ),
                  ],
                ),
              ),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: context.t.editProfile.save,
                onPressed: () => _save(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
