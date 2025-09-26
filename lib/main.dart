import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _counter = 0; // カウンターの値を保持する変数
  int _delayingCounter = 0;

  // 非同期処理としてカウンターを増やすメソッド
  Future<void> _incrementCounter() async {
    // 500ミリ秒の遅延を作成
    setState(() {
      _delayingCounter++;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      // setStateを呼び出すことで、UIが更新される
      _counter++;
      _delayingCounter--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Flutter初めて')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('ボタンを押した回数:'),
              Text(
                '$_delayingCounter : $_counter', // カウンターの値を表示
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20), // スペースを追加
              ElevatedButton(
                onPressed: _incrementCounter, // ボタンが押されたらカウンターを増やす
                child: const Text('カウントアップ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
