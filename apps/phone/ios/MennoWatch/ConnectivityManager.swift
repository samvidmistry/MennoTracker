import Combine
import Foundation
import WatchConnectivity

final class ConnectivityManager: NSObject, ObservableObject {
    static let shared = ConnectivityManager()

    @Published var currentPayload: WatchPayload?
    @Published private(set) var activationState: WCSessionActivationState = .notActivated

    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var pendingReliableTransfers: [[String: Any]] = []
    private var pendingLiveMessages: [[String: Any]] = []

    private override init() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        session.delegate = self

        if session.activationState != .activated {
            session.activate()
        } else {
            activationState = session.activationState
            flushPendingUploads()
        }
    }

    func sendSetCompleted(
        _ setLog: SetLog,
        sessionId: String? = nil,
        workoutId: String? = nil,
        block: WatchExerciseBlock? = nil,
        blockIndex: Int? = nil,
        setIndex: Int? = nil
    ) {
        var envelope = makeEnvelope(type: "setCompleted")
        if let setLogData = try? encoder.encode(setLog) {
            envelope["setLog"] = setLogData
        }
        add(sessionId ?? currentPayload?.sessionId, to: &envelope, key: "sessionId")
        add(workoutId ?? currentPayload?.workoutId, to: &envelope, key: "workoutId")
        add(block?.blockId, to: &envelope, key: "blockId")
        add(block?.exerciseId, to: &envelope, key: "exerciseId")
        add(blockIndex, to: &envelope, key: "blockIndex")
        add(setIndex, to: &envelope, key: "setIndex")
        send(envelope)
    }

    func sendSessionComplete() {
        flushPendingUploads()

        var envelope = makeEnvelope(type: "sessionComplete")
        add(currentPayload?.sessionId, to: &envelope, key: "sessionId")
        add(currentPayload?.workoutId, to: &envelope, key: "workoutId")
        envelope["completedAt"] = Date()
        send(envelope)
        flushPendingUploads()
    }

    private func makeEnvelope(type: String) -> [String: Any] {
        [
            "type": type,
            "schemaVersion": 1,
            "sentAt": Date()
        ]
    }

    private func add<T>(_ value: T?, to dictionary: inout [String: Any], key: String) {
        guard let value else { return }
        dictionary[key] = value
    }

    private func send(_ envelope: [String: Any]) {
        activate()
        guard WCSession.isSupported() else {
            pendingReliableTransfers.append(envelope)
            pendingLiveMessages.append(envelope)
            return
        }

        let session = WCSession.default
        if session.activationState == .activated {
            session.transferUserInfo(envelope)
        } else {
            pendingReliableTransfers.append(envelope)
        }

        if session.isReachable {
            session.sendMessage(envelope, replyHandler: nil) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.pendingLiveMessages.append(envelope)
                }
            }
        } else {
            pendingLiveMessages.append(envelope)
        }
    }

    private func flushPendingUploads() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default

        if session.activationState == .activated, !pendingReliableTransfers.isEmpty {
            let transfers = pendingReliableTransfers
            pendingReliableTransfers.removeAll()
            transfers.forEach { session.transferUserInfo($0) }
        }

        guard session.isReachable, !pendingLiveMessages.isEmpty else { return }
        let messages = pendingLiveMessages
        pendingLiveMessages.removeAll()
        messages.forEach { message in
            session.sendMessage(message, replyHandler: nil) { [weak self] _ in
                DispatchQueue.main.async {
                    self?.pendingLiveMessages.append(message)
                }
            }
        }
    }

    private func handleInbound(_ dictionary: [String: Any]) {
        guard let payload = decodePayload(from: dictionary) else { return }
        DispatchQueue.main.async {
            self.currentPayload = payload
        }
    }

    private func decodePayload(from dictionary: [String: Any]) -> WatchPayload? {
        for key in ["payload", "watchPayload", "workoutPayload", "data"] {
            if let data = dictionary[key] as? Data,
               let payload = try? decoder.decode(WatchPayload.self, from: data) {
                return payload
            }

            if let json = dictionary[key] as? String,
               let data = json.data(using: .utf8),
               let payload = try? decoder.decode(WatchPayload.self, from: data) {
                return payload
            }

            if let nested = dictionary[key] as? [String: Any],
               let payload = decodePayload(from: nested) {
                return payload
            }
        }

        guard dictionary["schemaVersion"] != nil,
              dictionary["sessionId"] != nil,
              JSONSerialization.isValidJSONObject(dictionary),
              let data = try? JSONSerialization.data(withJSONObject: dictionary),
              let payload = try? decoder.decode(WatchPayload.self, from: data) else {
            return nil
        }
        return payload
    }
}

extension ConnectivityManager: WCSessionDelegate {
    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        DispatchQueue.main.async {
            self.activationState = activationState
            self.flushPendingUploads()
        }
    }

    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any]) {
        handleInbound(userInfo)
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        handleInbound(message)
    }

    func session(
        _ session: WCSession,
        didReceiveMessage message: [String: Any],
        replyHandler: @escaping ([String: Any]) -> Void
    ) {
        handleInbound(message)
        replyHandler(["ok": true])
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.flushPendingUploads()
        }
    }
}

