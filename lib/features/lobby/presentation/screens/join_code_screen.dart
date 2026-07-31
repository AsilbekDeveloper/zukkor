import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/lobby_join_error.dart';
import '../controllers/lobby_controller.dart';
import '../widgets/code_input_row.dart';
import 'lobby_screen.dart';

/// Join a friend's room by its 6-digit code — mirrors the prototype's
/// `view-join-code`.
///
/// Sends a real `lobby_join` over the lobby WebSocket once all 6 digits
/// are entered and waits for [LobbyController]'s `room` (success) or
/// `joinError` (bad code / room full) to resolve.
class JoinCodeScreen extends ConsumerStatefulWidget {
  const JoinCodeScreen({super.key});

  @override
  ConsumerState<JoinCodeScreen> createState() => _JoinCodeScreenState();
}

class _JoinCodeScreenState extends ConsumerState<JoinCodeScreen> {
  // Mirrors DuelWaitingScreen/LobbyScreen's same safety net: a lost
  // `lobby_join` (socket not actually ready, dropped message, ...)
  // otherwise left the Join button spinning with zero feedback forever.
  static const Duration _joinTimeout = Duration(seconds: 20);

  String _code = '';
  bool _joining = false;
  Timer? _joinTimeoutTimer;

  @override
  void dispose() {
    _joinTimeoutTimer?.cancel();
    super.dispose();
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _join() {
    setState(() => _joining = true);
    ref.read(lobbyControllerProvider.notifier).joinRoom(_code);
    _joinTimeoutTimer?.cancel();
    _joinTimeoutTimer = Timer(_joinTimeout, () {
      if (mounted) {
        setState(() => _joining = false);
        context.showSnack(context.t.joinCode.timedOut);
      }
    });
  }

  String _errorMessage(BuildContext context, LobbyJoinErrorReason reason) => switch (reason) {
        LobbyJoinErrorReason.notFound => context.t.joinCode.roomNotFound,
        LobbyJoinErrorReason.roomFull => context.t.joinCode.roomFull,
        LobbyJoinErrorReason.alreadyStarted => context.t.joinCode.alreadyStarted,
      };

  @override
  Widget build(BuildContext context) {
    ref.listen(lobbyControllerProvider, (previous, next) {
      if (next.room != null && next.room != previous?.room) {
        _joinTimeoutTimer?.cancel();
        context.pushReplacement(AppRoutes.lobby, extra: LobbyRole.guest);
      } else if (next.joinError != null && next.joinError != previous?.joinError) {
        _joinTimeoutTimer?.cancel();
        setState(() => _joining = false);
        context.showSnack(_errorMessage(context, next.joinError!));
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.home.joinWithCode, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 260),
                  child: Text(
                    context.t.joinCode.hint,
                    textAlign: TextAlign.center,
                    style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                  ),
                ),
              ),
              AppSpacing.xl.vGap,
              CodeInputRow(onCodeChanged: (code) => setState(() => _code = code)),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: context.t.joinCode.joinButton,
                icon: const Icon(TablerIcons.arrowRight, color: Colors.white, size: 18),
                isLoading: _joining,
                onPressed: _code.length == CodeInputRow.digitCount ? _join : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
