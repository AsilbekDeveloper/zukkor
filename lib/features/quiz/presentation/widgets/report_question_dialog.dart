import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../i18n/strings.g.dart';

class ReportQuestionDialog extends StatefulWidget {
  const ReportQuestionDialog({required this.onSubmit, super.key});

  final Future<void> Function(String reason, String? comment) onSubmit;

  static Future<bool?> show(
    BuildContext context, {
    required Future<void> Function(String reason, String? comment) onSubmit,
  }) {
    return showDialog<bool>(context: context, builder: (_) => ReportQuestionDialog(onSubmit: onSubmit));
  }

  @override
  State<ReportQuestionDialog> createState() => _ReportQuestionDialogState();
}

class _ReportQuestionDialogState extends State<ReportQuestionDialog> {
  final TextEditingController _commentController = TextEditingController();
  String? _selectedReason;
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) return;

    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    try {
      await widget.onSubmit(_selectedReason!, _commentController.text.trim().isEmpty ? null : _commentController.text.trim());
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
    final t = context.t;
    final reasons = [
      (value: 'wrong_answer', label: t.report.reasonWrongAnswer),
      (value: 'unclear', label: t.report.reasonUnclear),
      (value: 'offensive', label: t.report.reasonOffensive),
      (value: 'other', label: t.report.reasonOther),
    ];

    return AlertDialog(
      title: Text(t.report.dialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RadioGroup<String>(
              groupValue: _selectedReason,
              onChanged: (val) {
                if (!_isSubmitting) setState(() => _selectedReason = val);
              },
              child: Column(
                children: reasons
                    .map((r) => RadioListTile<String>(
                          title: Text(r.label, style: context.textStyles.bodyMedium),
                          value: r.value,
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          activeColor: context.colors.coral,
                        ))
                    .toList(),
              ),
            ),
            AppSpacing.md.vGap,
            AppTextField(
              label: t.report.commentLabel,
              hint: t.report.commentHint,
              controller: _commentController,
              maxLines: 3,
              maxLength: 500,
              enabled: !_isSubmitting,
            ),
            if (_errorText != null) ...[
              AppSpacing.sm.vGap,
              Text(_errorText!, style: context.textStyles.bodySmall?.copyWith(color: context.colors.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(t.common.cancel),
        ),
        TextButton(
          onPressed: _isSubmitting || _selectedReason == null ? null : _submit,
          child: _isSubmitting
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  t.report.submit,
                  style: TextStyle(
                    color: _selectedReason == null ? context.colors.muted : context.colors.coral,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ],
    );
  }
}
