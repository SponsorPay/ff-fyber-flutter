import 'package:fyber_4_flutter/offerwall.dart';
import 'package:test/test.dart';

void main() {
  test('hashcode() should produce correct value', () {
    final hash = hashcode(params: {
      "appid": "47403",
      "uid": "player@1",
      "locale": "en",
      "os_version": "6.0.0",
      "ip": "212.45.111.17",
      "timestamp": "1471856286",
      "google_ad_id": "a0b0c0d0-a0b0-c0d0-e0f0-a0b0c0d0e0f0",
      "google_ad_id_limited_tracking_enabled": "true",
    }, apiKey: "5661dcc7c71ccf4fe05367dc65f1999b85e5fcbb");
    expect(hash, "a47ac173043ddf35980b95e549f4293ea40da0bd");
  });
}
