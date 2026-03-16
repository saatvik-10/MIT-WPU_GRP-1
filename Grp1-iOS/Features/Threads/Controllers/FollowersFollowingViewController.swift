//
//  FollowersFollowingViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 16/03/26.
//

import UIKit
 
final class FollowersFollowingViewController: UIViewController {
 
    // MARK: - Input
    var initialSegment: Int = 0          // 0 = Followers, 1 = Following
    var followerNames: [String] = []
    var followingNames: [String] = []
 
    // MARK: - Data
    private let store = ThreadsDataStore.shared
    private var currentNames: [String] { selectedIndex == 0 ? followerNames : followingNames }
    private var selectedIndex: Int = 0
 
    // MARK: - UI
    private let segmentControl = UISegmentedControl(items: ["Followers", "Following"])
    private let tableView = UITableView()
 
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Connections"
        selectedIndex = initialSegment
        setupSegmentControl()
        setupTableView()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
 
    // MARK: - Setup
    private func setupSegmentControl() {
        segmentControl.translatesAutoresizingMaskIntoConstraints = false
        segmentControl.selectedSegmentIndex = initialSegment
        segmentControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        view.addSubview(segmentControl)
 
        NSLayoutConstraint.activate([
            segmentControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
 
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FollowUserCell.self, forCellReuseIdentifier: "FollowUserCell")
        tableView.rowHeight = 72
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 76, bottom: 0, right: 0)
        tableView.backgroundColor = .systemBackground
        view.addSubview(tableView)
 
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentControl.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
 
    @objc private func segmentChanged(_ sender: UISegmentedControl) {
        selectedIndex = sender.selectedSegmentIndex
        tableView.reloadData()
    }
}
 
// MARK: - UITableViewDataSource
extension FollowersFollowingViewController: UITableViewDataSource {
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentNames.count
    }
 
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowUserCell", for: indexPath) as! FollowUserCell
        let userName = currentNames[indexPath.row]
        let isFollowing = store.isFollowing(userName: userName)
        let isOwnProfile = userName == store.currentUserName
 
        cell.configure(userName: userName, isFollowing: isFollowing, isOwnProfile: isOwnProfile)
 
        cell.onFollowTapped = { [weak self] in
            guard let self else { return }
            self.store.toggleFollow(userName: userName)
            tableView.reloadRows(at: [indexPath], with: .none)
        }
 
        return cell
    }
}
 
// MARK: - UITableViewDelegate
extension FollowersFollowingViewController: UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let userName = currentNames[indexPath.row]
        guard userName != store.currentUserName else { return }
        let profileVC = BloggerProfileViewController()
        profileVC.bloggerUserName = userName
        navigationController?.pushViewController(profileVC, animated: true)
    }
}
 
 
// MARK: - FollowUserCell
final class FollowUserCell: UITableViewCell {
 
    var onFollowTapped: (() -> Void)?
 
    private let profileImageView = UIImageView()
    private let userNameLabel    = UILabel()
    private let followButton     = UIButton(type: .system)
 
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
 
    required init?(coder: NSCoder) { fatalError() }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
 
    private func setupUI() {
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .systemGray5
        profileImageView.image = UIImage(systemName: "person.circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.systemGray3)
        contentView.addSubview(profileImageView)
 
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        userNameLabel.textColor = .label
        contentView.addSubview(userNameLabel)
 
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.layer.cornerRadius = 10
        followButton.layer.borderWidth = 1
        followButton.clipsToBounds = true
        followButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        followButton.addTarget(self, action: #selector(followTapped), for: .touchUpInside)
        contentView.addSubview(followButton)
 
        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48),
 
            userNameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            userNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            userNameLabel.trailingAnchor.constraint(equalTo: followButton.leadingAnchor, constant: -12),
 
            followButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            followButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            followButton.widthAnchor.constraint(equalToConstant: 100),
            followButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
 
    func configure(userName: String, isFollowing: Bool, isOwnProfile: Bool) {
        userNameLabel.text = userName
        followButton.isHidden = isOwnProfile
 
        if isFollowing {
            followButton.setTitle("Following", for: .normal)
            followButton.setTitleColor(.label, for: .normal)
            followButton.backgroundColor = .clear
            followButton.layer.borderColor = UIColor.systemGray3.cgColor
        } else {
            followButton.setTitle("Follow", for: .normal)
            followButton.setTitleColor(.white, for: .normal)
            followButton.backgroundColor = .systemBlue
            followButton.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
 
    @objc private func followTapped() {
        onFollowTapped?()
    }
}
