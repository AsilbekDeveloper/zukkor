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
import '../../../quiz/presentation/controllers/categories_controller.dart';
import '../../domain/entities/ai_quiz.dart';
import '../controllers/ai_quiz_controller.dart';
import '../widgets/topic_selection_row.dart';

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
  // Backendning MAX_UPLOAD_SIZE_BYTES (app/routers/ai_quiz.py) qiymati bilan
  // bir xil bo'lishi kerak - noto'g'ri bo'lsa, foydalanuvchi katta faylni
  // to'liq yuklab, faqat serverdan rad javobini olib vaqtini behuda sarflaydi.
  static const int _maxFileSizeBytes = 15 * 1024 * 1024;
  static const int _maxFileSizeMb = 15;

  final TextEditingController _instructionController = TextEditingController();
  final TextEditingController _topicController = TextEditingController();
  _GenerateMode _mode = _GenerateMode.document;
  PlatformFile? _pickedFile;
  int _questionCount = 10;
  int? _topicCategoryId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(categoriesControllerProvider.notifier).load());
  }

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

    final PlatformFile file = result.files.single;
    if (file.size > _maxFileSizeBytes) {
      if (!mounted) return;
      context.showSnack(context.t.aiQuiz.fileTooLarge(maxSizeMb: _maxFileSizeMb));
      return;
    }
    setState(() => _pickedFile = file);
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

    try {
      final String jobId = await ref.read(aiQuizControllerProvider.notifier).generateAsync(
            filePath: filePath,
            fileName: fileName,
            instruction: instruction,
            topic: topic,
            questionCount: _questionCount,
            topicCategoryId: _topicCategoryId,
          );
      if (!mounted) return;

      // Backend so'rovi baribir darhol qaytadi (uzun HTTP ulanishini ochiq
      // ushlab turmaslik uchun - katta hujjat 1-2 daqiqa olishi mumkin),
      // lekin foydalanuvchiga "eski" sinxron tuyg'uni qaytarish uchun shu
      // ekranda turib fon-so'rovni (har 7 soniyada, 2 daqiqagacha)
      // kuzatuvchi, yopilmaydigan "tayyorlanmoqda" dialogini ko'rsatamiz -
      // shunda foydalanuvchi ekrandan chiqarilmasdan, natijani shu yerda
      // kutadi (2026-09-06, foydalanuvchi ilgarigi xatti-harakatni so'rab
      // qaytardi: "avval tayyorlanmoqda deb chiqar edi").
      final result = await showDialog<({String status, AiQuiz? quiz, String? error})?>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _GeneratingDialog(jobId: jobId),
      );
      if (!mounted) return;

      if (result == null) {
        // 2 daqiqadan keyin ham tugamadi - juda kamdan-kam holat (g'ayrioddiy
        // uzun hujjat). Fon jarayonning o'zi davom etadi, foydalanuvchi
        // cheksiz kutib turmasin deb dialogni yopamiz - tayyor bo'lganda
        // bildirishnoma orqali bilib oladi.
        context.showSnack(context.t.aiQuiz.stillProcessingNotifyLater);
      } else if (result.status == 'completed') {
        context.showSnack(context.t.aiQuiz.generated);
        context.pop();
      } else {
        context.showSnack(result.error ?? t.errors.unknown);
      }
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
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
              TopicSelectionRow(
                selectedId: _topicCategoryId,
                onChanged: (id) => setState(() => _topicCategoryId = id),
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

/// Generatsiya davomida (odatda 10-60+ soniya - hujjatni o'qish + AI
/// so'rovi) ekranda ko'rsatiladigan, yopilmaydigan dialog. O'zi (har 7
/// soniyada, 2 daqiqagacha) `checkJobStatus` orqali fon-jarayonni
/// so'raydi va tugagach (yoki 2 daqiqadan oshsa) o'zini yopib natijani
/// chaqiruvchiga qaytaradi.
class _GeneratingDialog extends ConsumerStatefulWidget {
  const _GeneratingDialog({required this.jobId});

  final String jobId;

  @override
  ConsumerState<_GeneratingDialog> createState() => _GeneratingDialogState();
}

class _GeneratingDialogState extends ConsumerState<_GeneratingDialog> {
  Timer? _pollTimer;
  int _attempts = 0;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 7), _poll);
  }

  Future<void> _poll(Timer timer) async {
    _attempts++;
    if (_attempts > 17) {
      timer.cancel();
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final result = await ref.read(aiQuizControllerProvider.notifier).checkJobStatus(widget.jobId);
    if ((result.status == 'completed' || result.status == 'failed') && mounted) {
      timer.cancel();
      Navigator.of(context).pop(result);
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: CircularProgressIndicator(strokeWidth: 3, color: context.colors.coral),
                    ),
                    Icon(TablerIcons.sparkle, color: context.colors.coral, size: 24),
                  ],
                ),
              ),
              AppSpacing.lg.vGap,
              Text(
                context.t.aiQuiz.generatingTitle,
                textAlign: TextAlign.center,
                style: context.textStyles.titleLarge,
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
