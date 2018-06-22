package com.fyber.flutter.fyber4flutter

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.util.Log
import com.fyber.Fyber
import com.fyber.ads.AdFormat
import com.fyber.requesters.*
import com.fyber.utils.FyberLogger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

class Fyber4FlutterPlugin(registrar: Registrar, val channel: MethodChannel) : MethodCallHandler, EventChannel.StreamHandler {

    companion object {
        private const val TAG = "Fyber4Flutter"
        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val channel = MethodChannel(registrar.messenger(), "fyber_4_flutter")
            val eventStream = EventChannel(registrar.messenger(), "fyber_4_flutter/eventStream")
            val plugin = Fyber4FlutterPlugin(registrar, channel)
            channel.setMethodCallHandler(plugin)
            eventStream.setStreamHandler(plugin)
        }
    }

    val activity: Activity = registrar.activity()
    val context: Context = registrar.context()

    private var settings: Fyber.Settings? = null

    override fun onMethodCall(call: MethodCall, result: Result): Unit {
        Log.d(TAG, "${call.method} method called with arguments: ${call.arguments}")
        when (call.method) {
            "startFyber" -> {
                val arguments = call.arguments as Map<String, String>
                val appId = arguments["appId"]!!
                val securityToken = arguments["securityToken"]!!
                val user = arguments["user"]
                val loggingEnabled = arguments["loggingEnabled"]

                var fyber = Fyber.with(appId, this.activity)
                        .withSecurityToken(securityToken);
                user?.let {
                    fyber = fyber.withUserId(it)
                }
                FyberLogger.enableLogging("true" == loggingEnabled)

                this.settings = fyber.start()
                Log.d(TAG, "Fyber SDK started: $settings")
                result.success(this.settings != null)
                sendEvent("started")

            }
            "showAdvertisement" -> {
                val arguments = call.arguments as Map<String, String>
                val adType = arguments["type"]
                adType?.let {
                    val requestCallback: RequestCallback = CustomRequestCallback(result, context)
                    when (it) {
                        "offerwall" -> {
                            Log.d(TAG, "requesting for OfferWall")

                            OfferWallRequester.create(requestCallback).request(context)
                        }
                        "interstitial" -> {
                            Log.d(TAG, "requesting for Interstitial")
                            InterstitialRequester.create(requestCallback).request(context)
                        }
                        "rewarded" -> {
                            Log.d(TAG, "requesting for Rewarded Video")
                            RewardedVideoRequester.create(requestCallback).request(context)
                        }
                        else -> {
                            Log.e(TAG, "Unrecognized ad type: $it")
                            result.error("AD_TYPE_INVALID", "The ad type of $it is " +
                                    "invalid", null)
                        }
                    }

                }
                if (adType == null) {
                    result.error("AD_TYPE_MISSING", "Empty `type` attribute", null)
                }
            }
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(p0: Any?, p1: EventChannel.EventSink?) {
        eventSink = p1
    }

    override fun onCancel(p0: Any?) {
        eventSink = null
    }

    private fun sendEvent(event: Any): Boolean {
        return eventSink?.let {
            it.success(event)
            true
        } ?: false
    }

    class CustomRequestCallback(private val result: Result, private val context: Context) : RequestCallback {
        override fun onAdAvailable(p0: Intent?) {
            Log.d(TAG, "onAdAvailable: ${p0?.component}")
            p0?.let {
                context.startActivity(it.apply {
                    it.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                })
                result.success("fill")
            }
        }

        override fun onAdNotAvailable(p0: AdFormat?) {
            Log.d(TAG, "onAdNotAvailable: $p0")
            result.success("no-fill")
        }

        override fun onRequestError(p0: RequestError?) {
            Log.d(TAG, "onRequestError: $p0")
            result.success("error")
        }

    }
}
