package com.fyber.flutter.fyber4flutterexample

import android.os.Bundle
import com.fyber.annotations.FyberSDK

import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant

@FyberSDK
class MainActivity(): FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
  }
}
