package com.erbil.erbilcafe

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "erbilcafe/platform_config",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                // Dart asks before it builds a map. Without a key the Maps SDK
                // renders a permanently blank tile and logs an authorisation
                // failure, so the app shows a fallback instead.
                "mapsConfigured" -> result.success(hasMapsKey())
                else -> result.notImplemented()
            }
        }
    }

    private fun hasMapsKey(): Boolean = try {
        val info = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
        val key = info.metaData?.getString("com.google.android.geo.API_KEY").orEmpty()
        key.isNotBlank()
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }
}
