import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/pill_segment_control.dart';
import '../../../../i18n/strings.g.dart';
import '../models/quiz_category.dart';
import '../models/quiz_launch_args.dart';

/// Savollar sonini tanlash — tezkor variantlar (5/10/15/20) yoki pastga
/// aylantirib istalgan sonni (1-50) tanlash. Kategoriya tanlangandan
/// keyin, Countdown'dan oldin ko'rsatiladi.
class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({required this.category, super.key});

  final QuizCategory category;

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  static const List<int> _quickOptions = [5, 10, 15, 20];
  static const int _minCustom = 1;
  static const int _maxCustom = 50;
  static const int _defaultCount = 10;

  int _selectedCount = _defaultCount;
  late final FixedExtentScrollController _wheelController;

  @override
  void initState() {
    super.initState();
    _wheelController = FixedExtentScrollController(initialItem: _selectedCount - _minCustom);
  }

  @override
  void dispose() {
    _wheelController.dispose();
    super.dispose();
  }

  void _selectQuick(int count) {
    setState(() => _selectedCount = count);
    _wheelController.animateToItem(
      count - _minCustom,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _onWheelChanged(int index) {
    setState(() => _selectedCount = _minCustom + index);
  }

  void _start() {
    context.push(
      AppRoutes.quizIntro,
      extra: QuizLaunchArgs(category: widget.category, questionCount: _selectedCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.quizSetup.title, onBack: () => context.pop()),
              AppSpacing.sm.vGap,
              Text(
                context.t.quizSetup.subtitle,
                style: context.textStyles.bodyMedium?.copyWith(color: context.colors.muted),
              ),
              AppSpacing.xl.vGap,
              PillSegmentControl<int>(
                values: _quickOptions,
                selected: _quickOptions.contains(_selectedCount) ? _selectedCount : -1,
                labelBuilder: (value) => '$value',
                onChanged: _selectQuick,
              ),
              AppSpacing.xl.vGap,
              Text(
                context.t.quizSetup.customLabel,
                textAlign: TextAlign.center,
                style: context.textStyles.labelSmall,
              ),
              AppSpacing.sm.vGap,
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: context.colors.card,
                    border: Border.all(color: context.colors.line),
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: CupertinoPicker(
                    scrollController: _wheelController,
                    itemExtent: 44,
                    backgroundColor: Colors.transparent,
                    selectionOverlay: Container(
                      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: context.colors.coral.withValues(alpha: 0.08),
                        border: Border.symmetric(
                          horizontal: BorderSide(color: context.colors.coral, width: 1.5),
                        ),
                      ),
                    ),
                    onSelectedItemChanged: _onWheelChanged,
                    children: [
                      for (int count = _minCustom; count <= _maxCustom; count++)
                        Center(
                          child: Text(
                            '$count',
                            style: context.textStyles.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: context.colors.ink,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: context.t.quizSetup.startButton,
                onPressed: _start,
              ),
              AppSpacing.lg.vGap,
            ],
          ),
        ),
      ),
    );
  }
}
