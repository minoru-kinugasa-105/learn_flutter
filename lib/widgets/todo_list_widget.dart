import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';

class TodoListWidget extends StatelessWidget {
  final int tabIndex;
  final Function(Todo todo, {bool? isCompleted, bool? isDeleted}) onUpdateTodo;

  const TodoListWidget({
    super.key,
    required this.tabIndex,
    required this.onUpdateTodo,
  });

  @override
  Widget build(BuildContext context) {
    final todos = TodoService.getTodosByStatus(tabIndex);

    if (todos.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return _buildTodoCard(todo);
      },
    );
  }

  Widget _buildEmptyState() {
    String message;
    switch (tabIndex) {
      case 0:
        message = '未完了のタスクはありません';
        break;
      case 1:
        message = '完了済みのタスクはありません';
        break;
      case 2:
        message = '削除済みのタスクはありません';
        break;
      default:
        message = 'タスクがありません';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoCard(Todo todo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description != null && todo.description!.isNotEmpty)
              Text(
                todo.description!,
                style: TextStyle(color: todo.isCompleted ? Colors.grey : null),
              ),
            if (todo.dueTime != null)
              Text(
                '期限: ${TodoService.formatDateTime(todo.dueTime!)}',
                style: TextStyle(
                  color: todo.dueTime!.isBefore(DateTime.now())
                      ? Colors.red
                      : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tabIndex == 0) // 未完了タブの場合
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () => onUpdateTodo(todo, isCompleted: true),
                tooltip: '完了にする',
              ),
            if (tabIndex == 0 || tabIndex == 1) // 未完了または完了済みタブの場合
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => onUpdateTodo(todo, isDeleted: true),
                tooltip: '削除する',
              ),
            if (tabIndex == 1) // 完了済みタブの場合
              IconButton(
                icon: const Icon(Icons.undo, color: Colors.blue),
                onPressed: () => onUpdateTodo(todo, isCompleted: false),
                tooltip: '未完了に戻す',
              ),
            if (tabIndex == 2) // 削除済みタブの場合
              IconButton(
                icon: const Icon(Icons.restore, color: Colors.orange),
                onPressed: () => onUpdateTodo(todo, isDeleted: false),
                tooltip: '復元する',
              ),
          ],
        ),
      ),
    );
  }
}
