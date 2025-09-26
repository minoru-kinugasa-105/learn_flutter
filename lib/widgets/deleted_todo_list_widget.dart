import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import '../services/auth_service.dart';

class DeletedTodoListWidget extends StatefulWidget {
  final Function(Todo todo, {bool? isCompleted, bool? isDeleted}) onUpdateTodo;
  final Function(Todo todo) onCopyTodo;
  final Function(
    Todo todo,
    String title,
    String? description,
    DateTime? dueTime,
  )
  onEditTodo;

  const DeletedTodoListWidget({
    super.key,
    required this.onUpdateTodo,
    required this.onCopyTodo,
    required this.onEditTodo,
  });

  @override
  State<DeletedTodoListWidget> createState() => _DeletedTodoListWidgetState();
}

class _DeletedTodoListWidgetState extends State<DeletedTodoListWidget> {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  bool _authFailed = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    setState(() {
      _isLoading = true;
      _authFailed = false;
    });

    // 生体認証が利用可能かチェック
    final bool shouldRequireAuth = await AuthService.shouldRequireAuth();

    if (!shouldRequireAuth) {
      // 生体認証が利用できない場合は認証なしで表示
      setState(() {
        _isAuthenticated = true;
        _isLoading = false;
      });
      return;
    }

    // FaceID認証を実行
    final bool authenticated = await AuthService.authenticateWithFaceID();

    setState(() {
      _isAuthenticated = authenticated;
      _isLoading = false;
      _authFailed = !authenticated;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_authFailed) {
      return _buildAuthFailedState();
    }

    if (!_isAuthenticated) {
      return _buildUnauthenticatedState();
    }

    return _buildTodoList();
  }

  Widget _buildLoadingState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              '認証中...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthFailedState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(
                '認証に失敗しました',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '削除済みタスクを閲覧するには認証が必要です',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _checkAuthentication,
                icon: const Icon(Icons.refresh),
                label: const Text('再試行'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedState() {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.face_retouching_natural,
                size: 64,
                color: Colors.blue[400],
              ),
              const SizedBox(height: 16),
              Text(
                '認証が必要です',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '削除済みタスクを閲覧するにはFaceID認証が必要です',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _checkAuthentication,
                icon: const Icon(Icons.face),
                label: const Text('認証する'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoList() {
    final todos = TodoService.getTodosByStatus(2); // 削除済みタブ

    if (todos.isEmpty) {
      return _buildEmptyState();
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 200),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final todo = todos[index];
          return _buildTodoCard(context, todo);
        }, childCount: todos.length),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              '削除済みのタスクはありません',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoCard(BuildContext context, Todo todo) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
        ),
        title: Text(
          todo.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description != null && todo.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  todo.description!,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ),
            if (todo.dueTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      TodoService.formatDateTime(todo.dueTime!),
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.restore, color: Colors.orange),
              onPressed: () => widget.onUpdateTodo(todo, isDeleted: false),
              tooltip: '復元する',
            ),
          ],
        ),
      ),
    );
  }
}
