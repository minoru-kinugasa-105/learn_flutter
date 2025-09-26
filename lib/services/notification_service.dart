import 'dart:async';
import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/todo.dart';
import 'hive_service.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static Timer? _periodicTimer;

  /// 通知サービスを初期化する
  static Future<void> initialize() async {
    // タイムゾーンデータを初期化
    tz.initializeTimeZones();

    // Android初期化設定
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS初期化設定
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // 定期的な励まし通知を開始
    _startPeriodicNotifications();
  }

  /// 期限30分前の即時通知をスケジュールする
  static Future<void> scheduleTodoNotification(Todo todo) async {
    if (todo.dueTime == null || todo.isCompleted || todo.isNotificationSent) {
      return;
    }

    final now = DateTime.now();
    final notificationTime = todo.dueTime!.subtract(
      const Duration(minutes: 30),
    );

    // 通知時間が過去の場合はスケジュールしない
    if (notificationTime.isBefore(now)) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'todo_reminder',
      'Todo Reminder',
      channelDescription: '期限30分前のTodo通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      todo.key as int, // Hiveのキーを通知IDとして使用
      '${todo.title} はもうやりましたか？',
      '期限まで30分です。早めに取り掛かりましょう！',
      tz.TZDateTime.from(notificationTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 通知済みフラグを更新する
  static Future<void> markNotificationSent(Todo todo) async {
    todo.isNotificationSent = true;
    await todo.save();
  }

  /// 定期的な励まし通知を開始する
  static void _startPeriodicNotifications() {
    _periodicTimer?.cancel();

    // 10分間隔で励まし通知を送信
    _periodicTimer = Timer.periodic(const Duration(minutes: 60), (timer) {
      _sendEncouragementNotification();
    });
  }

  /// 励まし通知を送信する
  static Future<void> _sendEncouragementNotification() async {
    final messages = [
      'タスクのやり忘れはありませんか？',
      'たまには息抜きしましょう',
      '早めに終わらせるのも一つの戦法です！',
      '今日もお疲れ様です！',
      '一歩ずつ進んでいきましょう',
      '集中力が続かない時は休憩も大切です',
      '小さな進歩も大きな成果につながります',
    ];

    final random = Random();
    final message = messages[random.nextInt(messages.length)];

    const androidDetails = AndroidNotificationDetails(
      'encouragement',
      'Encouragement',
      channelDescription: '励ましのメッセージ',
      importance: Importance.low,
      priority: Priority.low,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // ユニークなID
      'Todo App',
      message,
      details,
    );
  }

  /// 完了したTodoの通知をキャンセルする
  static Future<void> cancelTodoNotification(Todo todo) async {
    await _notifications.cancel(todo.key as int);
  }

  /// すべての通知をキャンセルする
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// 期限が近いTodoの通知をチェックして送信する
  static Future<void> checkAndScheduleNotifications() async {
    final allTodos = HiveService.todoBox.values.toList();

    for (final todo in allTodos) {
      if (!todo.isCompleted &&
          !todo.isDeleted &&
          !todo.isNotificationSent &&
          todo.dueTime != null) {
        await scheduleTodoNotification(todo);
      }
    }
  }

  /// 通知サービスを停止する
  static void dispose() {
    _periodicTimer?.cancel();
  }
}
