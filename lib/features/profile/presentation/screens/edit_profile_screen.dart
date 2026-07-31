import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/models/avatar_color_option.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/avatar_color_picker.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/current_user_controller.dart';
import '../../../onboarding/presentation/models/onboarding_direction.dart';

/// Edit the current user's first name, last name, username and avatar
/// color — pre-filled from and saved to the real backend (the same
/// `PATCH /users/me/profile` endpoint Onboarding uses).
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  AvatarColorOption _avatarColor = AvatarColorOption.fallback;
  String? _avatarImagePath;
  String? _originalUsername;
  bool _usernameTaken = false;
  bool _checkingUsername = false;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_clearUsernameTakenError);

    final User? user = ref.read(currentUserControllerProvider).data;
    if (user != null) {
      _prefill(user);
    } else {
      // Chuqur havola orqali to'g'ridan-to'g'ri ochilgan holat uchun
      // ehtiyot chorasi — odatda Profile ekrani buni oldindan yuklab qo'yadi.
      Future.microtask(() async {
        await ref.read(currentUserControllerProvider.notifier).load();
        final User? loaded = ref.read(currentUserControllerProvider).data;
        if (mounted && loaded != null) setState(() => _prefill(loaded));
      });
    }
  }

  void _prefill(User user) {
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _usernameController.text = user.username ?? '';
    _originalUsername = user.username;
    _avatarColor = AvatarColorOption.fromApiValue(user.avatarColor);
    _avatarImagePath = user.avatarImagePath;
  }

  /// Galereyadan rasm tanlab, darhol backend'ga yuklaydi (Saqlash
  /// tugmasini kutmasdan) — backend `avatar_color`ni tozalaydi, ular
  /// bir-birini istisno qiladi. Yuklashdan oldin rasm 1024×1024'gacha
  /// kichraytiriladi — telefon kamerasining asl hajmi (ko'pincha bir
  /// necha MB) sekin yuklanishning asosiy sababi edi.
  Future<void> _pickAndUploadPhoto() async {
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;

      setState(() => _uploadingPhoto = true);
      final User updated =
          await ref.read(authControllerProvider.notifier).uploadAvatarImage(picked.path);
      ref.read(currentUserControllerProvider.notifier).setUser(updated);
      if (!mounted) return;
      setState(() {
        _avatarImagePath = updated.avatarImagePath;
        _avatarColor = AvatarColorOption.fromApiValue(updated.avatarColor);
      });
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown); 
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _clearUsernameTakenError() {
    if (_usernameTaken) {
      setState(() => _usernameTaken = false);
    }
  }

  @override
  void dispose() {
    _usernameController.removeListener(_clearUsernameTakenError);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  /// `null` — so'rov xatolik bilan tugadi (snackbar ko'rsatildi).
  Future<bool?> _checkUsernameAvailable(String username) async {
    setState(() => _checkingUsername = true);
    try {
      return await ref.read(checkUsernameAvailableUseCaseProvider).call(username);
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
      return null;
    } finally {
      if (mounted) setState(() => _checkingUsername = false);
    }
  }

  Future<void> _save() async {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final String newUsername = _usernameController.text.trim();
    if (newUsername != _originalUsername) {
      final bool? available = await _checkUsernameAvailable(newUsername);
      if (available == null) return; // xatolik — allaqachon ko'rsatildi
      if (!available) {
        setState(() => _usernameTaken = true);
        _formKey.currentState?.validate();
        return;
      }
    }

    final User? current = ref.read(currentUserControllerProvider).data;
    try {
      final User updated = await ref.read(authControllerProvider.notifier).updateProfile(
            username: newUsername,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            // Faqat foydalanuvchining joriy tanlovi rang bo'lsagina
            // yuboriladi — agar u hozir yuklangan rasmni ishlatayotgan
            // bo'lsa (_avatarImagePath != null), bu maydonni yuborish
            // backend'da o'sha rasmni o'chirib, rangga qaytarib qo'yar edi
            // (ular bir-birini istisno qiladi).
            avatarColor: _avatarImagePath == null ? _avatarColor.apiValue : null,
            // Bu ekranda yo'nalish o'zgartirilmaydi — joriy qiymat
            // o'zgarishsiz qayta yuboriladi (backend uni ham talab qiladi).
            direction: current?.direction ?? OnboardingDirection.casual.apiValue,
          );
      ref.read(currentUserControllerProvider.notifier).setUser(updated);
      if (!mounted) return;
      context.showSnack(context.t.editProfile.updated);
      _goBack();
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading = _checkingUsername || ref.watch(authControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.profile.editProfile, onBack: _goBack),
              AppSpacing.xl.vGap,
              AvatarColorPicker(
                selectedColor: _avatarColor,
                avatarImagePath: _avatarImagePath,
                isUploading: _uploadingPhoto,
                // Rang tanlash rasmni bekor qiladi — ikkalasi bir-birini
                // istisno qiladi (Saqlash bosilganda backend ham shunday
                // tozalaydi).
                onColorSelected: (color) => setState(() {
                  _avatarColor = color;
                  _avatarImagePath = null;
                }),
                onUploadPhoto: _pickAndUploadPhoto,
              ),
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
                      validator: (value) =>
                          Validators.username(value) ??
                          (_usernameTaken ? t.authValidation.usernameTaken : null),
                    ),
                  ],
                ),
              ),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: context.t.editProfile.save,
                isLoading: isLoading,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
