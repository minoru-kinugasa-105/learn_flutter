import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/todo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // TodoモデルをHiveに登録
  Hive.registerAdapter(TodoAdapter());
  await Hive.openBox<Todo>('todos');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoHomePage(),
    );
  }
}

class TodoHomePage extends StatefulWidget {
  const TodoHomePage({super.key});

  @override
  State<TodoHomePage> createState() => _TodoHomePageState();
}

class _TodoHomePageState extends State<TodoHomePage> {
  Box<Todo>? _todoBox;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    // ボックスが既に開かれているかチェック
    if (Hive.isBoxOpen('todos')) {
      _todoBox = Hive.box<Todo>('todos');
    } else {
      // ボックスが開かれていない場合は開く
      _todoBox = await Hive.openBox<Todo>('todos');
    }
    setState(() {});
  }

  // Todoを追加するメソッド
  Future<void> _addTodo() async {
    if (_todoBox == null) return;

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? selectedDateTime;
    String dueType = 'none'; // 'none', 'today', 'tomorrow', 'custom'

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ヘッダー
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('キャンセル'),
                    ),
                    const Text(
                      '新しいタスクを追加',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (titleController.text.trim().isNotEmpty) {
                          Navigator.of(context).pop(true);
                        }
                      },
                      child: const Text('追加'),
                    ),
                  ],
                ),
              ),
              // コンテンツ
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'タイトル',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: '説明（任意）',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      // 期限設定セクション
                      const Text(
                        '期限設定（任意）',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 期限タイプ選択
                      Column(
                        children: [
                          RadioListTile<String>(
                            title: const Text('期限なし'),
                            value: 'none',
                            groupValue: dueType,
                            onChanged: (value) {
                              setDialogState(() {
                                dueType = value!;
                                selectedDateTime = null;
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('今日中'),
                            value: 'today',
                            groupValue: dueType,
                            onChanged: (value) {
                              setDialogState(() {
                                dueType = value!;
                                selectedDateTime = DateTime.now().add(
                                  const Duration(hours: 1),
                                );
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('明日'),
                            value: 'tomorrow',
                            groupValue: dueType,
                            onChanged: (value) {
                              setDialogState(() {
                                dueType = value!;
                                final tomorrow = DateTime.now().add(
                                  const Duration(days: 1),
                                );
                                selectedDateTime = DateTime(
                                  tomorrow.year,
                                  tomorrow.month,
                                  tomorrow.day,
                                  18,
                                  0,
                                );
                              });
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('カスタム'),
                            value: 'custom',
                            groupValue: dueType,
                            onChanged: (value) {
                              setDialogState(() {
                                dueType = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      // 期限詳細設定
                      if (dueType == 'today') ...[
                        const SizedBox(height: 12),
                        const Text('何時？', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        ListTile(
                          title: Text(
                            selectedDateTime == null
                                ? '時間を選択'
                                : '期限: ${_formatDateTime(selectedDateTime!)}',
                          ),
                          trailing: const Icon(Icons.access_time),
                          onTap: () async {
                            final time = await _showTodayTimePicker(
                              context,
                              selectedDateTime,
                            );
                            if (time != null) {
                              setDialogState(() {
                                selectedDateTime = time;
                              });
                            }
                          },
                        ),
                      ],
                      if (dueType == 'tomorrow') ...[
                        const SizedBox(height: 12),
                        const Text('何時？', style: TextStyle(fontSize: 14)),
                        const SizedBox(height: 8),
                        ListTile(
                          title: Text(
                            selectedDateTime == null
                                ? '時間を選択'
                                : '期限: ${_formatDateTime(selectedDateTime!)}',
                          ),
                          trailing: const Icon(Icons.access_time),
                          onTap: () async {
                            final tomorrow = DateTime.now().add(
                              const Duration(days: 1),
                            );
                            final time = await _showTomorrowTimePicker(
                              context,
                              tomorrow,
                              selectedDateTime,
                            );
                            if (time != null) {
                              setDialogState(() {
                                selectedDateTime = time;
                              });
                            }
                          },
                        ),
                      ],
                      if (dueType == 'custom') ...[
                        const SizedBox(height: 12),
                        ListTile(
                          title: Text(
                            selectedDateTime == null
                                ? '日付と時間を選択'
                                : '期限: ${_formatDateTime(selectedDateTime!)}',
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              final time = await _showTimePicker(
                                context,
                                date,
                                selectedDateTime,
                              );
                              if (time != null) {
                                setDialogState(() {
                                  selectedDateTime = time;
                                });
                              }
                            }
                          },
                        ),
                      ],
                      // 期限プレビュー
                      if (selectedDateTime != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Text(
                            '期限: ${_formatDateTime(selectedDateTime!)}',
                            style: TextStyle(
                              color: Colors.blue[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      // 下部の余白
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      final todo = Todo()
        ..title = titleController.text.trim()
        ..description = descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim()
        ..dueTime = selectedDateTime
        ..isCompleted = false
        ..isDeleted = false
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await _todoBox!.add(todo);
      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('タスクを追加しました')));
      }
    }
  }

  // Todoの状態を更新するメソッド
  Future<void> _updateTodo(
    Todo todo, {
    bool? isCompleted,
    bool? isDeleted,
  }) async {
    if (isCompleted != null) todo.isCompleted = isCompleted;
    if (isDeleted != null) todo.isDeleted = isDeleted;
    todo.updatedAt = DateTime.now();
    await todo.save();
    setState(() {});
  }

  // 今日用の時間選択ピッカーを表示
  Future<DateTime?> _showTodayTimePicker(
    BuildContext context,
    DateTime? currentDateTime,
  ) async {
    final now = DateTime.now();
    final startTime = now.add(const Duration(minutes: 1));
    int selectedHour = currentDateTime?.hour ?? startTime.hour;
    int selectedMinute = currentDateTime?.minute ?? startTime.minute;

    // 分を1分刻みに調整
    selectedMinute = (selectedMinute / 1).round() * 1;

    // 現在時刻より後の時間のみ表示するための計算
    final availableHours = <int>[];
    for (int hour = now.hour; hour <= 23; hour++) {
      availableHours.add(hour);
    }

    return await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                  const Text(
                    '何時？',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      final targetTime = DateTime(
                        now.year,
                        now.month,
                        now.day,
                        selectedHour,
                        selectedMinute,
                      );

                      // 現在時刻より後の時刻のみ許可
                      if (targetTime.isAfter(now)) {
                        Navigator.pop(context, targetTime);
                      }
                    },
                    child: const Text('完了'),
                  ),
                ],
              ),
            ),
            // ピッカー
            Expanded(
              child: Row(
                children: [
                  // 時間ピッカー
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        selectedHour = availableHours[index];
                      },
                      children: availableHours.map((hour) {
                        return Center(
                          child: Text(
                            '${hour.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(fontSize: 18),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const Text(
                    ':',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // 分ピッカー
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        selectedMinute = index; // 1分刻み
                      },
                      children: List.generate(60, (index) {
                        return Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 20),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 明日用の時間選択ピッカーを表示
  Future<DateTime?> _showTomorrowTimePicker(
    BuildContext context,
    DateTime tomorrow,
    DateTime? currentDateTime,
  ) async {
    int selectedHour = currentDateTime?.hour ?? 18;
    int selectedMinute = currentDateTime?.minute ?? 0;

    return await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                  const Text(
                    '何時？',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        DateTime(
                          tomorrow.year,
                          tomorrow.month,
                          tomorrow.day,
                          selectedHour,
                          selectedMinute,
                        ),
                      );
                    },
                    child: const Text('完了'),
                  ),
                ],
              ),
            ),
            // ピッカー
            Expanded(
              child: Row(
                children: [
                  // 時間ピッカー
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        selectedHour = index;
                      },
                      children: List.generate(24, (index) {
                        return Center(
                          child: Text(
                            '${index.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(fontSize: 18),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Text(
                    ':',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // 分ピッカー
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        selectedMinute = index; // 1分刻み
                      },
                      children: List.generate(60, (index) {
                        return Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 20),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // iPhoneスタイルの時間選択ピッカーを表示
  Future<DateTime?> _showTimePicker(
    BuildContext context,
    DateTime selectedDate,
    DateTime? currentDateTime,
  ) async {
    int selectedHour = currentDateTime?.hour ?? DateTime.now().hour;
    int selectedMinute = currentDateTime?.minute ?? 0;

    // 分を1分刻みに調整
    selectedMinute = (selectedMinute / 1).round() * 1;

    return await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 300,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ヘッダー
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                  const Text(
                    '時間を選択',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedHour,
                          selectedMinute,
                        ),
                      );
                    },
                    child: const Text('完了'),
                  ),
                ],
              ),
            ),
            // ピッカー
            Expanded(
              child: Row(
                children: [
                  // 時間ピッカー
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        selectedHour = index;
                      },
                      children: List.generate(24, (index) {
                        return Center(
                          child: Text(
                            '${index.toString()}',
                            style: const TextStyle(fontSize: 20),
                          ),
                        );
                      }),
                    ),
                  ),
                  const Text(
                    ':',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // 分ピッカー
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 50,
                      onSelectedItemChanged: (index) {
                        selectedMinute = index; // 1分刻み
                      },
                      children: List.generate(60, (index) {
                        return Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: const TextStyle(fontSize: 20),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 期限表示をフォーマットするメソッド
  String _formatDateTime(DateTime dateTime) {
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

  // フラグに応じてTodoを分類するメソッド
  List<Todo> _getTodosByStatus(int tabIndex) {
    if (_todoBox == null) return [];
    final allTodos = _todoBox!.values.toList();

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

  // Todoリストを表示するウィジェット
  Widget _buildTodoList(int tabIndex) {
    final todos = _getTodosByStatus(tabIndex);

    if (todos.isEmpty) {
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: todo.isCompleted ? Colors.grey : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todo.description != null && todo.description!.isNotEmpty)
                  Text(
                    todo.description!,
                    style: TextStyle(
                      color: todo.isCompleted ? Colors.grey : null,
                    ),
                  ),
                if (todo.dueTime != null)
                  Text(
                    '期限: ${_formatDateTime(todo.dueTime!)}',
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
                    onPressed: () => _updateTodo(todo, isCompleted: true),
                    tooltip: '完了にする',
                  ),
                if (tabIndex == 0 || tabIndex == 1) // 未完了または完了済みタブの場合
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _updateTodo(todo, isDeleted: true),
                    tooltip: '削除する',
                  ),
                if (tabIndex == 1) // 完了済みタブの場合
                  IconButton(
                    icon: const Icon(Icons.undo, color: Colors.blue),
                    onPressed: () => _updateTodo(todo, isCompleted: false),
                    tooltip: '未完了に戻す',
                  ),
                if (tabIndex == 2) // 削除済みタブの場合
                  IconButton(
                    icon: const Icon(Icons.restore, color: Colors.orange),
                    onPressed: () => _updateTodo(todo, isDeleted: false),
                    tooltip: '復元する',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_todoBox == null) {
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
        body: Stack(
          children: [
            TabBarView(
              children: [
                // 未完了タブ
                _buildTodoList(0),
                // 完了済みタブ
                _buildTodoList(1),
                // 削除済みタブ
                _buildTodoList(2),
              ],
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
