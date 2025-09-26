import '../models/todo.dart';
import 'hive_service.dart';
import 'notification_service.dart';

class TodoService {
  /// Todoを追加する
  static Future<void> addTodo({
    required String title,
    String? description,
    DateTime? dueTime,
  }) async {
    final todo = Todo()
      ..title = title
      ..description = description
      ..dueTime = dueTime
      ..isCompleted = false
      ..isDeleted = false
      ..isNotificationSent = false
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await HiveService.todoBox.add(todo);

    // 期限がある場合は通知をスケジュール
    if (dueTime != null) {
      await NotificationService.scheduleTodoNotification(todo);
    }
  }

  /// Todoの状態を更新する
  static Future<void> updateTodo(
    Todo todo, {
    bool? isCompleted,
    bool? isDeleted,
  }) async {
    if (isCompleted != null) {
      todo.isCompleted = isCompleted;
      // 完了した場合は通知をキャンセル
      if (isCompleted) {
        await NotificationService.cancelTodoNotification(todo);
      }
    }
    if (isDeleted != null) {
      todo.isDeleted = isDeleted;
      // 削除した場合は通知をキャンセル
      if (isDeleted) {
        await NotificationService.cancelTodoNotification(todo);
      }
    }
    todo.updatedAt = DateTime.now();
    await todo.save();
  }

  /// Todoをコピーする
  static Future<void> copyTodo(Todo originalTodo) async {
    final copiedTodo = Todo()
      ..title = '${originalTodo.title} (コピー)'
      ..description = originalTodo.description
      ..dueTime = originalTodo.dueTime
      ..isCompleted = false
      ..isDeleted = false
      ..isNotificationSent = false
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await HiveService.todoBox.add(copiedTodo);

    // 期限がある場合は通知をスケジュール
    if (originalTodo.dueTime != null) {
      await NotificationService.scheduleTodoNotification(copiedTodo);
    }
  }

  /// Todoを編集する
  static Future<void> editTodo(
    Todo todo, {
    required String title,
    String? description,
    DateTime? dueTime,
  }) async {
    // 既存の通知をキャンセル
    await NotificationService.cancelTodoNotification(todo);

    todo.title = title;
    todo.description = description;
    todo.dueTime = dueTime;
    todo.isNotificationSent = false; // 編集時は通知フラグをリセット
    todo.updatedAt = DateTime.now();
    await todo.save();

    // 新しい期限がある場合は通知をスケジュール
    if (dueTime != null) {
      await NotificationService.scheduleTodoNotification(todo);
    }
  }

  /// フラグに応じてTodoを分類する
  static List<Todo> getTodosByStatus(int tabIndex) {
    final allTodos = HiveService.todoBox.values.toList();

    switch (tabIndex) {
      case 0: // 未完了
        return allTodos
            .where((todo) => !todo.isCompleted && !todo.isDeleted)
            .toList();
      case 1: // 完了済み
        return allTodos
            .where((todo) => todo.isCompleted && !todo.isDeleted)
            .toList();
      case 2: // 削除済み
        return allTodos.where((todo) => todo.isDeleted).toList();
      default:
        return [];
    }
  }

  /// 期限表示をフォーマットする
  static String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (targetDate == today) {
      // 今日の場合
      final diff = dateTime.difference(now);
      if (diff.inHours > 0) {
        return '今日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} (${diff.inHours}時間後)';
      } else if (diff.inMinutes > 0) {
        return '今日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} (${diff.inMinutes}分後)';
      } else {
        return '今日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} (期限切れ)';
      }
    } else if (targetDate == tomorrow) {
      // 明日の場合
      return '明日 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // 数日後の場合
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
