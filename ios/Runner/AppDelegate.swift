import UIKit
import Flutter
import GoogleMaps
//import background_locator
import workmanager
import shared_preferences


//
//func registerPlugins(registry: FlutterPluginRegistry) -> () {
//    if (!registry.hasPlugin("BackgroundLocatorPlugin")) {
//        GeneratedPluginRegistrant.register(with: registry)
//    }
//}

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
        
    WorkmanagerPlugin.register(with: self.registrar(forPlugin: "be.tramckrijte.workmanager.WorkmanagerPlugin") as! FlutterPluginRegistrar)
        
        UNUserNotificationCenter.current().delegate = self

        UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
    GMSServices.provideAPIKey("AIzaSyAhTmOCHZSiX3-HVqd0oCkX--Qv-QS7Mqg")

        
        WorkmanagerPlugin.setPluginRegistrantCallback { registry in
            AppDelegate.registerPlugins(with: registry)
            FLTSharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin") as! FlutterPluginRegistrar)
            
           
               
        }
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
      
  }
    static func registerPlugins(with registry: FlutterPluginRegistry) {
                 GeneratedPluginRegistrant.register(with: registry)
            }
         
      override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
           completionHandler(.alert)
       }
//  func registerOtherPlugins() {
//      if !hasPlugin("com.tekartik.sqflite.SqflitePlugin") {
//        print("Plugin is available")
//          //SqflitePlugin.register(with : registry.registrar(forPlugin: "com.tekartik.sqflite.SqflitePlugin"))
//      }else{
//        print("Plugin is not available")
//      }
//  }

}

