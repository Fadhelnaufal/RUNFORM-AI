package com.example.mobile_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.runform.ai/predict"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getPrediction") {
                val features = call.argument<List<Double>>("features")
                
                if (features != null) {
                    try {
                        // Memanggil fungsi predict() dari RunformPredictor.java
                        val prediction = RunformPredictor.predict(features.toDoubleArray())
                        result.success(prediction)
                    } catch (e: Exception) {
                        result.error("AI_ERROR", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGUMENT", "Data fitur kosong", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}