//
//  SocketManager.swift
//  SocketPractice
//
//  Created by bill.w.chen on 2025/11/26.
//

import Foundation
import CocoaAsyncSocket

class SocketManager: NSObject, GCDAsyncSocketDelegate {

    static let shared = SocketManager()
    weak var delegate: SocketManagerDelegate?
    private var socket: GCDAsyncSocket!
    private var reconnectTimer: Timer?
    private var reconnectDelay: TimeInterval = 3
    private var reconnectAttempts = 0
    private let maxReconnectAttempts = 10
    private var myUserId: String = ""
    private var targetUserId: String = ""

    private let host = "127.0.0.1"   // 🔥 改成你的 Mac IP
    private let port: UInt16 = 3000

    var isConnected: Bool {
        return socket.isConnected
    }
    
    var isActive = false

    override init() {
        super.init()
        socket = GCDAsyncSocket(delegate: self, delegateQueue: .main)
    }

    // MARK: - Connect
    func connect() {
        guard !socket.isConnected else { return }

        // ❗️ 沒 userId 不准連線
        guard !myUserId.isEmpty else {
            print("⚠️ 尚未輸入 userId，不進行連線")
            return
        }

        do {
            print("🔌 連線中...")
            try socket.connect(toHost: host, onPort: port)
        } catch {
            print("❌ 連線失敗：\(error)")
            scheduleReconnect()
        }
    }
    
    func setMyUserId(_ id: String) {
        myUserId = id
    }

    func setTargetId(_ id: String) {
        targetUserId = id
    }
    
    func readMyUserId() -> String {
        return myUserId
    }

    // MARK: - Disconnect
    func disconnect() {
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        socket.disconnect()
    }

    // MARK: - Auto Reconnect
    private func scheduleReconnect() {
        guard reconnectTimer == nil else { return }
        guard reconnectAttempts < maxReconnectAttempts else {
            print("❌ 超過最大重連次數，不再重試")
            return
        }

        reconnectAttempts += 1
        print("⏳ \(reconnectDelay) 秒後嘗試重連（第 \(reconnectAttempts) 次）")

        reconnectTimer = Timer.scheduledTimer(withTimeInterval: reconnectDelay, repeats: false) { _ in
            self.reconnectTimer = nil
            self.connect()
        }
    }

    // MARK: - Send
    func send(json: [String: Any]) {
        let data = try! JSONSerialization.data(withJSONObject: json)
        socket.write(data, withTimeout: -1, tag: 0)
    }


    // MARK: - Delegate
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        print("✅ 已連線：\(host):\(port)")
        reconnectAttempts = 0
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        let registerData: [String: Any] = [
            "type": "register",
            "userId": myUserId
        ]
        send(json: registerData)
        socket.readData(withTimeout: -1, tag: 0)
    }

    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        print("⚠️ Socket 斷線：\(err?.localizedDescription ?? "未知錯誤")")
        if isActive {
            scheduleReconnect()
        }
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        socket.readData(withTimeout: -1, tag: 0)
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        guard let from = json["from"] as? String,
        let text = json["text"] as? String else { return }

        delegate?.didReceive(message: "[\(from)] \(text)")
    }
    
    // MARK: - Send message
    func sendMessage(to receiver: String, text: String) {
        let body: [String: Any] = [
            "type": "message",
            "from": myUserId,
            "to": targetUserId,
            "text": text
        ]
        send(json: body)
    }
}

protocol SocketManagerDelegate: AnyObject {
    func didReceive(message: String)
}
