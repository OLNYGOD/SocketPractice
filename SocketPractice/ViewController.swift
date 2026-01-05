//
//  ViewController.swift
//  SocketPractice
//
//  Created by bill.w.chen on 2025/11/26.
//

import UIKit

class ViewController: UIViewController {

    private let tableView = UITableView()
    private let inputContainer = UIView()
    private let inputField = UITextField()
    private let sendButton = UIButton(type: .system)

    private var messages: [Message] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSocket()
        
        Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { _ in
            
            let pingData: [String: Any] = [
                "type": "ping",
                "userId": SocketManager.shared.readMyUserId()
            ]
            SocketManager.shared.send(json: pingData)
        }

                // Demo：每 3 秒送訊息
//        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
//            SocketManager.shared.send("PING")
//        }
//
//        // Demo：每 3 秒送訊息
//        Timer.scheduledTimer(withTimeInterval: 11, repeats: true) { _ in
//            SocketManager.shared.send("HELLO")
//        }
//
//        // Demo：每 3 秒送訊息
//        Timer.scheduledTimer(withTimeInterval: 21, repeats: true) { _ in
//            SocketManager.shared.send("TIME")
//        }
    }

    // MARK: - Setup UI
    private func setupUI() {

        view.backgroundColor = .white

        // MARK: TableView
        tableView.register(MessageCell.self, forCellReuseIdentifier: MessageCell.identifier)
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(tableView)

        // MARK: Input Container (下方白色區域)
        inputContainer.backgroundColor = UIColor(white: 0.95, alpha: 1)
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputContainer)

        // MARK: Input Field
        inputField.placeholder = "輸入訊息..."
        inputField.borderStyle = .roundedRect
        inputField.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(inputField)

        // MARK: Send Button
        sendButton.setTitle("送出", for: .normal)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(sendButton)

        // MARK: AutoLayout
        NSLayoutConstraint.activate([
            // tableView 占滿上面
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),

            // 下方輸入框容器
            inputContainer.topAnchor.constraint(equalTo: tableView.bottomAnchor),
            inputContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            inputContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputContainer.heightAnchor.constraint(equalToConstant: 60),

            // inputField
            inputField.leftAnchor.constraint(equalTo: inputContainer.leftAnchor, constant: 12),
            inputField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            inputField.heightAnchor.constraint(equalToConstant: 36),

            // Send Button
            sendButton.leftAnchor.constraint(equalTo: inputField.rightAnchor, constant: 8),
            sendButton.rightAnchor.constraint(equalTo: inputContainer.rightAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),

            // inputField 寬度
            inputField.rightAnchor.constraint(equalTo: sendButton.leftAnchor, constant: -8)
        ])
    }

    // MARK: Socket
    private func setupSocket() {
        SocketManager.shared.delegate = self
        SocketManager.shared.connect()
    }

    // MARK: Send Message
    @objc func sendMessage(_ sender: Any) {
        guard let text = inputField.text, !text.isEmpty else { return }

        // 🔥 A001 → B001（寫死）
        SocketManager.shared.sendMessage(to: "A001", text: text)

        addMessage("[A001] \(text)", type: .me)

        inputField.text = ""
    }

    func addMessage(_ text: String, type: MessageType) {
        messages.append(Message(text: text, type: type))
        tableView.reloadData()
        scrollToBottom()
    }

    func scrollToBottom() {
        guard messages.count > 0 else { return }
        let index = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: index, at: .bottom, animated: true)
    }
}

// MARK: Socket Delegate
extension ViewController: SocketManagerDelegate {
    func didReceive(message: String) {
        addMessage(message, type: .server)
    }
}

// MARK: TableView
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: MessageCell.identifier,
            for: indexPath
        ) as! MessageCell

        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

