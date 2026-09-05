import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // The key comes from Info.plist, which is populated by Secrets.xcconfig —
    // an untracked file. v1 hardcoded it here, so it leaked into git history.
    if let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String,
       !key.isEmpty, key != "$(MAPS_API_KEY)" {
      GMSServices.provideAPIKey(key)
    } else {
      NSLog("[ErbilCafe] No Maps API key configured — copy ios/Flutter/Secrets.example.xcconfig to Secrets.xcconfig and set MAPS_API_KEY.")
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
