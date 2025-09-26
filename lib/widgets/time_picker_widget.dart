import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TimePickerWidget {
  /// 今日用の時間選択ピッカーを表示
  static Future<DateTime?> showTodayTimePicker(
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

  /// 明日用の時間選択ピッカーを表示
  static Future<DateTime?> showTomorrowTimePicker(
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

  /// iPhoneスタイルの時間選択ピッカーを表示
  static Future<DateTime?> showTimePicker(
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
}
