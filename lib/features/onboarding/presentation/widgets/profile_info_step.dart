import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import 'step_header.dart';

/// Onboarding step 2 — first name, last name, username
/// (Zukkor_Profil_Yaratish.docx: all three required).
class ProfileInfoStep extends StatelessWidget {
  const ProfileInfoStep({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.usernameController,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController usernameController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepHeader(
          icon: TablerIcons.user,
          title: AppStrings.profileStepTitle,
          subtitle: AppStrings.profileStepSubtitle,
        ),
        AppSpacing.xxl.vGap,
        Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: AppStrings.firstNameLabel,
                hint: AppStrings.firstNameHint,
                controller: firstNameController,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
                validator: Validators.personName,
              ),
              AppSpacing.md.vGap,
              AppTextField(
                label: AppStrings.lastNameLabel,
                hint: AppStrings.lastNameHint,
                controller: lastNameController,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.familyName],
                validator: Validators.personName,
              ),
              AppSpacing.md.vGap,
              AppTextField(
                label: AppStrings.usernameLabel,
                hint: AppStrings.usernameHint,
                controller: usernameController,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.newUsername],
                validator: Validators.username,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
