//
//  ChatListViewController.swift
//  ChatScreen
//
//  Created by SDC-USER on 24/11/25.
//

import UIKit

class ChatListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func newChatButton(_ sender: Any) {
        openChatDetail(withTitle: "New Chat", isNewChat: true)
    }
    var chats: [ChatPreview] = [
        ChatPreview(id: UUID(), title: "What is inflation?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "What is repo rate?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "Why does RBI increase the repo rate?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "Explain the Indian Economy?", timestamp: Date()),
        ChatPreview(id: UUID(), title: "What is FII?", timestamp: Date())
    ]
    
    var filteredChats: [ChatPreview] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredChats = chats
        
        setupTableView()
        setupSearchBar()
        //setupNewChatButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.largeTitleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 34, weight: .bold)
            ]
            appearance.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
            ]

            // Apply ONLY to ChatList
            navigationItem.standardAppearance = appearance
            navigationItem.scrollEdgeAppearance = appearance

            navigationItem.largeTitleDisplayMode = .always
            navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    // MARK: - Setup Methods
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .onDrag // Dismiss keyboard when scrolling
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.placeholder = "Search chats..."
        searchBar.returnKeyType = .search
        searchBar.enablesReturnKeyAutomatically = false
    }
    
    // MARK: - Search Logic
    
    private func filterChats(with searchText: String) {
        if searchText.isEmpty {
            filteredChats = chats
        } else {
            filteredChats = chats.filter { chat in
                chat.title.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }


    
    // MARK: - Navigation
    
    private func openChatDetail(withTitle title: String, isNewChat: Bool = false) {
        let chatDetailVC = ChatDetailViewController()
        chatDetailVC.chatTitle = title
        chatDetailVC.isNewChat = isNewChat
        navigationController?.pushViewController(chatDetailVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChatListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredChats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        let chat = filteredChats[indexPath.row]
        
        var config = cell.defaultContentConfiguration()
        config.text = chat.title
        config.secondaryText = chat.timestamp.formatted(date: .numeric, time: .shortened)
        config.textProperties.font = .systemFont(ofSize: 16,weight: .medium)
        config.secondaryTextProperties.color = .gray

        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ChatListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chat = filteredChats[indexPath.row]
        openChatDetail(withTitle: chat.title, isNewChat: false)
    }
}

// MARK: - UISearchBarDelegate

extension ChatListViewController: UISearchBarDelegate {
    
    // Called when text changes
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterChats(with: searchText)
    }
    
    // Called when search button is tapped on keyboard
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Dismiss keyboard
    }
    
    // Called when cancel button is tapped
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        filterChats(with: "")
    }
    
    // Optional: Show cancel button when editing begins
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    // Optional: Hide cancel button when editing ends
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
}
