//
//  ThreadDetailViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class ThreadDetailViewController: UIViewController {
    var thread: ThreadPost!
 
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let profileImageView = UIImageView()
    private let usernameLabel = UILabel()
    private let timeLabel = UILabel()

    private let postImageView = UIImageView()
    private let captionLabel = UILabel()

    private let actionsStackView = UIStackView()
    
    private let likeButton = UIButton(type: .system)
    private let likeCountLabel = UILabel()

    private let commentButton = UIButton(type: .system)
    private let commentCountLabel = UILabel()

    private let shareButton = UIButton(type: .system)
    private let shareCountLabel = UILabel()
    
    private var isLiked = false
    override func viewDidLoad() {
        
       
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

            setupUI()
            configureWithData()
    }
     

    
    @objc private func didTapLike() {
        isLiked.toggle()

        let updatedLikes = isLiked
            ? thread.likes + 1
            : thread.likes - 1

        likeCountLabel.text = "\(updatedLikes)"
        updateLikeUI()

        ThreadsDataStore.shared.toggleLike(for: thread.id)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    private func setupUI() {

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(captionLabel)
        contentView.addSubview(actionsStackView)

        setupStyles()
        setupActionButtons()
        setupConstraints()
    }
 
    private func setupStyles() {

        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        profileImageView.contentMode = .scaleAspectFill

        usernameLabel.font = .boldSystemFont(ofSize: 16)
        timeLabel.font = .systemFont(ofSize: 13)
        timeLabel.textColor = .secondaryLabel

        postImageView.contentMode = .scaleAspectFill
        postImageView.clipsToBounds = true
        postImageView.layer.cornerRadius = 12

        captionLabel.font = .systemFont(ofSize: 15)
        captionLabel.numberOfLines = 0

        actionsStackView.axis = .horizontal
        actionsStackView.spacing = 20
    }
  
    private func setupConstraints() {

        [scrollView, contentView,
         profileImageView, usernameLabel, timeLabel,
         postImageView, captionLabel, actionsStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([

            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Profile Image
            profileImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            profileImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileImageView.widthAnchor.constraint(equalToConstant: 40),
            profileImageView.heightAnchor.constraint(equalToConstant: 40),

            // Username
            usernameLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 12),
            usernameLabel.topAnchor.constraint(equalTo: profileImageView.topAnchor),

            // Time
            timeLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor),
            timeLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 4),

            // Post Image
            postImageView.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            postImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            postImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            postImageView.heightAnchor.constraint(equalTo: postImageView.widthAnchor, multiplier: 0.75),

            // Caption
            captionLabel.topAnchor.constraint(equalTo: postImageView.bottomAnchor, constant: 16),
            captionLabel.leadingAnchor.constraint(equalTo: postImageView.leadingAnchor),
            captionLabel.trailingAnchor.constraint(equalTo: postImageView.trailingAnchor),

            // Actions
            actionsStackView.topAnchor.constraint(equalTo: captionLabel.bottomAnchor, constant: 20),
            actionsStackView.leadingAnchor.constraint(equalTo: captionLabel.leadingAnchor),
            actionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    
    private func configureWithData() {
        guard let thread else { return }

        usernameLabel.text = thread.userName
        timeLabel.text = thread.timeAgo
        captionLabel.text = thread.description
        postImageView.image = UIImage(named: thread.imageName)
        profileImageView.image = UIImage(named: "beach_1")
        
        likeCountLabel.text = "\(thread.likes)"
           commentCountLabel.text = "\(thread.comments)"
           shareCountLabel.text = "\(thread.shares)"
        
        isLiked = thread.isLiked
            updateLikeUI()
    }
    
    private func setupActionButtons() {

        // Icons
        likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
        commentButton.setImage(UIImage(systemName: "bubble.right"), for: .normal)
        shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)

        // Tint
        [likeButton, commentButton, shareButton].forEach {
            $0.tintColor = .systemBlue
        }

        // Counts
        [likeCountLabel, commentCountLabel, shareCountLabel].forEach {
            $0.font = .systemFont(ofSize: 14)
            $0.textColor = .systemBlue
        }

        // Small stacks (icon + count)
        let likeStack = makeActionItem(button: likeButton, label: likeCountLabel)
        let commentStack = makeActionItem(button: commentButton, label: commentCountLabel)
        let shareStack = makeActionItem(button: shareButton, label: shareCountLabel)

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
    
    private func updateLikeUI() {
        let imageName = isLiked ? "heart.fill" : "heart"
        likeButton.setImage(UIImage(systemName: imageName), for: .normal)
    }
}
