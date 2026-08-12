import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/pill_segment_control.dart';
import '../../../../i18n/strings.g.dart';
import '../controllers/ai_quiz_controller.dart';

/// Hujjat (PDF/Word/matn) yuklab, undan AI orqali quiz generatsiya
/// qilish. Muvaffaqiyatli bo'lsa natija darhol backend'da saqlanadi
/// (alohida "saqlash" qadami yo'q) va foydalanuvchi "Mening AI
/// quizlarim" ro'yxatiga qaytariladi.
class GenerateAiQuizScreen extends ConsumerStatefulWidget {
  const GenerateAiQuizScreen({super.key});

  @override
  ConsumerState<GenerateAiQuizScreen> createState() => _GenerateAiQuizScreenState();
}

class _GenerateAiQuizScreenState extends ConsumerState<GenerateAiQuizScreen> {
  static const List<int> _questionCountOptions = [5, 10, 15, 20];

  final TextEditingController _instructionController = TextEditingController();
  PlatformFile? _pickedFile;
  int _questionCount = 10;

  @override
  void dispose() {
    _instructionController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx', 'txt'],
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _pickedFile = result.files.single);
  }

  Future<void> _generate() async {
    final PlatformFile? file = _pickedFile;
    final String? path = file?.path;
    if (file == null || path == null) {
      context.showSnack(context.t.aiQuiz.pickFileFirst);
      return;
    }
    if (_instructionController.text.trim().isEmpty) {
      context.showSnack(context.t.aiQuiz.instructionRequired);
      return;
    }

    context.hideKeyboard();
    try {
      await ref.read(aiQuizControllerProvider.notifier).generate(
            filePath: path,
            fileName: file.name,
            instruction: _instructionController.text.trim(),
            questionCount: _questionCount,
          );
      if (!mounted) return;
      context.showSnack(context.t.aiQuiz.generated);
      context.pop();
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isGenerating = ref.watch(aiQuizControllerProvider).isGenerating;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.aiQuiz.generateTitle, onBack: _goBack),
              AppSpacing.xl.vGap,
              Text(
                context.t.aiQuiz.generateSubtitle,
                style: context.textStyles.bodyMedium?.copyWith(color: context.colors.muted),
              ),
              AppSpacing.xl.vGap,
              _FilePickerCard(file: _pickedFile, onTap: isGenerating ? null : _pickFile),
              AppSpacing.lg.vGap,
              AppTextField(
                label: context.t.aiQuiz.instructionLabel,
                hint: context.t.aiQuiz.instructionHint,
                controller: _instructionController,
              ),
              AppSpacing.lg.vGap,
              Text(context.t.aiQuiz.questionCountLabel, style: context.textStyles.labelSmall),
              AppSpacing.sm.vGap,
              PillSegmentControl<int>(
                values: _questionCountOptions,
                selected: _questionCount,
                labelBuilder: (value) => '$value',
                onChanged: isGenerating ? (_) {} : (value) => setState(() => _questionCount = value),
              ),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: context.t.aiQuiz.generateButton,
                isLoading: isGenerating,
                onPressed: isGenerating ? null : _generate,
              ),
              AppSpacing.lg.vGap,
            ],
          ),
        ),
      ),
    );
  }
}

class _FilePickerCard extends StatelessWidget {
  const _FilePickerCard({required this.file, required this.onTap});

  final PlatformFile? file;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasFile = file != null;
    return Material(
      color: context.colors.card,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: hasFile ? context.colors.coral : context.colors.line),
          ),
          child: Row(
            children: [
              Icon(
                hasFile ? TablerIcons.fileCheck : TablerIcons.fileUpload,
                color: hasFile ? context.colors.coral : context.colors.muted,
              ),
              AppSpacing.sm.hGap,
              Expanded(
                child: Text(
                  hasFile ? file!.name : context.t.aiQuiz.pickFileLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: hasFile ? context.colors.ink : context.colors.muted,
                    fontWeight: hasFile ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
