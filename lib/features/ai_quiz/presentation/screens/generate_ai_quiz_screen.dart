import 'dart:async';

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

enum _GenerateMode { document, topic }

/// Ikki usulda AI orqali quiz generatsiya qilish: hujjat (PDF/Word/matn)
/// yuklab undan, yoki faqat mavzu yozib — bu holda AI internetdan qidirib
/// mavzu bo'yicha savollar tayyorlaydi. Muvaffaqiyatli bo'lsa natija
/// darhol backend'da saqlanadi (alohida "saqlash" qadami yo'q) va
/// foydalanuvchi "Mening AI quizlarim" ro'yxatiga qaytariladi.
class GenerateAiQuizScreen extends ConsumerStatefulWidget {
  const GenerateAiQuizScreen({super.key});

  @override
  ConsumerState<GenerateAiQuizScreen> createState() => _GenerateAiQuizScreenState();
}

class _GenerateAiQuizScreenState extends ConsumerState<GenerateAiQuizScreen> {
  static const List<int> _questionCountOptions = [5, 10, 15, 20];

  final TextEditingController _instructionController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  _GenerateMode _mode = _GenerateMode.document;
  PlatformFile? _pickedFile;
  int _questionCount = 10;

  @override
  void dispose() {
    _instructionController.dispose();
    _topicController.dispose();
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
    String? filePath;
    String? fileName;
    String? instruction;
    String? topic;

    if (_mode == _GenerateMode.document) {
      final PlatformFile? file = _pickedFile;
      final String? path = file?.path;
      if (file == null || path == null) {
        context.showSnack(context.t.aiQuiz.pickFileFirst);
        return;
      }
      filePath = path;
      fileName = file.name;
      instruction = _instructionController.text.trim();
    } else {
      final String topicText = _topicController.text.trim();
      if (topicText.isEmpty) {
        context.showSnack(context.t.aiQuiz.topicRequired);
        return;
      }
      topic = topicText;
      instruction = _instructionController.text.trim();
    }

    context.hideKeyboard();
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const _GeneratingDialog(),
      ),
    );

    try {
      await ref.read(aiQuizControllerProvider.notifier).generate(
            filePath: filePath,
            fileName: fileName,
            instruction: instruction,
            topic: topic,
            questionCount: _questionCount,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
      context.showSnack(context.t.aiQuiz.generated);
      context.pop();
    } on Failure catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      context.showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pop();
      context.showSnack(t.errors.unknown);
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
              PillSegmentControl<_GenerateMode>(
                values: const [_GenerateMode.document, _GenerateMode.topic],
                selected: _mode,
                labelBuilder: (value) => value == _GenerateMode.document
                    ? context.t.aiQuiz.modeDocumentLabel
                    : context.t.aiQuiz.modeTopicLabel,
                onChanged: isGenerating ? (_) {} : (value) => setState(() => _mode = value),
              ),
              AppSpacing.lg.vGap,
              if (_mode == _GenerateMode.document) ...[
                _FilePickerCard(file: _pickedFile, onTap: isGenerating ? null : _pickFile),
                AppSpacing.lg.vGap,
                AppTextField(
                  label: context.t.aiQuiz.instructionLabel,
                  hint: context.t.aiQuiz.instructionHint,
                  controller: _instructionController,
                ),
              ] else ...[
                AppTextField(
                  label: context.t.aiQuiz.topicLabel,
                  hint: context.t.aiQuiz.topicHint,
                  controller: _topicController,
                ),
                AppSpacing.lg.vGap,
                AppTextField(
                  label: context.t.aiQuiz.instructionLabel,
                  hint: context.t.aiQuiz.instructionHint,
                  controller: _instructionController,
                ),
              ],
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

/// Generatsiya davomida (odatda 10-60+ soniya - hujjatni o'qish + AI
/// so'rovi) ko'rsatiladi, foydalanuvchi ilova "osilib qolgan" deb
/// o'ylamasligi uchun. Orqaga qaytish/tashqarini bosish bilan yopilmaydi -
/// generatsiyani bekor qilishning hech qanday yo'li yo'q.
class _GeneratingDialog extends StatelessWidget {
  const _GeneratingDialog();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: context.colors.card,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: context.colors.coral),
              AppSpacing.lg.vGap,
              Text(
                context.t.aiQuiz.generatingTitle,
                textAlign: TextAlign.center,
                style: context.textStyles.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              AppSpacing.xs.vGap,
              Text(
                context.t.aiQuiz.generatingSubtitle,
                textAlign: TextAlign.center,
                style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
