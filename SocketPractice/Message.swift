//
//  Untitled.swift
//  SocketPractice
//
//  Created by bill.w.chen on 2025/12/12.
//

import Foundation

enum MessageType {
    case me
    case server
}

struct Message {
    let text: String
    let type: MessageType
}
