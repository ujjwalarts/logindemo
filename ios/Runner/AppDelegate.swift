import UIKit
import Flutter
import Firebase
import FirebaseDynamicLinks

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    if let incomingURL = userActivity.webpageURL {
      print("Incoming URL is \(incomingURL)")
      let handled = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamicLink, error in
        if let link = dynamicLink?.url {
          print("Dynamic link URL: \(link.absoluteString)")
          // Pass this to your Flutter side
        }
      }
      return handled
    }
    return false
  }
}
