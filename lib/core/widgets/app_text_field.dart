import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

/// Yorliq + input birikmasi — prototipdagi forma maydonlari uslubida
/// (yorliq tepada, kichik va qalin; input karta fonida, yumaloq burchak).
///
/// Parol maydoni uchun [obscure] = true — ko'rsatish/yashirish tugmasi
/// avtomatik chiqadi.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onSubmitted,
    this.enabled = true,
    this.maxLength,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final int maxLines;

  /// Serverdan kelgan maydon xatosi (masalan "Bu email band") —
  /// forma validatoridan mustaqil ko'rsatiladi.
  final String? errorText;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  /// Maksimal belgilar soni — o'rnatilsa, kiritish shu chegarada to'xtaydi
  /// (backend qabul qilmaydigan uzunlikni oldini oladi). Standart hisoblagich
  /// ko'rsatilmaydi, forma toza qoladi.
  final int? maxLength;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: context.textStyles.bodySmall?.copyWith(
            color: context.colors.ink2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: widget.controller,
          enabled: widget.enabled,
          obscureText: _obscured,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          onFieldSubmitted: widget.onSubmitted,
          maxLength: widget.maxLength,
          // Standart "12/50" hisoblagichni yashiramiz — kichik so'rovnoma
          // maydonlarida u ortiqcha, chegara jimgina qo'llaniladi.
          buildCounter: widget.maxLength == null
              ? null
              : (_, {required currentLength, required isFocused, maxLength}) => null,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: context.textStyles.bodyMedium?.copyWith(
            color: context.colors.ink,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            suffixIcon: widget.obscure
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    icon: Icon(
                      _obscured
                          ? TablerIcons.eye
                          : TablerIcons.eyeOff,
                      size: 20,
                      color: context.colors.muted,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
