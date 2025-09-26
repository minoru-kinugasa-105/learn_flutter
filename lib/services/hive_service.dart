import 'package:hive_flutter/hive_flutter.dart';
import '../models/todo.dart';

class HiveService {
  static Box<Todo>? _todoBox;

  /// Hiveを初期化し、Todoボックスを開く
  static Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TodoAdapter());
    _todoBox = await Hive.openBox<Todo>('todos');
  }

  /// Todoボックスを取得する
  static Box<Todo> get todoBox {
    if (_todoBox == null) {
      throw Exception(
        'HiveService is not initialized. Call initialize() first.',
      );
    }
    return _todoBox!;
  }

  /// ボックスが開かれているかチェック
  static bool get isInitialized => _todoBox != null;
}
