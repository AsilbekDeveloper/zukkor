import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

/// 6 single-digit boxes for entering a room code — mirrors the
/// prototype's `.code-input-row` / `.code-box`, including its
/// auto-advance-on-type / auto-back-on-backspace behavior.
class CodeInputRow extends StatefulWidget {
  const CodeInputRow({super.key});

  static const int digitCount = 6;

  @override
  State<CodeInputRow> createState() => _CodeInputRowState();
}

class _CodeInputRowState extends State<CodeInputRow> {
  late final List<TextEditingController> _controllers = List.generate(
    CodeInputRow.digitCount,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _focusNodes = List.generate(
    CodeInputRow.digitCount,
    (_) => FocusNode(),
  );

  @override
  void dispose() {
    for (final TextEditingController controller in _controllers) {
      controller.dispose();
    }
    for (final FocusNode node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < CodeInputRow.digitCount - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    // Boxes are `Expanded` (never a fixed 42px each) so 6 of them always
    // fit any width without overflowing — the whole row is then capped
    // so they don't balloon into oversized squares on wide screens.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: Row(
          children: [
            for (int i = 0; i < CodeInputRow.digitCount; i++) ...[
              Expanded(
                child: _CodeBox(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  semanticLabel: context.t.joinCode.codeDigitLabel(position: i + 1),
                  onChanged: (value) => _onChanged(i, value),
                  onKey: (event) => _onKey(i, event),
                ),
              ),
              if (i < CodeInputRow.digitCount - 1) AppSpacing.xxs.hGap,
            ],
          ],
        ),
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.controller,
    required this.focusNode,
    required this.semanticLabel,
    required this.onChanged,
    required this.onKey,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String semanticLabel;
  final ValueChanged<String> onChanged;
  final KeyEventResult Function(KeyEvent event) onKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.smAll,
        boxShadow: context.colors.shadowSm,
      ),
      child: Focus(
        onKeyEvent: (node, event) => onKey(event),
        child: Semantics(
          label: semanticLabel,
          textField: true,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: context.colors.ink,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: AppRadius.smAll,
                borderSide: BorderSide(color: context.colors.muted, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.smAll,
                borderSide: BorderSide(color: context.colors.muted, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.smAll,
                borderSide: BorderSide(color: context.colors.coral, width: 1.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
