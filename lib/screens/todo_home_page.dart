import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/hive_service.dart';
import '../services/todo_service.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/todo_list_widget.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    // ボックスが既に開かれているかチェック
    if (!HiveService.isInitialized) {
      await HiveService.initialize();
    }
    setState(() {});
  }

  /// Todoを追加するメソッド
  Future<void> _addTodo() async {
    await AddTodoDialog.show(context, (title, description, dueTime) async {
      await TodoService.addTodo(
        title: title,
        description: description,
        dueTime: dueTime,
      );
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('タスクを追加しました')));
      }
    });
  }

  /// Todoの状態を更新するメソッド
  Future<void> _updateTodo(
    Todo todo, {
    bool? isCompleted,
    bool? isDeleted,
  }) async {
    await TodoService.updateTodo(
      todo,
      isCompleted: isCompleted,
      isDeleted: isDeleted,
    );
    setState(() {});
  }

  /// Todoをコピーするメソッド
  Future<void> _copyTodo(Todo todo) async {
    await TodoService.copyTodo(todo);
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('タスクをコピーしました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!HiveService.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Todo App'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '未完了'),
              Tab(text: '完了済み'),
              Tab(text: '削除済み'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 未完了タブ
            TodoListWidget(
              tabIndex: 0,
              onUpdateTodo: _updateTodo,
              onCopyTodo: _copyTodo,
            ),
            // 完了済みタブ
            TodoListWidget(
              tabIndex: 1,
              onUpdateTodo: _updateTodo,
              onCopyTodo: _copyTodo,
            ),
            // 削除済みタブ
            TodoListWidget(
              tabIndex: 2,
              onUpdateTodo: _updateTodo,
              onCopyTodo: _copyTodo,
            ),
          ],
        ),
        // 右下のプラスボタン
        floatingActionButton: FloatingActionButton(
          onPressed: _addTodo,
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
