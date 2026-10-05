package ecom.furqanbook.com

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // 03/10 (Lalit point 2 — "download ki jgha abhi share ho raha hai"):
    // invoice ko PUBLIC Downloads folder me ASLI save — share-sheet nahi.
    // Android 10+ (API 29) par MediaStore Downloads ko koi runtime
    // permission NAHI chahiye. Purane Android (minSdk 26-28) par app
    // Dart side par share-sheet fallback karti hai (data-loss nahi).
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "alfurqan/downloads")
            .setMethodCallHandler { call, result ->
                if (call.method != "saveToDownloads") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val bytes = call.argument<ByteArray>("bytes")
                val name = call.argument<String>("name") ?: "download"
                val mime = call.argument<String>("mime") ?: "application/octet-stream"
                if (bytes == null) {
                    result.error("NO_BYTES", "bytes argument missing", null)
                    return@setMethodCallHandler
                }
                if (Build.VERSION.SDK_INT < 29) {
                    result.error("UNSUPPORTED", "public Downloads needs Android 10+", null)
                    return@setMethodCallHandler
                }
                try {
                    val values = ContentValues().apply {
                        put(MediaStore.Downloads.DISPLAY_NAME, name)
                        put(MediaStore.Downloads.MIME_TYPE, mime)
                        put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                    }
                    val resolver = applicationContext.contentResolver
                    val uri = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                    if (uri == null) {
                        result.error("INSERT_FAIL", "media store uri null", null)
                    } else {
                        val out = resolver.openOutputStream(uri)
                        if (out == null) {
                            result.error("STREAM_FAIL", "output stream null", null)
                        } else {
                            out.use { it.write(bytes) }
                            result.success(name)
                        }
                    }
                } catch (e: Exception) {
                    result.error("SAVE_FAIL", e.message, null)
                }
            }
    }
}
