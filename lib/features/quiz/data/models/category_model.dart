import '../../domain/entities/category.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorKey,
    required this.questionCount,
    required this.playCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json['id'] as int,
        name: json['name'] as String,
        iconName: json['icon_name'] as String,
        colorKey: json['color_key'] as String,
        questionCount: json['question_count'] as int,
        playCount: json['play_count'] as int? ?? 0,
      );

  final int id;
  final String name;
  final String iconName;
  final String colorKey;
  final int questionCount;
  final int playCount;

  Category toEntity() => Category(
        id: id,
        name: name,
        iconName: iconName,
        colorKey: colorKey,
        questionCount: questionCount,
        playCount: playCount,
      );
}
