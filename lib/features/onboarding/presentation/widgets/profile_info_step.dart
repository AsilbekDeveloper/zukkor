import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/step_header.dart';
import '../../../../i18n/strings.g.dart';

/// Onboarding step 2 — first name, last name, username
/// (Zukkor_Profil_Yaratish.docx: all three required).
class ProfileInfoStep extends StatelessWidget {
  const ProfileInfoStep({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.usernameController,
    this.usernameTaken = false,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController usernameController;

  /// `true` — oxirgi tekshiruvda shu username band chiqqan
  /// (`GET /users/username-available`). Foydalanuvchi matnni
  /// o'zgartirganda tashqarida `false`ga qaytariladi.
  final bool usernameTaken;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepHeader(
          icon: TablerIcons.user,
          title: context.t.onboarding.profileTitle,
          subtitle: context.t.onboarding.profileSubtitle,
        ),
        AppSpacing.xxl.vGap,
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: context.t.onboarding.firstNameLabel,
                hint: context.t.onboarding.firstNameHint,
                controller: firstNameController,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
                validator: Validators.personName,
              ),
              AppSpacing.md.vGap,
              AppTextField(
                label: context.t.onboarding.lastNameLabel,
                hint: context.t.onboarding.lastNameHint,
                controller: lastNameController,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.familyName],
                validator: Validators.personName,
              ),
              AppSpacing.md.vGap,
              AppTextField(
                label: context.t.onboarding.usernameLabel,
                hint: context.t.onboarding.usernameHint,
                controller: usernameController,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newUsername],
                validator: (value) =>
                    Validators.username(value) ??
                    (usernameTaken ? t.authValidation.usernameTaken : null),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
