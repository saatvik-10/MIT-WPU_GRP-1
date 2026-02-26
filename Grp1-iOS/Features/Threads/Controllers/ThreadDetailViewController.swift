//
//  ThreadDetailViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class ThreadDetailViewController: UIViewController {

    var thread: ThreadPost!

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let profileImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let timeLabel = UILabel()

    private let tagsStackView = UIStackView()
    private let titleLabel = UILabel()
    private let postImageView = UIImageView()
    private let descriptionLabel = UILabel()

    private let divider = UIView()

    private let likeButton = UIButton(type: .system)
    private let likeCountLabel = UILabel()
    private let commentButton = UIButton(type: .system)
    private let commentCountLabel = UILabel()
    private let shareButton = UIButton(type: .system)
    private let shareCountLabel = UILabel()
    private let actionsStackView = UIStackView()

    private var isLiked = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureWithData()
    }

    // MARK: - Setup
    private func setupUI() {
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        // Profile Image
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 24
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.backgroundColor = .systemGray5

        // Username
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameLabel.font = .boldSystemFont(ofSize: 17)

        // Time
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = .systemFont(ofSize: 14)
        timeLabel.textColor = .secondaryLabel

        // Tags
        tagsStackView.translatesAutoresizingMaskIntoConstraints = false
        tagsStackView.axis = .horizontal
        tagsStackView.spacing = 8
        tagsStackView.alignment = .leading

        // Title
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 26)
        titleLabel.numberOfLines = 0

        // Post Image
        postImageView.translatesAutoresizingMaskIntoConstraints = false
        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 16

        // Description
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 17)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textColor = .label
        descriptionLabel.lineBreakMode = .byWordWrapping

        // Divider
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = .systemGray6

        // Actions
        actionsStackView.translatesAutoresizingMaskIntoConstraints = false
        actionsStackView.axis = .horizontal
        actionsStackView.spacing = 24
        actionsStackView.alignment = .center

        setupActionButtons()

        // Add subviews
        [profileImageView, usernameLabel, timeLabel,
         tagsStackView, titleLabel, postImageView,
         descriptionLabel, divider, actionsStackView].forEach {
            contentView.addSubview($0)
        }

        // Constraints
        NSLayoutConstraint.activate([
            // Profile image
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 48),
            profileImageView.heightAnchor.constraint(equalToConstant: 48),

            // Username
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor, constant: 4),
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            usernameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Time
            timeLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),
            timeLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),

            // Tags
            tagsStackView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            tagsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tagsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Title
            titleLabel.topAnchor.constraint(equalTo: tagsStackView.bottomAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Post Image
            postImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: 0.6),

            // Description
            descriptionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            // Divider
            divider.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            divider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            divider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            divider.heightAnchor.constraint(equalToConstant: 1),

            // Actions
            actionsStackView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            actionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            actionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32),
        ])
    }

    private func setupActionButtons() {
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        commentButton.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)

        [likeButton, commentButton, shareButton].forEach {
            $0.tintColor = .systemBlue
            $0.imageView?.contentMode = .scaleAspectFit
            $0.imageEdgeInsets = .zero
        }

        [likeCountLabel, commentCountLabel, shareCountLabel].forEach {
            $0.font = .systemFont(ofSize: 16)
            $0.textColor = .secondaryLabel
        }

        let likeStack   = makeActionItem(button: likeButton,    label: likeCountLabel)
        let commentStack = makeActionItem(button: commentButton, label: commentCountLabel)
        let shareStack  = makeActionItem(button: shareButton,   label: shareCountLabel)

        actionsStackView.addArrangedSubview(likeStack)
        actionsStackView.addArrangedSubview(commentStack)
        actionsStackView.addArrangedSubview(shareStack)

        likeButton.addTarget(self, action: #selector(didTapLike), for: .touchUpInside)
    }

    private func makeActionItem(button: UIButton, label: UILabel) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [button, label])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        return stack
    }

    private func makeTagLabel(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        label.backgroundColor = .systemGray6
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        // Padding via attributed string trick — use insets via a wrapper
        label.setContentHuggingPriority(.required, for: .horizontal)

        // Add padding
        let padding: CGFloat = 10
        label.widthAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true
        label.layoutMargins = UIEdgeInsets(top: 4, left: padding, bottom: 4, right: padding)

        // Use a container view for padding
        return label
    }

    // MARK: - Configure
    private func configureWithData() {
        guard let thread else { return }

        usernameLabel.text = thread.userName
        timeLabel.text = thread.timeAgo
        titleLabel.text = thread.title
        descriptionLabel.text = thread.description

        // Profile image
        profileImageView.image = UIImage(named: thread.userProfileImage)
            ?? UIImage(systemName: "person.circle.fill")

        // Post image
        if let imageName = thread.imageName {
            postImageView.isHidden = false
            if imageName.contains("/") {
                postImageView.image = UIImage(contentsOfFile: imageName)
            } else {
                postImageView.image = UIImage(named: imageName)
            }
        } else {
            postImageView.isHidden = true
            // When no image, link description directly to title
            NSLayoutConstraint.activate([
                descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20)
            ])
        }

        // Tags
        tagsStackView.arrangedSubviews.forEach {
            tagsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        for tag in thread.tags.prefix(3) {
            let pill = TagLabel()
            pill.text = "#\(tag)"
            pill.font = .systemFont(ofSize: 13, weight: .medium)
            pill.textColor = .secondaryLabel
            pill.backgroundColor = .systemGray6
            pill.layer.cornerRadius = 10
            pill.clipsToBounds = true
          //  pill.textInsets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
            tagsStackView.addArrangedSubview(pill)
        }

        // Counts
        likeCountLabel.text = "\(thread.likes)"
        commentCountLabel.text = "\(thread.comments.count)"
        shareCountLabel.text = "\(thread.shares)"

        isLiked = thread.isLiked
        updateLikeUI()
    }

    // MARK: - Actions
    @objc private func didTapLike() {
        isLiked.toggle()
        let updatedLikes = isLiked ? thread.likes + 1 : thread.likes - 1
        likeCountLabel.text = "\(updatedLikes)"
        updateLikeUI()
        ThreadsDataStore.shared.toggleLike(for: thread.id)
    }

    private func updateLikeUI() {
        let imageName = isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
        likeButton.tintColor = isLiked ? .systemRed : .systemBlue
    }
}















