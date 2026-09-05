import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// Whether a Maps key was supplied at build time.
  ///
  /// Dart asks before it builds a map. Without this the Google Maps SDK raises
  /// an uncaught Objective-C exception the moment a map view is created, which
  /// takes the whole app down — there is no way to catch that from Dart.
  private var mapsConfigured = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // The key comes from Info.plist, populated by the untracked
    // Flutter/Secrets.xcconfig. v1 hardcoded it here, so it leaked into git.
    let key = Bundle.main.object(forInfoDictionaryKey: "GMSApiKey") as? String ?? ""
    let resolved = key.trimmingCharacters(in: .whitespacesAndNewlines)

    if !resolved.isEmpty && resolved != "$(MAPS_API_KEY)" {
      GMSServices.provideAPIKey(resolved)
      mapsConfigured = true
    } else {
      NSLog("[ErbilCafe] No Maps API key. Copy ios/Flutter/Secrets.example.xcconfig "
        + "to Secrets.xcconfig and set MAPS_API_KEY. The Map tab will show a fallback.")
    }

    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      // Apple's Liquid Glass material, which Flutter itself does not expose.
      registrar(forPlugin: "LiquidGlass")?.register(
        LiquidGlassViewFactory(messenger: controller.binaryMessenger),
        withId: "erbilcafe/liquid_glass"
      )

      FlutterMethodChannel(
        name: "erbilcafe/platform_config",
        binaryMessenger: controller.binaryMessenger
      ).setMethodCallHandler { [weak self] call, result in
        switch call.method {
        case "mapsConfigured":
          result(self?.mapsConfigured ?? false)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
