import 'package:flutter/material.dart';
import 'services/hive_service.dart';
import 'services/notification_service.dart';
import 'screens/todo_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initialize();
  await NotificationService.initialize();
  // 既存のTodoの通知をチェックしてスケジュール
  await NotificationService.checkAndScheduleNotifications();
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
