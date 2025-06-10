import UIKit
import AVFoundation
import FirebaseCore
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {

  var cameraController: CameraController?
  var universalLinkChannel: FlutterMethodChannel?
  var pendingUniversalLink: String?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)

    if let controller = window?.rootViewController as? FlutterViewController {
      // 📹 Видео-канал
      let videoChannel = FlutterMethodChannel(
        name: "camera_merge_channel",
        binaryMessenger: controller.binaryMessenger
      )
      videoChannel.setMethodCallHandler { [weak self] call, result in
        if call.method == "mergeVideos", let args = call.arguments as? [String] {
          let urls = args.map { URL(fileURLWithPath: $0) }
          self?.cameraController?.mergeVideos(from: urls) { mergedURL in
            if let url = mergedURL {
              result(url.absoluteString)
            } else {
              result(FlutterError(code: "MERGE_FAILED", message: "Unable to merge videos", details: nil))
            }
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }

      // 🔗 Канал для Universal Link
      let linkChannel = FlutterMethodChannel(
        name: "universal_link_channel",
        binaryMessenger: controller.binaryMessenger
      )
      self.universalLinkChannel = linkChannel

      // ✅ Обработчик getInitialLink
      linkChannel.setMethodCallHandler { [weak self] call, result in
        if call.method == "getInitialLink" {
          result(self?.pendingUniversalLink)
          self?.pendingUniversalLink = nil
        } else {
          result(FlutterMethodNotImplemented)
        }
      }

      // ⏳ После создания канала — передаём pending ссылку
      if self.pendingUniversalLink != nil {
        self.waitAndSendInitialLink()
      }
    } else {
      print("⚠️ Warning: RootViewController is not FlutterViewController")
    }

    // ✅ Сохраняем ссылку, если она пришла при старте
    if let activityDictionary = launchOptions?[.userActivityDictionary] as? [AnyHashable: Any] {
      for (_, activity) in activityDictionary {
        if let userActivity = activity as? NSUserActivity,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let incomingURL = userActivity.webpageURL {

          print("📦 Initial link at launch: \(incomingURL.absoluteString)")
          pendingUniversalLink = incomingURL.absoluteString
        }
      }
    }

    cameraController = CameraController()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let incomingURL = userActivity.webpageURL else {
      return false
    }

    print("🔥 Universal Link received: \(incomingURL.absoluteString)")

    // 🟣 Показываем alert на экране
   

    if incomingURL.absoluteString.contains("resetPassword") {
      if let channel = universalLinkChannel {
        print("📤 Sending link immediately to Flutter")
        channel.invokeMethod("handleUniversalLink", arguments: incomingURL.absoluteString)
      } else {
        print("⏳ Flutter not ready, saving link for later")
        pendingUniversalLink = incomingURL.absoluteString
      }
    }

    return true
  }

  // 🔁 Метод ожидания готовности Flutter и отправки ссылки
  func waitAndSendInitialLink() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
      guard let self = self else { return }

      if let channel = self.universalLinkChannel, let link = self.pendingUniversalLink {
        print("📤 ✅ Flutter is ready. Sending initial link: \(link)")
        channel.invokeMethod("handleUniversalLink", arguments: link)
        self.pendingUniversalLink = nil
      } else {
        print("⏳ Waiting for Flutter to be ready...")
        self.waitAndSendInitialLink()
      }
    }
  }

 
}
