import Flutter
import UIKit

/// Apple's real Liquid Glass material, bridged to Flutter as a platform view.
///
/// Flutter has no Liquid Glass API on any channel — stable, beta or master —
/// so a Dart-side imitation is the only alternative, and it never matches the
/// system's refraction or its response to what is behind it. This hosts a
/// `UIVisualEffectView` running `UIGlassEffect`, which is the same material
/// UIKit uses for its own bars on iOS 26.
///
/// Content rendered *behind* a Flutter platform view lives in a real UIView
/// below it in the hierarchy, so the effect genuinely samples the app's own
/// scrolling content rather than a snapshot.
final class LiquidGlassView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let effectView: UIVisualEffectView

  init(frame: CGRect, viewId: Int64, args: Any?) {
    let params = args as? [String: Any] ?? [:]
    let isClear = (params["style"] as? String) == "clear"
    let isInteractive = params["interactive"] as? Bool ?? false
    let tint = LiquidGlassView.color(from: params["tint"] as? NSNumber)

    if #available(iOS 26.0, *) {
      let glass = UIGlassEffect(style: isClear ? .clear : .regular)
      glass.isInteractive = isInteractive
      glass.tintColor = tint
      effectView = UIVisualEffectView(effect: glass)
    } else {
      // Pre-26 falls back to the closest system material rather than to a flat
      // colour, so the bar still reads as translucent chrome.
      effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
      if let tint {
        let overlay = UIView()
        overlay.backgroundColor = tint.withAlphaComponent(0.18)
        overlay.translatesAutoresizingMaskIntoConstraints = false
        effectView.contentView.addSubview(overlay)
        NSLayoutConstraint.activate([
          overlay.topAnchor.constraint(equalTo: effectView.contentView.topAnchor),
          overlay.bottomAnchor.constraint(equalTo: effectView.contentView.bottomAnchor),
          overlay.leadingAnchor.constraint(equalTo: effectView.contentView.leadingAnchor),
          overlay.trailingAnchor.constraint(equalTo: effectView.contentView.trailingAnchor),
        ])
      }
    }

    super.init()

    effectView.frame = container.bounds
    effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    // The Flutter widget owns hit testing; the glass is purely decorative.
    effectView.isUserInteractionEnabled = false
    container.isUserInteractionEnabled = false
    container.backgroundColor = .clear
    container.addSubview(effectView)
  }

  func view() -> UIView { container }

  /// Dart sends an ARGB int, the same encoding as `Color.value`.
  private static func color(from value: NSNumber?) -> UIColor? {
    guard let raw = value?.uint32Value else { return nil }
    return UIColor(
      red: CGFloat((raw >> 16) & 0xFF) / 255.0,
      green: CGFloat((raw >> 8) & 0xFF) / 255.0,
      blue: CGFloat(raw & 0xFF) / 255.0,
      alpha: CGFloat((raw >> 24) & 0xFF) / 255.0
    )
  }
}

final class LiquidGlassViewFactory: NSObject, FlutterPlatformViewFactory {
  private let messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
  }

  func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?)
    -> FlutterPlatformView
  {
    LiquidGlassView(frame: frame, viewId: viewId, args: args)
  }

  func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
    FlutterStandardMessageCodec.sharedInstance()
  }
}
