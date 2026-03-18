//
//  BloggerProfileViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 16/03/26.
//

import UIKit
 
final class BloggerProfileViewController: UIViewController {
 
    // MARK: - Input
    var bloggerUserName: String = ""
 
    // MARK: - Data
    private let store = ThreadsDataStore.shared
    private var posts: [ThreadPost] = []
 
    // MARK: - UI
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
 
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 250/255, alpha: 1)
        navigationItem.title = bloggerUserName
        loadPosts()
        setupCollectionView()
    }
 
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }
 
    // MARK: - Data
    private func loadPosts() {
        posts = store.getAllPostsForSearch().filter { $0.userName == bloggerUserName }
    }
 
    // MARK: - CollectionView setup
    private func setupCollectionView() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor(white: 250/255, alpha: 1)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            UINib(nibName: "collectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "collectionViewCell"
        )
        collectionView.register(
            BloggerProfileHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "BloggerProfileHeaderView"
        )
        view.addSubview(collectionView)
 
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}
 
// MARK: - UICollectionViewDataSource
extension BloggerProfileViewController: UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "collectionViewCell", for: indexPath
        ) as! collectionViewCell
 
        let post = posts[indexPath.item]
        let isFollowing = store.isFollowing( post.userName)
        cell.configure(with: post, isFollowing: isFollowing, isOwnPost: false)
        cell.applyStyle(isCard: true)
 
        cell.onLikeTapped = { [weak self] in
            guard let self else { return }
            self.store.toggleLike(for: post.id)
            self.loadPosts()
            collectionView.reloadItems(at: [indexPath])
        }
 
        cell.onFollowTapped = { [weak self] in
            guard let self else { return }
            self.store.toggleFollow(post.userName)
            self.loadPosts()
            collectionView.reloadData()
        }
 
        cell.onCommentTapped = { [weak self] in
            guard let self else { return }
            let vc = CommentsViewController()
            vc.postID = post.id
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 40
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.selectedDetentIdentifier = .medium
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                sheet.prefersEdgeAttachedInCompactHeight = true
            }
            self.present(vc, animated: true)
        }
 
        return cell
    }
 
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "BloggerProfileHeaderView",
            for: indexPath
        ) as! BloggerProfileHeaderView
 
        let isFollowing = store.isFollowing( bloggerUserName)
        let postCount = posts.count
        header.configure(userName: bloggerUserName, posts: postCount, isFollowing: isFollowing)
 
        header.onFollowTapped = { [weak self] in
            guard let self else { return }
            self.store.toggleFollow(self.bloggerUserName)
            self.loadPosts()
            collectionView.reloadData()
        }
 
        header.onFollowersTapped = { [weak self] in
            guard let self else { return }
            let vc = FollowersFollowingViewController()
            vc.initialSegment = 0
            vc.followerNames = ["Rishabh Kothari", "Tanmay Verma", "Mitali Shah"]
            vc.followingNames = Array(Set(self.store.getFollowingThreads().map { $0.userName }))
            self.navigationController?.pushViewController(vc, animated: true)
        }
 
        header.onFollowingTapped = { [weak self] in
            guard let self else { return }
            let vc = FollowersFollowingViewController()
            vc.initialSegment = 1
            vc.followerNames = ["Rishabh Kothari", "Tanmay Verma", "Mitali Shah"]
            vc.followingNames = Array(Set(self.store.getFollowingThreads().map { $0.userName }))
            self.navigationController?.pushViewController(vc, animated: true)
        }
 
        return header
    }
}
 
// MARK: - UICollectionViewDelegateFlowLayout
extension BloggerProfileViewController: UICollectionViewDelegateFlowLayout {
 
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 180)
    }
}
 
// MARK: - UICollectionViewDelegate
extension BloggerProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let post = posts[indexPath.item]
        let detailVC = ThreadDetailViewController()
        detailVC.thread = post
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
 
 
// MARK: - BloggerProfileHeaderView (programmatic)
final class BloggerProfileHeaderView: UICollectionReusableView {
 
    var onFollowTapped: (() -> Void)?
    var onFollowersTapped: (() -> Void)?
    var onFollowingTapped: (() -> Void)?
 
    private let profileImageView  = UIImageView()
    private let userNameLabel     = UILabel()
    private let followButton      = UIButton(type: .system)
 
    // Stat views
    private let postsStatView     = BloggerStatView()
    private let followersStatView = BloggerStatView()
    private let followingStatView = BloggerStatView()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupUI()
 
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTap))
        followersStatView.isUserInteractionEnabled = true
        followersStatView.addGestureRecognizer(followersTap)
 
        let followingTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTap))
        followingStatView.isUserInteractionEnabled = true
        followingStatView.addGestureRecognizer(followingTap)
    }
 
    required init?(coder: NSCoder) { fatalError() }
 
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
    }
 
    private func setupUI() {
        // Profile image — left side
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .systemGray5
        profileImageView.image = UIImage(systemName: "person.circle.fill")?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.systemGray3)
        addSubview(profileImageView)
 
        // Stats stack — right of image
        let statsStack = UIStackView(arrangedSubviews: [postsStatView, followersStatView, followingStatView])
        statsStack.translatesAutoresizingMaskIntoConstraints = false
        statsStack.axis = .horizontal
        statsStack.distribution = .fillEqually
        statsStack.spacing = 8
        addSubview(statsStack)
 
        // Username — below image
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        userNameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        userNameLabel.textColor = .label
        addSubview(userNameLabel)
 
        // Follow button — below username
        followButton.translatesAutoresizingMaskIntoConstraints = false
        followButton.layer.cornerRadius = 10
        followButton.layer.borderWidth = 1
        followButton.clipsToBounds = true
        followButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        followButton.addTarget(self, action: #selector(followTapped), for: .touchUpInside)
        addSubview(followButton)
 
        NSLayoutConstraint.activate([
            // Profile image — top left
            profileImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
 
            // Stats — right of image, vertically centred
            statsStack.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 20),
            statsStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            statsStack.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
 
            // Username — below profile image
            userNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            userNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            userNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
 
            // Follow button — below username, full width with insets
            followButton.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor, constant: 10),
            followButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            followButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            followButton.heightAnchor.constraint(equalToConstant: 36),
            followButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
 
    func configure(userName: String, posts: Int, isFollowing: Bool) {
        userNameLabel.text = userName
        postsStatView.configure(value: "\(posts)", label: "posts")
        followersStatView.configure(value: "—", label: "followers")
        followingStatView.configure(value: "—", label: "following")
        updateFollowButton(isFollowing: isFollowing)
    }
 
    private func updateFollowButton(isFollowing: Bool) {
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
 
    @objc private func handleFollowersTap() { onFollowersTapped?() }
    @objc private func handleFollowingTap() { onFollowingTapped?() }
 
    @objc private func followTapped() {
        onFollowTapped?()
    }
}
 
// MARK: - BloggerStatView
final class BloggerStatView: UIView {
    private let valueLabel = UILabel()
    private let titleLabel = UILabel()
 
    override init(frame: CGRect) {
        super.init(frame: frame)
        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 2
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        valueLabel.font = .systemFont(ofSize: 17, weight: .bold)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .center
        titleLabel.font = .systemFont(ofSize: 13)
        titleLabel.textColor = .secondaryLabel
        titleLabel.textAlignment = .center
    }
 
    required init?(coder: NSCoder) { fatalError() }
 
    func configure(value: String, label: String) {
        valueLabel.text = value
        titleLabel.text = label
    }
}
