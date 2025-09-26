import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class SidebarWidget extends StatelessWidget {
  final VoidCallback onClose;

  const SidebarWidget({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // ヘッダー部分
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Colors.blue, size: 30),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Flutter学習',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '実験機能メニュー',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // メニュー項目
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.music_note,
                  title: '音声のバックグラウンド再生',
                  subtitle: '音楽をバックグラウンドで再生',
                  onTap: () {
                    _showAudioControlDialog(context);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.notifications,
                  title: '10秒後に通知を送る',
                  subtitle: 'タイマー通知機能',
                  onTap: () {
                    _showComingSoon(context, '10秒後に通知を送る');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.login,
                  title: 'ログイン',
                  subtitle: '基本的なログイン機能',
                  onTap: () {
                    _showComingSoon(context, 'ログイン');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.login,
                  title: 'ログイン（Google）',
                  subtitle: 'Googleアカウントでログイン',
                  onTap: () {
                    _showComingSoon(context, 'ログイン（Google）');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.camera_alt,
                  title: 'カメラでぱしゃり',
                  subtitle: 'カメラで写真を撮影',
                  onTap: () {
                    _showComingSoon(context, 'カメラでぱしゃり');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.photo_library,
                  title: '写真',
                  subtitle: 'ギャラリーから写真を選択',
                  onTap: () {
                    _showComingSoon(context, '写真');
                  },
                ),
              ],
            ),
          ),

          // フッター
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Flutter学習用アプリ v1.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        hoverColor: Colors.blue.withOpacity(0.05),
      ),
    );
  }

  void _showAudioControlDialog(BuildContext context) {
    final audioService = AudioService();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.music_note, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(child: Text('音声のバックグラウンド再生')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'mrs.mp3を無限ループでバックグラウンド再生します。',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await audioService.startBackgroundPlayback();
                        setState(() {});
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('音声のバックグラウンド再生を開始しました'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('エラー: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('再生開始'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await audioService.stopPlayback();
                        setState(() {});
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('音声の再生を停止しました'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('エラー: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('停止'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '状態: ${audioService.isPlaying ? "再生中" : "停止中"}',
                style: TextStyle(
                  color: audioService.isPlaying ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('閉じる'),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String featureName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('準備中'),
        content: Text('「$featureName」機能は現在開発中です。\n近日中に実装予定です！'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
