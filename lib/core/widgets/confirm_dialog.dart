import 'package:flutter/material.dart';

import '../../i18n/strings.g.dart';
import '../error/failures.dart';
import '../extensions/context_x.dart';
import '../extensions/num_x.dart';
import '../theme/app_spacing.dart';
import '../utils/validators.dart';
import 'app_text_field.dart';

/// A confirmation dialog for actions that need a second "are you sure" —
/// optionally re-asking for the current password first (e.g. deleting
/// the account). If [onConfirm] throws, the dialog shows an inline error
/// and stays open instead of dismissing and losing what the user typed.
class ConfirmDialog extends StatefulWidget {
  const ConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
    this.isDanger = false,
    this.passwordLabel,
    this.passwordHint,
    super.key,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final bool isDanger;

  /// When set, a password field is shown and its value is passed to
  /// [onConfirm] — used to re-confirm identity before something
  /// irreversible (deleting the account).
  final String? passwordLabel;
  final String? passwordHint;

  /// Runs when Confirm is tapped. Throw a [Failure] (or anything) to
  /// show an inline error and keep the dialog open for another try.
  final Future<void> Function(String? password) onConfirm;

  /// Shows the dialog. Returns true once [onConfirm] completes
  /// successfully, or null if the user cancelled/dismissed it.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function(String? password) onConfirm,
    bool isDanger = false,
    String? passwordLabel,
    String? passwordHint,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        onConfirm: onConfirm,
        isDanger: isDanger,
        passwordLabel: passwordLabel,
        passwordHint: passwordHint,
      ),
    );
  }

  @override
  State<ConfirmDialog> createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  bool get _needsPassword => widget.passwordLabel != null;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_needsPassword && !(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });
    try {
      await widget.onConfirm(_needsPassword ? _passwordController.text : null);
      if (mounted) Navigator.of(context).pop(true);
    } on Failure catch (e) {
      if (mounted) setState(() => _errorText = e.message);
    } catch (_) {
      if (mounted) setState(() => _errorText = t.errors.unknown);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color confirmColor = widget.isDanger ? context.colors.coralDeep : context.colors.coral;

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.message, style: context.textStyles.bodyMedium),
            if (_needsPassword) ...[
              AppSpacing.md.vGap,
              Form(
                key: _formKey,
                child: AppTextField(
                  label: widget.passwordLabel!,
                  hint: widget.passwordHint,
                  controller: _passwordController,
                  obscure: true,
                  errorText: _errorText,
                  enabled: !_isSubmitting,
                  validator: Validators.currentPassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _confirm(),
                ),
              ),
            ] else if (_errorText != null) ...[
              AppSpacing.sm.vGap,
              Text(_errorText!, style: context.textStyles.bodySmall?.copyWith(color: confirmColor)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(context.t.common.cancel),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _confirm,
          child: _isSubmitting
              ? SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: confirmColor),
                )
              : Text(widget.confirmLabel, style: TextStyle(color: confirmColor, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
