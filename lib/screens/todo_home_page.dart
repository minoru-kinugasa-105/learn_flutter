import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../models/todo.dart';
import '../services/hive_service.dart';
import '../services/todo_service.dart';
import '../widgets/add_todo_dialog.dart';
import '../widgets/todo_list_widget.dart';
import '../widgets/deleted_todo_list_widget.dart';
import '../widgets/sidebar_widget.dart';

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<ScrollController> _scrollControllers;
  bool _isAppBarVisible = true;
  bool _isSidebarVisible = false;
  late AnimationController _sidebarAnimationController;
  late Animation<double> _sidebarAnimation;

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
    _scrollControllers = List.generate(3, (index) {
      final controller = ScrollController();
      controller.addListener(() => _onScrollChanged(controller));
      return controller;
    });

    // タブ切り替え時のリスナーを追加
    _tabController.addListener(_onTabChanged);

    // サイドバーアニメーションコントローラーを作成
    _sidebarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _sidebarAnimation = Tween<double>(begin: -280.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _sidebarAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onScrollChanged(ScrollController controller) {
    // スクロール位置に基づいてアプリバーの表示/非表示を制御
    final isScrolled = controller.offset > 100;
    if (isScrolled != !_isAppBarVisible) {
      setState(() {
        _isAppBarVisible = !isScrolled;
      });
    }
  }

  void _onTabChanged() {
    // タブが切り替わった時に、そのタブのスクロール位置を一番上に戻す
    if (_tabController.indexIsChanging) {
      setState(() {}); // タブの内容を更新

      final currentIndex = _tabController.index;
      final controller = _scrollControllers[currentIndex];

      // アプリバーを表示状態に戻す
      setState(() {
        _isAppBarVisible = true;
      });

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
    _sidebarAnimationController.dispose();
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

  /// サイドバーを表示するメソッド
  void _showSidebar() {
    setState(() {
      _isSidebarVisible = true;
    });
    _sidebarAnimationController.forward();
  }

  /// サイドバーを非表示にするメソッド
  void _hideSidebar() {
    _sidebarAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isSidebarVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!HiveService.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          // メインコンテンツ
          TabBarView(
            controller: _tabController,
            children: [
              // 未完了タブ
              CustomScrollView(
                controller: _scrollControllers[0],
                slivers: [
                  // アプリバーの高さ分のスペースを追加
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height:
                          MediaQuery.of(context).padding.top +
                          kToolbarHeight +
                          kTextTabBarHeight,
                    ),
                  ),
                  TodoListWidget(
                    tabIndex: 0,
                    onUpdateTodo: _updateTodo,
                    onCopyTodo: _copyTodo,
                    onEditTodo: _editTodo,
                  ),
                ],
              ),
              // 完了済みタブ
              CustomScrollView(
                controller: _scrollControllers[1],
                slivers: [
                  // アプリバーの高さ分のスペースを追加
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height:
                          MediaQuery.of(context).padding.top +
                          kToolbarHeight +
                          kTextTabBarHeight,
                    ),
                  ),
                  TodoListWidget(
                    tabIndex: 1,
                    onUpdateTodo: _updateTodo,
                    onCopyTodo: _copyTodo,
                    onEditTodo: _editTodo,
                  ),
                ],
              ),
              // 削除済みタブ
              CustomScrollView(
                controller: _scrollControllers[2],
                slivers: [
                  // アプリバーの高さ分のスペースを追加
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height:
                          MediaQuery.of(context).padding.top +
                          kToolbarHeight +
                          kTextTabBarHeight,
                    ),
                  ),
                  DeletedTodoListWidget(
                    onUpdateTodo: _updateTodo,
                    onCopyTodo: _copyTodo,
                    onEditTodo: _editTodo,
                  ),
                ],
              ),
            ],
          ),

          // 左端スワイプ検出用のオーバーレイ
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 50, // 左端から50pxの幅でスワイプを検出
            child: RawGestureDetector(
              gestures: <Type, GestureRecognizerFactory>{
                PanGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<
                      PanGestureRecognizer
                    >(() => PanGestureRecognizer(), (
                      PanGestureRecognizer instance,
                    ) {
                      instance.onStart = (details) {
                        print(
                          'RawGestureDetector: スワイプ開始: x=${details.globalPosition.dx}',
                        ); // デバッグ用ログ
                      };
                      instance.onUpdate = (details) {
                        print(
                          'RawGestureDetector: スワイプ中: delta=${details.delta.dx}',
                        ); // デバッグ用ログ
                        if (details.delta.dx > 10) {
                          // 10px以上右に移動したら
                          print('RawGestureDetector: 右方向へのスワイプを検出'); // デバッグ用ログ
                          _showSidebar();
                        }
                      };
                      instance.onEnd = (details) {
                        print(
                          'RawGestureDetector: スワイプ終了: velocity=${details.velocity.pixelsPerSecond.dx}',
                        ); // デバッグ用ログ
                        if (details.velocity.pixelsPerSecond.dx > 0) {
                          _showSidebar();
                        }
                      };
                    }),
                TapGestureRecognizer:
                    GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
                      () => TapGestureRecognizer(),
                      (TapGestureRecognizer instance) {
                        instance.onTap = () {
                          print('RawGestureDetector: 左端エリアをタップしました'); // デバッグ用ログ
                          _showSidebar();
                        };
                      },
                    ),
              },
              child: Container(color: Colors.transparent, width: 50),
            ),
          ),

          // アプリバー（固定）
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: _isAppBarVisible ? 0 : -kToolbarHeight - kTextTabBarHeight,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ステータスバーの高さ分のスペース
                  SizedBox(height: MediaQuery.of(context).padding.top),
                  // アプリバー
                  Container(
                    height: kToolbarHeight,
                    color: Colors.white,
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        IconButton(
                          onPressed: _showSidebar,
                          icon: const Icon(Icons.menu, color: Colors.black87),
                        ),
                        const Expanded(
                          child: Text(
                            'Todo App',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                  // タブバー
                  Container(
                    height: kTextTabBarHeight,
                    color: Colors.white,
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: const [
                        Tab(text: '未完了'),
                        Tab(text: '完了済み'),
                        Tab(text: '削除済み'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // サイドバーオーバーレイ（背景の暗い部分）
          if (_isSidebarVisible)
            GestureDetector(
              onTap: _hideSidebar,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: double.infinity,
                height: double.infinity,
              ),
            ),

          // サイドバー
          if (_isSidebarVisible)
            AnimatedBuilder(
              animation: _sidebarAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_sidebarAnimation.value, 0),
                  child: SidebarWidget(onClose: _hideSidebar),
                );
              },
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
