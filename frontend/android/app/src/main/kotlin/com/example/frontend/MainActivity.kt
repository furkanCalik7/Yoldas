package com.example.frontend


import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap
import com.hiennv.flutter_callkit_incoming.CallkitConstants
class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("test", "test")
        print("test")
        println("testln")
        val channel = MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger!!, "YOUR_CHANNEL_NAME")
        val appOpenedIntent = intent
        if (
            appOpenedIntent != null &&
            appOpenedIntent.action == "com.hiennv.flutter_callkit_incoming.ACTION_CALL_ACCEPT"
        ) {
            val extras = appOpenedIntent.extras
            if (extras != null) {
                Log.d("CALL_KIT", fromBundle((extras)).toString())
                channel!!.invokeMethod("CALL_ACCEPTED_INTENT", fromBundle(extras))
            }
        } else {
            channel!!.invokeMethod("CHAT_ACCEPTED_INTENT", null)
        }
    }

    private fun fromBundle(bundle: Bundle): HashMap<String, Any?> {
        var data: HashMap<String, Any?> = HashMap()
        val extra_callkit_data = bundle.getBundle("EXTRA_CALLKIT_CALL_DATA") ?: return data
        data =
            extra_callkit_data.getSerializable(CallkitConstants.EXTRA_CALLKIT_EXTRA)
                    as HashMap<String, Any?>
        return data
    }
}
