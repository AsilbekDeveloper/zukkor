import '../../domain/entities/session_history_entry.dart';

class SessionHistoryEntryModel {
  const SessionHistoryEntryModel({
    required this.sessionId,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIconName,
    required this.categoryColorKey,
    required this.finishedAt,
    required this.correctCount,
    required this.totalQuestions,
    required this.totalBall,
    required this.totalXpEarned,
    required this.mode,
    this.opponentName,
    this.opponentAvatarColor,
    this.opponentAvatarImagePath,
    this.duelOutcome,
    this.lobbyRank,
    this.lobbyParticipantCount,
  });

  factory SessionHistoryEntryModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> category = json['category'] as Map<String, dynamic>;
    final Map<String, dynamic>? opponent = json['opponent'] as Map<String, dynamic>?;
    final Map<String, dynamic>? lobby = json['lobby'] as Map<String, dynamic>?;
    return SessionHistoryEntryModel(
      sessionId: json['session_id'] as String,
      categoryId: category['id'] as int,
      categoryName: category['name'] as String,
      categoryIconName: category['icon_name'] as String,
      categoryColorKey: category['color_key'] as String,
      finishedAt: DateTime.parse(json['finished_at'] as String),
      correctCount: json['correct_count'] as int,
      totalQuestions: json['total_questions'] as int,
      totalBall: json['total_ball'] as int,
      totalXpEarned: json['xp_earned'] as int,
      mode: switch (json['game_mode'] as String?) {
        'duel' => HistorySessionMode.duel,
        'lobby' => HistorySessionMode.lobby,
        _ => HistorySessionMode.solo,
      },
      opponentName: opponent?['name'] as String?,
      opponentAvatarColor: opponent?['avatar_color'] as String?,
      opponentAvatarImagePath: opponent?['avatar_image_path'] as String?,
      duelOutcome: switch (json['outcome'] as String?) {
        'won' => DuelHistoryOutcome.won,
        'lost' => DuelHistoryOutcome.lost,
        'draw' => DuelHistoryOutcome.draw,
        _ => null,
      },
      lobbyRank: lobby?['rank'] as int?,
      lobbyParticipantCount: lobby?['participant_count'] as int?,
    );
  }

  final String sessionId;
  final int categoryId;
  final String categoryName;
  final String categoryIconName;
  final String categoryColorKey;
  final DateTime finishedAt;
  final int correctCount;
  final int totalQuestions;
  final int totalBall;
  final int totalXpEarned;
  final HistorySessionMode mode;
  final String? opponentName;
  final String? opponentAvatarColor;
  final String? opponentAvatarImagePath;
  final DuelHistoryOutcome? duelOutcome;
  final int? lobbyRank;
  final int? lobbyParticipantCount;

  SessionHistoryEntry toEntity() => SessionHistoryEntry(
        sessionId: sessionId,
        categoryId: categoryId,
        categoryName: categoryName,
        categoryIconName: categoryIconName,
        categoryColorKey: categoryColorKey,
        finishedAt: finishedAt.toLocal(),
        correctCount: correctCount,
        totalQuestions: totalQuestions,
        totalBall: totalBall,
        totalXpEarned: totalXpEarned,
        mode: mode,
        opponent: opponentName == null
            ? null
            : DuelHistoryOpponent(
                name: opponentName!,
                avatarColor: opponentAvatarColor,
                avatarImagePath: opponentAvatarImagePath,
              ),
        duelOutcome: duelOutcome,
        lobbyResult: lobbyRank == null || lobbyParticipantCount == null
            ? null
            : LobbyHistoryResult(rank: lobbyRank!, participantCount: lobbyParticipantCount!),
      );
}
