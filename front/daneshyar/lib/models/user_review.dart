import 'package:hive/hive.dart';

part 'user_review.g.dart';

@HiveType(typeId: 1)
class UserReview extends HiveObject {
  @HiveField(0)
  String articleId;

  @HiveField(1)
  int rating; // 1 to 5 stars

  @HiveField(2)
  String notes;

  @HiveField(3)
  List<String> pros;

  @HiveField(4)
  List<String> cons;

  @HiveField(5)
  DateTime createdAt;

  UserReview({
    required this.articleId,
    required this.rating,
    required this.notes,
    required this.pros,
    required this.cons,
    required this.createdAt,
  });
}