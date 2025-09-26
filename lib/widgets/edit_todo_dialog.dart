import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';
import 'time_picker_widget.dart';

class EditTodoDialog {
  /// Todo編集ダイアログを表示
  static Future<bool?> show(
    BuildContext context,
    Todo todo,
    Function(String title, String? description, DateTime? dueTime) onEdit,
  ) async {
    final titleController = TextEditingController(text: todo.title);
    final descriptionController = TextEditingController(
      text: todo.description ?? '',
    );
    DateTime? selectedDateTime = todo.dueTime;
    String dueType = todo.dueTime == null
        ? 'none'
        : 'custom'; // 'none', 'today', 'tomorrow', 'custom'

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
                      'タスクを編集',
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
                      child: const Text('保存'),
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
                                : '期限: ${TodoService.formatDateTime(selectedDateTime!)}',
                          ),
                          trailing: const Icon(Icons.access_time),
                          onTap: () async {
                            final time =
                                await TimePickerWidget.showTodayTimePicker(
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
                                : '期限: ${TodoService.formatDateTime(selectedDateTime!)}',
                          ),
                          trailing: const Icon(Icons.access_time),
                          onTap: () async {
                            final tomorrow = DateTime.now().add(
                              const Duration(days: 1),
                            );
                            final time =
                                await TimePickerWidget.showTomorrowTimePicker(
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
                                : '期限: ${TodoService.formatDateTime(selectedDateTime!)}',
                          ),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedDateTime ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (date != null) {
                              final time =
                                  await TimePickerWidget.showTimePicker(
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
                            '期限: ${TodoService.formatDateTime(selectedDateTime!)}',
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
      onEdit(
        titleController.text.trim(),
        descriptionController.text.trim().isEmpty
            ? null
            : descriptionController.text.trim(),
        selectedDateTime,
      );
    }

    return result;
  }
}
