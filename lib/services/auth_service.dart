import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

class AuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  /// 生体認証が利用可能かチェック
  static Future<bool> isBiometricAvailable() async {
    try {
      final bool isAvailable = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// 利用可能な生体認証の種類を取得
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// FaceID認証を実行
  static Future<bool> authenticateWithFaceID() async {
    try {
      // 生体認証が利用可能かチェック
      final bool isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        return false;
      }

      // 利用可能な生体認証の種類をチェック
      final List<BiometricType> availableBiometrics =
          await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return false;
      }

      // 認証を実行
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: '削除済みタスクを閲覧するために認証が必要です',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      print('認証エラー: ${e.message}');
      return false;
    } catch (e) {
      print('予期しないエラー: $e');
      return false;
    }
  }

  /// 認証が必要かどうかをチェック（削除済みタブ用）
  static Future<bool> shouldRequireAuth() async {
    // 生体認証が利用可能な場合のみ認証を要求
    return await isBiometricAvailable();
  }
}
