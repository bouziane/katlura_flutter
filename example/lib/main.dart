import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:katlura_flutter/katlura_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _katluraFlutterPlugin = KatluraFlutter();
  MethodChannel? _platformChannel;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _katluraFlutterPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            KatluraPlayer(
              videoId: "1_n2tme8u4",
              onPlatformViewCreated: (id) {
                _platformChannel = MethodChannel('katlura_flutter_$id');
              },
              onPlayerStateChanged: (String value) {
                print(value);
              },
            ),
            Positioned(
                bottom: 32.0,
                child: Row(
                  children: [
                    FloatingActionButton(
                      onPressed: _playVideo,
                      child: const Icon(Icons.play_arrow),
                    ),
                    FloatingActionButton(
                      onPressed: _pauseVideo,
                      child: const Icon(Icons.pause),
                    )
                  ],
                ))
          ],
        ),
      ),
    );
  }

  void _playVideo() async {
    await _platformChannel?.invokeMethod('playVideo');
  }

  void _pauseVideo() async {
    await _platformChannel?.invokeMethod('pauseVideo');
  }
}
