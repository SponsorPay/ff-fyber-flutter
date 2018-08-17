import 'package:flutter/material.dart';
import 'package:fyber_4_flutter/offerwall.dart';

class OfferwallPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Offerwall(
      apiKey: "1c915e3b5d42d05136185030892fbb846c278927",
      appId: "2070",
      userId: "superman",
      googleAdId: "a0b0c0d0-a0b0-c0d0-e0f0-a0b0c0d0e0f0",
      googleAdIdLimitedTrackingEnabled: false,
      osVersion: "x86_64",
    );
  }
}
