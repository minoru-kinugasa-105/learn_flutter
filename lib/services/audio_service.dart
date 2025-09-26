import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLooping = false;

  bool get isPlaying => _isPlaying;
  bool get isLooping => _isLooping;

  /// 音声ファイルを無限ループで再生開始
  Future<void> startBackgroundPlayback() async {
    try {
      if (_isPlaying) {
        await stopPlayback();
      }

      // アセットファイルのパス
      const String audioPath = 'audios/mrs.mp3';

      // 無限ループで再生
      await _audioPlayer.setSource(AssetSource(audioPath));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.resume();

      _isPlaying = true;
      _isLooping = true;

      if (kDebugMode) {
        print('音声のバックグラウンド再生を開始しました');
      }
    } catch (e) {
      if (kDebugMode) {
        print('音声再生エラー: $e');
      }
      rethrow;
    }
  }

  /// 音声再生を停止
  Future<void> stopPlayback() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _isLooping = false;

      if (kDebugMode) {
        print('音声の再生を停止しました');
      }
    } catch (e) {
      if (kDebugMode) {
        print('音声停止エラー: $e');
      }
      rethrow;
    }
  }

  /// 音声再生を一時停止
  Future<void> pausePlayback() async {
    try {
      await _audioPlayer.pause();
      _isPlaying = false;

      if (kDebugMode) {
        print('音声の再生を一時停止しました');
      }
    } catch (e) {
      if (kDebugMode) {
        print('音声一時停止エラー: $e');
      }
      rethrow;
    }
  }

  /// 音声再生を再開
  Future<void> resumePlayback() async {
    try {
      await _audioPlayer.resume();
      _isPlaying = true;

      if (kDebugMode) {
        print('音声の再生を再開しました');
      }
    } catch (e) {
      if (kDebugMode) {
        print('音声再開エラー: $e');
      }
      rethrow;
    }
  }

  /// 音量を設定（0.0 - 1.0）
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));

      if (kDebugMode) {
        print('音量を${(volume * 100).toInt()}%に設定しました');
      }
    } catch (e) {
      if (kDebugMode) {
        print('音量設定エラー: $e');
      }
      rethrow;
    }
  }

  /// リソースを解放
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
      _isPlaying = false;
      _isLooping = false;

      if (kDebugMode) {
        print('AudioServiceを破棄しました');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AudioService破棄エラー: $e');
      }
    }
  }
}
