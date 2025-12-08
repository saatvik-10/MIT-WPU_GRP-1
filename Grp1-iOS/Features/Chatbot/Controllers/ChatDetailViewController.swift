
//
//  ChatDetailViewController.swift
//  ChatScreen
//
//

import UIKit
import MessageKit
import InputBarAccessoryView

// MARK: - Models

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

// MARK: - View Controller

class ChatDetailViewController: MessagesViewController {

    // You can set this from previous screen
    var chatTitle: String?
    var isNewChat : Bool = false

    // current user & bot
    let currentUser = Sender(senderId: "self", displayName: "")
    let botSender   = Sender(senderId: "bot",  displayName: "")

    // all messages shown in chat
    var messages: [Message] = []

    // mock bot replies
    let mockBotReplies: [String] = [
        "Hi! I'm your financial learning assistant. Ask me anything about repo rate, inflation, or markets. 😊",
        "Repo rate is the interest rate at which the RBI lends money to commercial banks.",
        "When repo rate goes up, banks' borrowing cost increases — so they may increase loan interest rates too.",
        "That's why your home loan EMI can go up if repo rate keeps increasing over time.",
        "On the other hand, higher rates can be good for fixed deposits and debt mutual funds.",
        "So repo rate changes affect both borrowers and savers in different ways."
     ]
    var botReplyIndex = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // navigation title
        title = chatTitle ?? "Chat"
        
        // Configure navigation bar
        navigationController?.navigationBar.prefersLargeTitles = false

        // MessageKit setup - ORDER MATTERS!
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        // IMPORTANT: Configure the collection view
        messagesCollectionView.backgroundColor = .systemBackground
        
        // Dismiss keyboard when tapping on messages
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        messagesCollectionView.addGestureRecognizer(tapGesture)
        
        // Configure input bar - CRITICAL FOR KEYBOARD
        configureMessageInputBar()
        
        // Configure avatar
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
        }

        // initial dummy conversation
        loadDummyMessages()
    }
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        
        // Input text view configuration
        messageInputBar.inputTextView.placeholder = "Type a message..."
        messageInputBar.inputTextView.placeholderTextColor = UIColor.systemGray3
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        messageInputBar.inputTextView.layer.borderColor = UIColor.systemGray4.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        // CRITICAL: Enable user interaction
        messageInputBar.inputTextView.isUserInteractionEnabled = true
        messageInputBar.inputTextView.isEditable = true
        messageInputBar.inputTextView.isScrollEnabled = true
        
        // Send button configuration
        messageInputBar.sendButton.setTitle("Send", for: .normal)
        messageInputBar.sendButton.setTitleColor(.systemBlue, for: .normal)
        messageInputBar.sendButton.setTitleColor(.systemGray, for: .disabled)
        
        // Set message input bar padding
        messageInputBar.padding = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        
        // Background color
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    @objc private func dismissKeyboard() {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Scroll to bottom when view appears
        if !messages.isEmpty {
            messagesCollectionView.scrollToLastItem(animated: false)
        }
        
        // IMPORTANT: Open keyboard after view appears for better animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.messageInputBar.inputTextView.becomeFirstResponder()
        }
    }

    private func loadDummyMessages() {
        // some starting messages (user + bot)
        if isNewChat {
            let welcomeMessage = Message(sender: botSender,
                                         messageId: UUID().uuidString,
                                         sentDate: Date(),
                                         kind: .text(mockBotReplies[0]))
        }
        else{
            let m1 = Message(
                sender: botSender,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-120),
                kind: .text(mockBotReplies[0])
            )
            
            let m2 = Message(
                sender: currentUser,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-60),
                kind: .text("I want to understand the repo rate limit. Can you help me?")
            )
            
            let m3 = Message(
                sender: botSender,
                messageId: UUID().uuidString,
                sentDate: Date(),
                kind: .text(mockBotReplies[1])
            )
            
            let m4 = Message(
                sender: currentUser,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-60),
                kind: .text("How does repo rate affect the banks ?")
            )
            
            let m5 = Message(
                sender: botSender,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-60),
                kind: .text(mockBotReplies[2])
            )
            let m6 = Message(
                sender: currentUser,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-60),
                kind: .text("How does it affect my Home loans, interests rate ? ")
            )
            let m7 = Message(
                sender: botSender,
                messageId: UUID().uuidString,
                sentDate: Date().addingTimeInterval(-60),
                kind: .text(mockBotReplies[3])
            )
            
            
            messages = [m1, m2, m3,m4,m5,m6,m7]
            botReplyIndex = 1
        }
        messagesCollectionView.reloadData()
    }

    private func sendNextBotReply() {
        guard botReplyIndex < mockBotReplies.count else { return }

        let text = mockBotReplies[botReplyIndex]
        botReplyIndex += 1

        // small delay to feel like "thinking"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            let message = Message(
                sender: self.botSender,
                messageId: UUID().uuidString,
                sentDate: Date(),
                kind: .text(text)
            )
            self.messages.append(message)
            self.messagesCollectionView.insertSections([self.messages.count - 1])
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
}

// MARK: - MessagesDataSource

extension ChatDetailViewController: MessagesDataSource {

    var currentSender: SenderType {
        return currentUser
    }

    func messageForItem(at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> any MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    // Required: Configure the avatar for each message
    func avatar(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Avatar? {
        // Return nil since we're hiding avatars
        return nil
    }
    
    // Required: Top label (can show sender name or timestamp)
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor.systemGray
            ]
        )
    }
    
    // Required: Bottom label (can show delivery status, timestamp, etc)
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: message.sentDate)
        return NSAttributedString(
            string: dateString,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption2),
                .foregroundColor: UIColor.systemGray2
            ]
        )
    }
}


// MARK: - MessagesLayoutDelegate & MessagesDisplayDelegate

extension ChatDetailViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {

    // optional: different bubble colors
    func backgroundColor(for message: MessageType,
                         at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == currentUser.senderId {
            return UIColor.systemBlue
        } else {
            return UIColor.systemGray5
        }
    }

    func textColor(for message: MessageType,
                   at indexPath: IndexPath,
                   in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == currentUser.senderId {
            return .white
        } else {
            return .label
        }
    }
    
    // Configure message style
    func messageStyle(for message: MessageType,
                      at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = message.sender.senderId == currentUser.senderId ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    
    // MARK: - Layout Delegate Methods
    
    // Height for top label (sender name)
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    // Height for bottom label (timestamp)
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

// MARK: - InputBarAccessoryViewDelegate

extension ChatDetailViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // user message
        let newMessage = Message(
            sender: currentUser,
            messageId: UUID().uuidString,
            sentDate: Date(),
            kind: .text(trimmed)
        )
        messages.append(newMessage)
        
        // clear text field first
        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()
        
        // Insert new section
        messagesCollectionView.insertSections([messages.count - 1])
        messagesCollectionView.scrollToLastItem(animated: true)

        // bot reply
        sendNextBotReply()
    }
}
