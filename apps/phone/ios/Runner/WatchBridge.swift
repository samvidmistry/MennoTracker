import Flutter
import WatchConnectivity
import UIKit

final class WatchBridge: NSObject, WCSessionDelegate {
    static let shared = WatchBridge()
    static let channelName = "mennotracker/watch"

    private var session: WCSession?

    private override init() {
        super.init()
        if WCSession.isSupported() {
            let s = WCSession.default
            s.delegate = self
            s.activate()
            session = s
        }
    }

    func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(name: WatchBridge.channelName, binaryMessenger: messenger)
        channel.setMethodCallHandler { [weak self] call, result in
            self?.handle(call: call, result: result)
        }
    }

    private func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let session = session else { result(false); return }
        switch call.method {
        case "isReachable":
            result(session.isReachable)
        case "sendWorkoutPayload":
            guard let args = call.arguments as? [String: Any] else { result(false); return }
            session.transferUserInfo(["type": "workoutPayload", "payload": args])
            if session.isReachable {
                session.sendMessage(["type": "workoutPayload", "payload": args], replyHandler: nil) { _ in }
            }
            result(true)
        case "sendSetCompleted":
            guard let args = call.arguments as? [String: Any] else { result(false); return }
            session.transferUserInfo(["type": "setCompleted", "payload": args])
            result(true)
        case "triggerHaptic":
            // No-op on phone side; the watch plays haptic on its own when it receives the set completion.
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // WCSessionDelegate
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
}
