# SDKのインストール
brew install --cask flutter

# PATH
brew info flutter
>> /opt/homebrew/Caskroom/flutter/3.35.4 (3.9GB)

~/.zshrc
export PATH="$PATH:/opt/homebrew/Caskroom/flutter/3.35.4/bin"


# confirm
flutter --version
>> Flutter 3.35.4 • channel stable • https://github.com/flutter/flutter.git
>> Framework • revision d693b4b9db (10 days ago) • 2025-09-16 14:27:41 +0000
>> Engine • hash feee8ee8fb8b975dd9990f86d3bda11e6e75faf3 (revision c298091351) (11 days ago) • 2025-09-15 14:04:24.000Z
>> Tools • Dart 3.9.2 • DevTools 2.48.0




## 新規作成
    flutter create .
## 依存解決
    flutter pub get
## 追加
    flutter pub add name
## シュミレーター起動
    open -a Simulator
    flutter run -d uuid
## エミュレーターを起動
    flutter emulators --launch id
## 利用可能なシュミレーター一覧
    xcrun simctl list devices
## 利用可能なエミュレーター一覧
    flutter emulators
## CocoaPdosのインストール
    sudo gem install cocoapods

## Android SDKから直接リスト表示
    avdmanager list avd
## Android SDKから直接エミュレーター起動
    emulator -avd id
## Android SDKから直接接続中のデバイス確認
    adb devices

## 成形
    dart format .


### CocoaPods
| プラグイン                | 使える機能         |
| -------------------- | ------------- |
| `camera`             | カメラ撮影         |
| `path_provider`      | ファイルの保存場所取得   |
| `url_launcher`       | 外部アプリやブラウザを開く |
| `shared_preferences` | 永続的な設定保存      |
| `firebase_messaging` | プッシュ通知        |


## Androidシュミレーター起動
    open -a "Android Studio"
## Android SDKの確認(Software Development Kit)
    flutter doctor --android-licenses
    flutter doctor -v
### 見つからなければ
    flutter config --android-sdk /Users/SchoolAccount/Library/Android/sdk
### SDKがないならインストール
    bash -eu <<'SH'
    SDK_ROOT="$HOME/Library/Android/sdk"
    TMP="/tmp/android_cmdline"
    mkdir -p "$SDK_ROOT" "$TMP"
    cd "$TMP"
    curl -L -o commandlinetools.zip "https://dl.google.com/android/repository/commandlinetools-mac-9477386_latest.zip"
    unzip -o commandlinetools.zip -d "$TMP"
    mkdir -p "$SDK_ROOT/cmdline-tools/latest"
    mv "$TMP/cmdline-tools"/* "$SDK_ROOT/cmdline-tools/latest/" 2>/dev/null || true
    export PATH="$SDK_ROOT/cmdline-tools/latest/bin:$PATH"
    yes | sdkmanager --sdk_root="$SDK_ROOT" --licenses
    sdkmanager --sdk_root="$SDK_ROOT" "platform-tools" "platforms;android-34" "emulator"
    flutter config --android-sdk "$SDK_ROOT"
    echo "OK: Android SDK installed at $SDK_ROOT"
    SH







## シュミレーターは起動しているのにもかかわらずFlutterがデバイスを認識できていない問題
### Simulatorを完全に終了
osascript -e 'tell application "Simulator" to quit'
### Flutterキャッシュクリア
flutter clean
flutter doctor






## 実機テスト
iphone > 設定 > プライバシーとセキュリティ > デベロッパーモード > 許可して再起動

XCode開いて、settings開いて、accounts開いて、自分のAppleIDでログイン
open ios/Runner.xcworkspace 開いて、RunnerのSigning & CapabilitiesにあるTermを自分のIDにして、 identiferを com.自分の名前.flutterapp にでもしておく

そしたら
flutter devices
で出てきた実機のidをコピって
flutter run -d id
で実機にrun

一旦エラー吐くから、その状態で
iPhone > 設定 > 一般 > VPNとデバイス管理 > デベロッパアプリ
にある自分のメアドのやつを許可する、で自分自信を信頼したデベロッパにする

そうすると勝手にflutterのbuildとインストールが始まる