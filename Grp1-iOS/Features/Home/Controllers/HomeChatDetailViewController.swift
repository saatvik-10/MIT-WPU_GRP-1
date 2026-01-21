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
    var articleID: Int?
    var dominantColor: UIColor?
    private var lastQuestion: String?
    private var lastAnswer: String?
    weak var delegate : HomeChatDetailViewControllerDelegate?

    var chatTitle: String?
    var isNewChat : Bool = false

    let currentUser = Sender(senderId: "self", displayName: "")
    let botSender   = Sender(senderId: "bot",  displayName: "")


    var messages: [Message] = []
 
    private var selectedMessageIndex: Int = 0

    let mockBotReplies = MockBotReplies.replies
    var botReplyIndex = 0


    
    
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

        title = chatTitle ?? "Chat"

        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.largeTitleDisplayMode = .never
        
        let smallFont = UIFont.systemFont(ofSize: 16, weight: .semibold)
            navigationController?.navigationBar.titleTextAttributes = [
                .font : smallFont
            ]


        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messagesCollectionView.backgroundColor = dominantColor
 
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        messagesCollectionView.addGestureRecognizer(tapGesture)
        
        configureMessageInputBar()
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageIncomingAvatarSize(.zero)
            layout.setMessageOutgoingAvatarSize(.zero)
        }

        loadDummyMessages()
    }
    
    private func configureMessageInputBar() {
        messageInputBar.delegate = self
        
        messageInputBar.inputTextView.placeholder = "Type a message..."
        messageInputBar.inputTextView.placeholderTextColor = UIColor.systemGray3
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        messageInputBar.inputTextView.layer.borderColor = UIColor.systemGray4.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        messageInputBar.inputTextView.isUserInteractionEnabled = true
        messageInputBar.inputTextView.isEditable = true
        messageInputBar.inputTextView.isScrollEnabled = true
        
        messageInputBar.sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        messageInputBar.sendButton.setTitle("", for: .normal)  // Remove text
        messageInputBar.sendButton.tintColor = .systemBlue
        
        messageInputBar.padding = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    @objc private func dismissKeyboard() {
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !messages.isEmpty {
            messagesCollectionView.scrollToLastItem(animated: false)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() ) {
            self.messageInputBar.inputTextView.becomeFirstResponder()
        }
    }

    private func loadDummyMessages() {

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
            botReplyIndex = 1
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


            NewsDataStore.shared.addQA(
                for: articleID,
                question: question,
                answer: answer
            )

            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)

            UIView.animate(withDuration: 0.2, animations: {
                self.view.alpha = 0.95
            }) { _ in
   
                self.dismiss(animated: true)
            }
    }
    
}


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
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
}



extension HomeChatDetailViewController: MessagesLayoutDelegate, MessagesDisplayDelegate {

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
    
    func messageStyle(for message: MessageType,
                      at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = message.sender.senderId == currentUser.senderId ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
    

    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
}



extension HomeChatDetailViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        lastQuestion = trimmed


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
        
     
        inputBar.inputTextView.text = ""
        inputBar.invalidatePlugins()
        
   
        messagesCollectionView.insertSections([messages.count - 1])
        messagesCollectionView.scrollToLastItem(animated: true)

  
        sendNextBotReply()
    }
}



