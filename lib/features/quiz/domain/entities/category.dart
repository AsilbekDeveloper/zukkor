/// Backend'dagi quiz kategoriyasi — `GET /categories` javobiga mos.
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorKey,
    required this.questionCount,
  });

  final int id;
  final String name;
  final String iconName;
  final String colorKey;
  final int questionCount;
}
