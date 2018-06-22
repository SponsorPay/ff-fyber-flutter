import 'dart:async';

import 'package:flutter/services.dart';

class Fyber4Flutter {
  static const MethodChannel _channel =
      const MethodChannel('fyber_4_flutter');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
