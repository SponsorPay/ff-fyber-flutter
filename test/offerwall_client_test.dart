import 'package:fyber_4_flutter/offerwall.dart';
import 'package:test/test.dart';

void main() {
  test(
    "Check if request is successfully performed",
    () async {
      OfferwallRestApiClient client = OfferwallRestApiClient(
          "1c915e3b5d42d05136185030892fbb846c278927",
          "2070",
          "superman",
          "de",
          "x86_64",
          "a0b0c0d0-a0b0-c0d0-e0f0-a0b0c0d0e0f0",
          false);
      final response = await client.getOffers();
      expect(response.code, "OK");
      print(response);
    },
    timeout: Timeout(Duration(seconds: 15)),
  );
}
