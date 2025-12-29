package com.dhruvathaide.vanguard

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.dhruvathaide.vanguard/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "secure") {
                window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                result.success(null)
            } else if (call.method == "insecure") {
                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
