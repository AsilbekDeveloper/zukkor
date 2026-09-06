import '../../domain/entities/weekly_activity.dart';

class WeeklyActivityModel {
  const WeeklyActivityModel({required this.days});

  factory WeeklyActivityModel.fromJson(Map<String, dynamic> json) =>
      WeeklyActivityModel(days: (json['days'] as List<dynamic>).cast<bool>());

  final List<bool> days;

  WeeklyActivity toEntity() => WeeklyActivity(days: days);
}
