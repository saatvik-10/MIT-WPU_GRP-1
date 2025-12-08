//
//  ChatListViewController.swift
//  ChatScreen
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

struct ChatPreview {
    let id: UUID
    let title: String
    let timestamp: Date
}

class ChatListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var chats: [ChatPreview] = [
        ChatPreview(id: UUID(), title: "What is inflation?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "What is repo rate?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "Why does RBI increases the repo rate?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "Explain the Indian Economy?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "What is FII?", timestamp: Date())
    ]
    
    var filteredChats: [ChatPreview] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredChats = chats
        tableView.dataSource = self
        tableView.delegate = self
        
        // Use standard title
        title = "Chats"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Increase navigation bar font size
        let titleLabel = UILabel()
            titleLabel.text = "Chats"
            titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
            titleLabel.textColor = .label
            titleLabel.textAlignment = .left
            
            // Create container view to position label on the left
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44))
            titleLabel.frame = CGRect(x: -80, y: 40, width: 200, height: 44) // Negative x shifts left
            containerView.addSubview(titleLabel)
            
            navigationItem.titleView = containerView
        
        // Setup "New Chat" button
        setupNewChatButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    // MARK: - Setup New Chat Button
    
    private func setupNewChatButton() {
        let newChatButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(newChatButtonTapped)
        )
        navigationItem.rightBarButtonItem = newChatButton
    }
    
    @objc private func newChatButtonTapped() {
        // Open new chat
        openChatDetail(withTitle: "New Chat", isNewChat: true)
    }
    
    // MARK: - Navigation Helper
    
    private func openChatDetail(withTitle title: String, isNewChat: Bool = false) {
        // Create ChatDetailViewController programmatically (no storyboard)
        let chatDetailVC = ChatDetailViewController()
        chatDetailVC.chatTitle = title
        chatDetailVC.isNewChat = isNewChat
        
        navigationController?.pushViewController(chatDetailVC, animated: true)
    }
    
    // MARK: - TableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        let chat = filteredChats[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = chat.title
        config.secondaryText = chat.timestamp.formatted(date: .numeric, time: .shortened)
        config.textProperties.font = .systemFont(ofSize: 16)
        config.secondaryTextProperties.color = .gray
        
        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Open existing chat (from table view)
        let chat = filteredChats[indexPath.row]
        openChatDetail(withTitle: chat.title, isNewChat: false)
    }
}
