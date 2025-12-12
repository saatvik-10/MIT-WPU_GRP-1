//
//  Models.swift
//

import Foundation
import MessageKit

// MARK: - Sender Model
struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

// MARK: - Message Model
struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
    init(sender: SenderType, messageId: String, kind: MessageKind) {
        self.sender = sender
        self.messageId = messageId
        self.sentDate = Date() // Auto timestamp
        self.kind = kind
    }
}

// MARK: - Mock Data (Bot Replies)
struct MockBotReplies {
    static let replies: [String] = [
        "Hi! I'm your financial learning assistant. Ask me anything about repo rate, inflation, or markets. 😊",
        "Repo rate is the interest rate at which the RBI lends money to commercial banks.",
        "When repo rate goes up, banks' borrowing cost increases — so they may increase loan interest rates too.",
        "That's why your home loan EMI can go up if repo rate keeps increasing over time.",
        "On the other hand, higher rates can be good for fixed deposits and debt mutual funds.",
        "So repo rate changes affect both borrowers and savers in different ways."
    ]
}

struct ChatPreview {
    let id: UUID
    let title: String
    let timestamp: Date
}

