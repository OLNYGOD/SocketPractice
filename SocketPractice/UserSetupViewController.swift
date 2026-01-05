//
//  UserSetupViewController.swift
//  SocketPractice
//
//  Created by bill.w.chen on 2025/12/12.
//

import UIKit

class UserSetupViewController: UIViewController {

    private let myIdField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "輸入你的 UserID（如：U1001）"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let targetIdField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "輸入對方 UserID（如：U1002）"
        tf.borderStyle = .roundedRect
        return tf
    }()
    
    private let enterButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("開始聊天", for: .normal)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 18)
        btn.backgroundColor = .systemBlue
        btn.layer.cornerRadius = 8
        btn.tintColor = .white
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "登入／選擇對象"
        view.backgroundColor = .white

        view.addSubview(myIdField)
        view.addSubview(targetIdField)
        view.addSubview(enterButton)

        enterButton.addTarget(self, action: #selector(startChat), for: .touchUpInside)

        layoutUI()
    }

    func layoutUI() {
        myIdField.translatesAutoresizingMaskIntoConstraints = false
        targetIdField.translatesAutoresizingMaskIntoConstraints = false
        enterButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            myIdField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            myIdField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            myIdField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            myIdField.heightAnchor.constraint(equalToConstant: 44),
            
            targetIdField.topAnchor.constraint(equalTo: myIdField.bottomAnchor, constant: 20),
            targetIdField.leadingAnchor.constraint(equalTo: myIdField.leadingAnchor),
            targetIdField.trailingAnchor.constraint(equalTo: myIdField.trailingAnchor),
            targetIdField.heightAnchor.constraint(equalToConstant: 44),

            enterButton.topAnchor.constraint(equalTo: targetIdField.bottomAnchor, constant: 40),
            enterButton.leadingAnchor.constraint(equalTo: myIdField.leadingAnchor),
            enterButton.trailingAnchor.constraint(equalTo: myIdField.trailingAnchor),
            enterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc func startChat() {
        guard let myId = myIdField.text, !myId.isEmpty,
              let target = targetIdField.text, !target.isEmpty else {
            print("⚠️ 請輸入完整資訊")
            return
        }

        SocketManager.shared.setMyUserId(myId)
        SocketManager.shared.setTargetId(target)
        SocketManager.shared.connect()

        let chatVC = ViewController()
        navigationController?.pushViewController(chatVC, animated: true)
    }
}
