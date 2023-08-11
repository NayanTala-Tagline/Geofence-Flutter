package com.example.geofence_demo

import com.tekartik.sqflite.SqflitePlugin
import com.transistorsoft.flutter.backgroundfetch.BackgroundFetchPlugin
import io.flutter.app.FlutterApplication
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin
import io.flutter.view.FlutterMain

//class Application : FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
//     override fun onCreate() {
//         super.onCreate()
//
//         // background_locator plugin configuration
//         FlutterMain.startInitialization(this)
//
//        // Background Fetch plugin configuration
//        BackgroundFetchPlugin.setPluginRegistrant(this)
//
//
//         //IsolateHolderService.setPluginRegistrant(this)
//     }
//
//     override fun registerWith(registry: PluginRegistry?) {
//         GeneratedPluginRegistrant.registerWith(FlutterEngine(this))
//         if (!registry!!.hasPlugin("com.tekartik.sqflite.SqflitePlugin")) {
//             SqflitePlugin.registerWith(registry.registrarFor("com.tekartik.sqflite.SqflitePlugin"))
//         }
//
//         if (!registry.hasPlugin("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin")) {
//             SharedPreferencesPlugin.registerWith(registry.registrarFor("io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin"))
//         }
//     }
// }

class Application : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
    }
}