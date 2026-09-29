import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/pill_segment_control.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../../ai_quiz/domain/entities/ai_quiz.dart';
import '../../../ai_quiz/presentation/controllers/ai_quiz_controller.dart';
import '../../../quiz/data/repositories/quiz_repository_impl.dart';
import '../../../quiz/domain/repositories/quiz_repository.dart';

/// Backend'dagi `economy_config.EXPORT_DIAMOND_COST` bilan bir xil qiymat
/// (2026-09-29, foydalanuvchi qarori: qat'iy narx, savollar soniga
/// qaramaydi) - qo'shimcha tarmoq so'rovi shart emas deb ATAYLAB
/// qattiq yozilgan (foydalanuvchi so'rovi). Narx admin panelidan
/// o'zgartirilsa, bu qiymat ham qo'lda yangilanishi kerak.
const int _diamondExportCost = 40;

/// 2026-09-29, foydalanuvchi qarori: Excel butunlay olib tashlandi (chop
/// etiladigan test qog'ozi uchun tabiiy format emas edi) - endi faqat
/// PDF va Word, ikkalasi ham har doim ishlaydi.
enum _ExportFormat { pdf, docx }

extension on _ExportFormat {
  String get fileExtension => switch (this) {
    _ExportFormat.pdf => 'pdf',
    _ExportFormat.docx => 'docx',
  };

  String get mimeType => switch (this) {
    _ExportFormat.pdf => 'application/pdf',
    _ExportFormat.docx =>
      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  };
}

/// Profil → "Eksport" - foydalanuvchining o'zi yaratgan (AI/qo'lda)
/// quizlaridan birini tanlab, PDF (bosma test qog'ozi) sifatida
/// eksport qiladi (2026-09-28, foydalanuvchi so'rovi bilan
/// `QuizSetupScreen`dagi avvalgi joylashuv o'rniga shu alohida ekranga
/// ko'chirildi - o'qituvchi bir joydan barcha quizlarini ko'rib,
/// kerakligini tanlaydi).
class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  _ExportFormat _format = _ExportFormat.pdf;

  @override
  void initState() {
    super.initState();
    if (ref.read(aiQuizControllerProvider).quizzes == null) {
      Future.microtask(
        () => ref.read(aiQuizControllerProvider.notifier).loadList(),
      );
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.profile);
    }
  }

  String _formatLabel(_ExportFormat format) => switch (format) {
    _ExportFormat.pdf => context.t.export.formatPdf,
    _ExportFormat.docx => context.t.export.formatDocx,
  };

  Future<void> _exportQuiz(AiQuiz quiz) async {
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _ExportingDialog(quizName: quiz.name),
      ),
    );

    try {
      final QuizRepository repo = ref.read(quizRepositoryProvider);
      final List<int> bytes = _format == _ExportFormat.docx
          ? await repo.exportQuizDocx(quiz.id)
          : await repo.exportQuizPdf(quiz.id);
      final Directory tempDir = await getTemporaryDirectory();
      final String safeName = quiz.name.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
      final File file = File(
        '${tempDir.path}/${safeName.isEmpty ? "quiz" : safeName}.${_format.fileExtension}',
      );
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      await Share.shareXFiles([XFile(file.path, mimeType: _format.mimeType)]);
    } on Failure catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      context.showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      context.showSnack(t.errors.unknown);
    }
  }

  Widget _formatSelector(BuildContext context) {
    return PillSegmentControl<_ExportFormat>(
      values: _ExportFormat.values,
      selected: _format,
      labelBuilder: _formatLabel,
      onChanged: (format) => setState(() => _format = format),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AiQuizState state = ref.watch(aiQuizControllerProvider);
    final List<AiQuiz>? quizzes = state.quizzes;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              FadeSlideIn(
                child: BackHeader(
                  title: context.t.export.title,
                  onBack: _goBack,
                ),
              ),
              AppSpacing.sm.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 40),
                child: Text(
                  context.t.export.subtitle,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ),
              AppSpacing.lg.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: _formatSelector(context),
              ),
              AppSpacing.xs.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 80),
                child: Text(
                  context.t.export.costPerExport(cost: _diamondExportCost),
                  style: context.textStyles.bodySmall?.copyWith(
                    color: context.colors.muted,
                  ),
                ),
              ),
              AppSpacing.lg.vGap,
              Expanded(
                child: state.hasListError
                    ? ErrorRetryView(
                        onRetry: () => ref
                            .read(aiQuizControllerProvider.notifier)
                            .loadList(),
                      )
                    : quizzes == null
                    ? const ShimmerListSkeleton(count: 4, trailingWidth: 36)
                    : quizzes.isEmpty
                    ? Center(
                        child: Text(
                          context.t.export.emptyQuizzes,
                          textAlign: TextAlign.center,
                          style: context.textStyles.bodyMedium?.copyWith(
                            color: context.colors.muted,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 100),
                          child: Column(
                            children: [
                              for (final AiQuiz quiz in quizzes) ...[
                                _ExportQuizRow(
                                  quiz: quiz,
                                  onTap: () => _exportQuiz(quiz),
                                ),
                                AppSpacing.xs.vGap,
                              ],
                            ],
                          ),
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

class _ExportQuizRow extends StatelessWidget {
  const _ExportQuizRow({required this.quiz, required this.onTap});

  final AiQuiz quiz;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Material(
        color: context.colors.card,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: AppRadius.smAll,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.smAll,
              border: Border.all(color: context.colors.line),
              boxShadow: context.colors.shadowSm,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.coral,
                    borderRadius: AppRadius.smAll,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    TablerIcons.sparkle,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                AppSpacing.sm.hGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        quiz.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        context.t.common.questionCount(
                          count: quiz.questionCount,
                        ),
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  TablerIcons.download,
                  color: context.colors.muted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportingDialog extends StatelessWidget {
  const _ExportingDialog({required this.quizName});

  final String quizName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: context.colors.coral),
            AppSpacing.md.vGap,
            Text(
              context.t.export.generatingDialog(name: quizName),
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
