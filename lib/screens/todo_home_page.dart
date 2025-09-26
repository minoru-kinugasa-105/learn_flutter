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

class _TodoHomePageState extends State<TodoHomePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<ScrollController> _scrollControllers;

  @override
  void initState() {
    super.initState();
    _initializeHive();
    _initializeControllers();
  }

  void _initializeControllers() {
    // TabControllerを作成
    _tabController = TabController(length: 3, vsync: this);

    // 各タブ用のScrollControllerを作成
    _scrollControllers = List.generate(3, (index) => ScrollController());

    // タブ切り替え時のリスナーを追加
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    // タブが切り替わった時に、そのタブのスクロール位置を一番上に戻す
    if (_tabController.indexIsChanging) {
      setState(() {}); // タブの内容を更新

      final currentIndex = _tabController.index;
      final controller = _scrollControllers[currentIndex];

      // 少し遅延を入れてスクロール位置をリセット
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.hasClients) {
          controller.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    // ScrollControllerとTabControllerを適切に解放
    for (final controller in _scrollControllers) {
      controller.dispose();
    }
    _tabController.dispose();
    super.dispose();
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

  /// Todoを編集するメソッド
  Future<void> _editTodo(
    Todo todo,
    String title,
    String? description,
    DateTime? dueTime,
  ) async {
    await TodoService.editTodo(
      todo,
      title: title,
      description: description,
      dueTime: dueTime,
    );
    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('タスクを編集しました')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!HiveService.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        controller: _scrollControllers[_tabController.index],
        slivers: [
          SliverAppBar(
            title: const Text('Todo App'),
            floating: true,
            snap: true,
            pinned: true,
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '未完了'),
                Tab(text: '完了済み'),
                Tab(text: '削除済み'),
              ],
            ),
          ),
          // 現在のタブの内容を表示
          TodoListWidget(
            tabIndex: _tabController.index,
            onUpdateTodo: _updateTodo,
            onCopyTodo: _copyTodo,
            onEditTodo: _editTodo,
          ),
        ],
      ),
      // 右下のプラスボタン
      floatingActionButton: FloatingActionButton(
        onPressed: _addTodo,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
