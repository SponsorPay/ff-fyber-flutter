import 'dart:async';

import 'package:flutter/services.dart';

class Fyber4Flutter {
  static const MethodChannel _channel = const MethodChannel('fyber_4_flutter');

  static const EventChannel _stream =
      const EventChannel('fyber_4_flutter/eventStream');

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

  static Stream<dynamic> _cached;

  static Stream<dynamic> _getEventsFromChannel() {
    if (_cached == null) {
      _cached = _stream.receiveBroadcastStream();
    }
    return _cached;
  }

  static Future<bool> get sdkReady {
    return _getEventsFromChannel()
        .where((event) => "started" == event)
        .map((event) => true)
        .firstWhere((value) => value);
  }

  static Future<String> showAd(AdTypes type) async {
    return await _channel.invokeMethod("showAdvertisement", {
      "type": _toString(type),
    });
  }

  static Stream<EngagementEvent> get engagementResults {
    return _getEventsFromChannel()
        .where((event) => event is Map)
        .cast<Map>()
        .map((map) {
      final String result = map["result"];
      final String code = map["code"];
      return new EngagementEvent(
          _fromString(result), _fromCode(int.parse(code)));
    });
  }

  static Future<String> showOfferwall({bool closeOnRedirect = false}) async {
    return await _channel.invokeMethod("showAdvertisement", {
      "type": _toString(AdTypes.offerwall),
      "closeOnRedirect": "$closeOnRedirect",
    });
  }

  static Future<String> showInterstitial() => showAd(AdTypes.interstitial);

  static Future<String> showRewardedVideo(
      {bool notifyOnCompletion = true}) async {
    return await _channel.invokeMethod("showAdvertisement", {
      "type": _toString(AdTypes.rewarded),
      "notifyOnCompletion": "$notifyOnCompletion",
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

const _REWARDED_REQUEST_CODE = 0x888000;
const _OFFERWALL_REQUEST_CODE = 0x888001;
const _INTERSTITIAL_REQUEST_CODE = 0x888002;

AdTypes _fromCode(int code) {
  switch (code) {
    case _REWARDED_REQUEST_CODE:
      return AdTypes.rewarded;
    case _INTERSTITIAL_REQUEST_CODE:
      return AdTypes.interstitial;
    case _OFFERWALL_REQUEST_CODE:
      return AdTypes.offerwall;
    default:
      return null;
  }
}

enum EngagementResult { finished, aborted, error }

EngagementResult _fromString(String engagement) {
  switch (engagement.toLowerCase()) {
    case "finished":
      return EngagementResult.finished;
    case "aborted":
      return EngagementResult.aborted;
    case "error":
      return EngagementResult.error;
    default:
      return null;
  }
}

class EngagementEvent {
  final EngagementResult result;
  final AdTypes type;

  const EngagementEvent(this.result, this.type)
      : assert(result != null),
        assert(type != null);

  @override
  String toString() {
    return 'EngagementEvent{result: $result, type: $type}';
  }
}
