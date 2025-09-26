import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import 'edit_todo_dialog.dart';

class TodoListWidget extends StatelessWidget {
  final int tabIndex;
  final Function(Todo todo, {bool? isCompleted, bool? isDeleted}) onUpdateTodo;
  final Function(Todo todo) onCopyTodo;
  final Function(
    Todo todo,
    String title,
    String? description,
    DateTime? dueTime,
  )
  onEditTodo;

  const TodoListWidget({
    super.key,
    required this.tabIndex,
    required this.onUpdateTodo,
    required this.onCopyTodo,
    required this.onEditTodo,
  });

  @override
  Widget build(BuildContext context) {
    final todos = TodoService.getTodosByStatus(tabIndex);

    if (todos.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 200), // 下部に200pxの余白を追加
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return _buildTodoCard(context, todo);
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

  Widget _buildTodoCard(BuildContext context, Todo todo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onLongPress: () => _showEditOptions(context, todo),
        child: ListTile(
          title: Text(
            todo.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: todo.isCompleted ? Colors.grey : null,
                  ),
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
                  visualDensity: const VisualDensity(
                    horizontal: -4.0,
                    vertical: -4.0,
                  ),
                  icon: const Icon(Icons.check, color: Colors.green, size: 20),
                  onPressed: () => onUpdateTodo(todo, isCompleted: true),
                  tooltip: '完了にする',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (tabIndex == 0 || tabIndex == 1) // 未完了または完了済みタブの場合
                IconButton(
                  visualDensity: const VisualDensity(
                    horizontal: -4.0,
                    vertical: -4.0,
                  ),
                  icon: const Icon(Icons.copy, color: Colors.blue, size: 18),
                  onPressed: () => onCopyTodo(todo),
                  tooltip: 'コピーする',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              if (tabIndex == 0 || tabIndex == 1) // 未完了または完了済みタブの場合
                IconButton(
                  visualDensity: const VisualDensity(
                    horizontal: -4.0,
                    vertical: -4.0,
                  ),
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () => onUpdateTodo(todo, isDeleted: true),
                  tooltip: '削除する',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
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
      ),
    );
  }

  /// 編集オプションを表示する
  void _showEditOptions(BuildContext context, Todo todo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('編集'),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context, todo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.green),
              title: const Text('コピー'),
              onTap: () {
                Navigator.pop(context);
                onCopyTodo(todo);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 編集ダイアログを表示する
  void _showEditDialog(BuildContext context, Todo todo) {
    EditTodoDialog.show(context, todo, (title, description, dueTime) {
      onEditTodo(todo, title, description, dueTime);
    });
  }
}
