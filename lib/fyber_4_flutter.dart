import 'dart:async';

import 'package:flutter/services.dart';

class Fyber4Flutter {
  static const MethodChannel _channel = const MethodChannel('fyber_4_flutter');

  static const EventChannel _stream =
      const EventChannel('fyber_4_flutter/eventStream');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> startFyber({
    String appId,
    String securityToken,
    String user,
    bool enableLogging = false,
  }) async {
    assert(appId != null);
    assert(securityToken != null);
    return await _channel.invokeMethod("startFyber", {
      "appId": appId,
      "securityToken": securityToken,
      "user": user,
      "loggingEnabled": enableLogging ? "true" : "false",
    }) as bool;
  }

  static Future<bool> get sdkReady {
    return _stream
        .receiveBroadcastStream()
        .where((event) => "started" == event)
        .map((event) => true)
        .firstWhere((value) => value);
  }

  static Future<String> showAd(AdTypes type) async {
    return await _channel.invokeMethod("showAdvertisement", {
      "type": _toString(type),
    });
  }
}

enum AdTypes { offerwall, rewarded, interstitial }

String _toString(AdTypes type) {
  switch (type) {
    case AdTypes.offerwall:
      return "offerwall";
    case AdTypes.interstitial:
      return "interstitial";
    case AdTypes.rewarded:
      return "rewarded";
  }
}
