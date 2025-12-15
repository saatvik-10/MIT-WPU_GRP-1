//
//  ChatDetailViewController.swift
//  ChatScreen
//
//

import UIKit
import MessageKit
import InputBarAccessoryView


// MARK: - View Controller

protocol HomeChatDetailViewControllerDelegate: AnyObject {
    func chatDetail(_ vc: HomeChatDetailViewController,didCreateNewChatWithFirstQuestion question: String)
}


class HomeChatDetailViewController: MessagesViewController {
    var articleID: Int?   // 👈 which article this chat belongs to
    var dominantColor: UIColor?
    private var lastQuestion: String?
    private var lastAnswer: String?
    weak var delegate : HomeChatDetailViewControllerDelegate?
    // You can set this from previous screen
    var chatTitle: String?
    var isNewChat : Bool = false

    // current user & bot
    let currentUser = Sender(senderId: "self", displayName: "")
    let botSender   = Sender(senderId: "bot",  displayName: "")

    // all messages shown in chat
    var messages: [Message] = []
    
    // Store selected message index for menu actions
    private var selectedMessageIndex: Int = 0

    // mock bot replies
    let mockBotReplies = MockBotReplies.replies
    var botReplyIndex = 0

    // MARK: - Lifecycle

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        if let dom = dominantColor {
//                view.backgroundColor = dom   // <--- SET SCREEN COLOR
//                messagesCollectionView.backgroundColor = dom
//                messageInputBar.backgroundView.backgroundColor = dom
//                messageInputBar.inputTextView.backgroundColor = dom
//            }
//        
        view.backgroundColor = .systemBackground
        messagesCollectionView.backgroundColor = .systemBackground
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        
        // navigation title
        title = chatTitle ?? "Chat"
        
        // Configure navigation bar
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        let smallFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
            navigationController?.navigationBar.titleTextAttributes = [
                .font : smallFont
            ]

        // MessageKit setup - ORDER MATTERS!
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        // IMPORTANT: Configure the collection view
        messagesCollectionView.backgroundColor = dominantColor
        
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
        messageInputBar.sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        messageInputBar.sendButton.setTitle("", for: .normal)  // Remove text
        messageInputBar.sendButton.tintColor = .systemBlue
        
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
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            self.messageInputBar.inputTextView.becomeFirstResponder()
        }
    }

    private func loadDummyMessages() {
        // some starting messages (user + bot)
        if isNewChat {
            messages = []
            botReplyIndex = 0
        }
        else{
            let m1 = Message(
                sender: botSender,
                messageId: UUID().uuidString,
                kind: .text(mockBotReplies[0])
            )
            
            
            
            messages = [m1]
            botReplyIndex = 1 // Updated to continue from m7
        }
        messagesCollectionView.reloadData()
    }

    private func sendNextBotReply() {
        guard botReplyIndex < mockBotReplies.count else { return }
        
        let text = mockBotReplies[botReplyIndex]
        lastAnswer = text
        botReplyIndex += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7){
            let message = Message(
                sender:self.botSender ,
                messageId: UUID().uuidString,
                kind: .text(text))
            
            self.messages.append(message)
            self.messagesCollectionView.insertSections([self.messages.count - 1])
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    // MARK: - Menu Actions
    
    
    @IBAction func doneTapped(_ sender: Any) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        dismiss(animated: true)
    }
    
    @IBAction func postTapped(_ sender: UIButton) {
        guard
                let articleID = articleID,
                let question = lastQuestion,
                let answer = lastAnswer
            else { return }

            // 1️⃣ SAVE TO DATA STORE
            NewsDataStore.shared.addQA(
                for: articleID,
                question: question,
                answer: answer
            )

            // 2️⃣ HAPTIC FEEDBACK
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            // 3️⃣ SMALL SUCCESS ANIMATION (fade)
            UIView.animate(withDuration: 0.2, animations: {
                self.view.alpha = 0.95
            }) { _ in
                // 4️⃣ CLOSE MODAL
                self.dismiss(animated: true)
            }
    }
    
}

// MARK: - MessagesDataSource

extension HomeChatDetailViewController: MessagesDataSource {

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
    
    // Required: Top label - REMOVED to hide timestamp
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    
    // Required: Bottom label
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
}


// MARK: - MessagesLayoutDelegate & MessagesDisplayDelegate

extension HomeChatDetailViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {

    // optional: different bubble colors
    func backgroundColor(for message: MessageType,
                         at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.senderId == currentUser.senderId {
            return AppTheme.shared.dominantColor
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
    
    // Height for top label - SET TO 0 to hide timestamp
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    // Height for bottom label
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
}


// MARK: - InputBarAccessoryViewDelegate

extension HomeChatDetailViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        lastQuestion = trimmed

        // user message
        if isNewChat {
            delegate?.chatDetail(self, didCreateNewChatWithFirstQuestion: trimmed)
            isNewChat = false
            
            let welcomeMsg = Message(
                sender: botSender,
                messageId: UUID().uuidString,
                kind: .text(mockBotReplies[0])
            )
            messages.append(welcomeMsg)
            messagesCollectionView.insertSections([messages.count - 1])
            botReplyIndex = 1
        }
        
        
        let newMessage = Message(
            sender: currentUser,
            messageId: UUID().uuidString,
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



