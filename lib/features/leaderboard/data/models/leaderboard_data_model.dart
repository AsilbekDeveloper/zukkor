import '../../domain/entities/leaderboard_data.dart';
import 'rank_entry_model.dart';

class LeaderboardDataModel {
  const LeaderboardDataModel({required this.entries, required this.me});

  factory LeaderboardDataModel.fromJson(Map<String, dynamic> json) => LeaderboardDataModel(
        entries: (json['entries'] as List<dynamic>)
            .map((e) => RankEntryModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        me: RankEntryModel.fromJson(json['me'] as Map<String, dynamic>),
      );

  final List<RankEntryModel> entries;
  final RankEntryModel me;

  LeaderboardData toEntity() =>
      LeaderboardData(entries: entries.map((e) => e.toEntity()).toList(), me: me.toEntity());
}
