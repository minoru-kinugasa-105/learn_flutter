import 'package:hive_flutter/hive_flutter.dart';

part 'todo.g.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  String title = '';

  @HiveField(1)
  String? description;

  @HiveField(2)
  DateTime? dueTime;

  @HiveField(3)
  bool isCompleted = false;

  @HiveField(4)
  bool isDeleted = false;

  @HiveField(5)
  DateTime createdAt = DateTime.now();

  @HiveField(6)
  DateTime updatedAt = DateTime.now();
}
