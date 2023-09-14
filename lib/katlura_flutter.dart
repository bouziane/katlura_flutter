import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'katlura_flutter_platform_interface.dart';

class KatluraFlutter {
  Future<String?> getPlatformVersion() {
    return KatluraFlutterPlatform.instance.getPlatformVersion();
  }
}

class KatluraPlayer extends StatelessWidget {
  final String videoId;
  final Function(int id) onPlatformViewCreated;
  final ValueChanged<String> onPlayerStateChanged;

  KatluraPlayer(
      {required this.onPlatformViewCreated,
      required this.onPlayerStateChanged,
      required this.videoId});

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return PlatformViewLink(
        viewType: 'katlura_player',
        surfaceFactory:
            (BuildContext context, PlatformViewController controller) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          return PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            creationParams: <String, dynamic>{'videoId': videoId},
            creationParamsCodec: StandardMessageCodec(),
            viewType: 'katlura_player',
            layoutDirection: TextDirection.ltr,
          )
            ..addOnPlatformViewCreatedListener(onPlatformViewCreated)
            ..create();
        },
      );
    } else if (Platform.isIOS) {
      print("Video ID: $videoId");

      return UiKitView(
        viewType: 'katlura_player_ios',
        creationParams: <String, dynamic>{'videoId': videoId},
        creationParamsCodec: StandardMessageCodec(),
        onPlatformViewCreated: (int id) {
          onPlatformViewCreated(id);
        },
      );
    } else {
      return Text("Platform not supported");
    }
  }
}
