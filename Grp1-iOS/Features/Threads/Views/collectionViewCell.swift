//
//  collectionViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class collectionViewCell: UICollectionViewCell {
    var onFollowTapped: (() -> Void)?
    var isFollowingUser: Bool = false
    var shouldShowFollowAction: Bool = true
    var onMoreTapped: (() -> Void)?
    var onLikeTapped: (() -> Void)?
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    
    @IBOutlet weak var tagsStackView: UIStackView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var threadImg: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var likesButton: UIButton!
    
    @IBOutlet weak var commentsButton: UIButton!
    
    @IBOutlet weak var sharesButton: UIButton!
    
    //    @IBAction func moreButtonTapped(_ sender: UIButton) {
    //        onMoreTapped?()
    //    }
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        onLikeTapped?()
    }
    
    @IBOutlet weak var dividerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        setupMoreMenu()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImg.layer.cornerRadius = profileImg.frame.width / 2
        profileImg.clipsToBounds = true
    }
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        
        layoutIfNeeded()
        
        let size = contentView.systemLayoutSizeFitting(
            CGSize(
                width: layoutAttributes.frame.width,
                height: UIView.layoutFittingCompressedSize.height
            )
        )
        
        var frame = layoutAttributes.frame
        frame.size.height = ceil(size.height)
        layoutAttributes.frame = frame
        
        return layoutAttributes
    }
    private func setupUI() {
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        
        backgroundColor = .clear
        
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = 0.3
        
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
        
        
        profileImg.contentMode = .scaleAspectFill
        profileImg.clipsToBounds = true
        
        
        userNameLabel.numberOfLines = 1
        userNameLabel.lineBreakMode = .byTruncatingTail
        
        
        timeAgoLabel.font = UIFont.systemFont(ofSize: 16)
        timeAgoLabel.textColor = .secondaryLabel
        
        
        titleLabel.numberOfLines = 0
        //  titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        
        
        threadImg.contentMode = .scaleAspectFill
        threadImg.layer.cornerRadius = 12
        
        threadImg.clipsToBounds = true
        
        
        descriptionLabel.numberOfLines = 0
        //descriptionLabel.font = UIFont.systemFont(ofSize: 15)
        
        
        // likesButton.tintColor = .systemBlue
        var config = UIButton.Configuration.plain()
        config.imagePadding = 6
        likesButton.configuration = config
        commentsButton.tintColor = .systemBlue
        sharesButton.tintColor = .systemBlue
        
        
        // moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        moreButton.tintColor = .secondaryLabel
    }
    
    private func makeTagLabel(text: String) -> UILabel {
        let label = TagLabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
        label.backgroundColor = UIColor.systemGray6
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.textAlignment = .center
        
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        return label
    }
    
    
    func applyStyle(isCard: Bool) {
        
        if isCard {
            
            contentView.backgroundColor = .white
            contentView.layer.cornerRadius = 16
            
            layer.cornerRadius = 16
            layer.shadowOpacity = 0.08
        } else {
            
            contentView.backgroundColor = .clear
            contentView.layer.cornerRadius = 0
            
            layer.cornerRadius = 0
            layer.shadowOpacity = 0
        }
        dividerView.isHidden = isCard
    }
    
    
    //    func configure(with post: ThreadPost, isFollowing: Bool) {
    //
    //
    //        self.isFollowingUser = isFollowing
    //
    //
    //        userNameLabel.text = post.userName
    //        timeAgoLabel.text = post.timeAgo
    //        titleLabel.text = post.title
    //        descriptionLabel.text = post.description
    //
    //
    //        profileImg.image = UIImage(named: post.userProfileImage)
    //        ?? UIImage(systemName: "person.circle.fill")
    //
    //
    //        if let imageName = post.imageName {
    //            threadImg.isHidden = false
    //            threadImg.image = UIImage(named: imageName)
    //        } else {
    //            threadImg.isHidden = true
    //            threadImg.image = nil
    //        }
    //
    //
    //        //            likesButton.setTitle("\(post.likes)", for: .normal)
    //        //            let heartName = post.isLiked ? "heart.fill" : "heart"
    //        //            likesButton.setImage(UIImage(systemName: heartName), for: .normal)
    //        //            likesButton.tintColor = post.isLiked ? .systemRed : .systemBlue
    //
    //        likesButton.setTitle("\(post.likes)", for: .normal)
    //       // likesButton.setTitleColor(.systemBlue, for: .normal)  ??
    //
    //
    //        let heartName = post.isLiked ? "heart.fill" : "heart"
    //        let heartImage = UIImage(systemName: heartName)?
    //            .withRenderingMode(.alwaysTemplate)
    //
    //        likesButton.setImage(heartImage, for: .normal)
    //        likesButton.tintColor = post.isLiked ? .systemRed : .systemBlue
    //
    //
    //        commentsButton.setTitle("\(post.comments)", for: .normal)
    //        sharesButton.setTitle("\(post.shares)", for: .normal)
    //
    //
    //
    //        tagsStackView.arrangedSubviews.forEach {
    //            tagsStackView.removeArrangedSubview($0)
    //            $0.removeFromSuperview()
    //        }
    //
    //        let tags = Array(post.tags.prefix(3)) // max 3 tags
    //
    //        if tags.isEmpty {
    //            tagsStackView.isHidden = true
    //        } else {
    //            tagsStackView.isHidden = false
    //
    //            for tag in tags {
    //                let tagLabel = makeTagLabel(text: tag)
    //                tagsStackView.addArrangedSubview(tagLabel)
    //            }
    //        }
    //
    //
    //
    //    }
    //
    func configure(with post: ThreadPost, isFollowing: Bool, isOwnPost: Bool) {
        
        
        self.isFollowingUser = isFollowing
        self.shouldShowFollowAction = !isOwnPost
        
       
        userNameLabel.text = post.userName
        timeAgoLabel.text = post.timeAgo
        titleLabel.text = post.title
        descriptionLabel.text = post.description
        
        profileImg.image = UIImage(named: post.userProfileImage)
        ?? UIImage(systemName: "person.circle.fill")
        
      
        if let imageName = post.imageName {
            threadImg.isHidden = false
            threadImg.image = UIImage(named: imageName)
        } else {
            threadImg.isHidden = true
            threadImg.image = nil
        }
        
       
        likesButton.setTitle("\(post.likes)", for: .normal)
        
        let heartName = post.isLiked ? "heart.fill" : "heart"
        likesButton.setImage(
            UIImage(systemName: heartName),
            for: .normal
        )
        likesButton.tintColor = post.isLiked ? .systemRed : .systemBlue
        
   
        commentsButton.setTitle("\(post.comments)", for: .normal)
        sharesButton.setTitle("\(post.shares)", for: .normal)
        
        // TAGS
        tagsStackView.arrangedSubviews.forEach {
            tagsStackView.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        
        let tags = Array(post.tags.prefix(3))
        tagsStackView.isHidden = tags.isEmpty
        
        for tag in tags {
            let label = makeTagLabel(text: tag)
            tagsStackView.addArrangedSubview(label)
        }
        
        
        setupMoreMenu()
    }
    
    
    //    private func setupMoreMenu() {
    //
    //        let followAction = UIAction(
    //            title: "Follow",
    //            image: UIImage(systemName: "person.badge.plus")
    //        ) { _ in
    //
    //        }
    //
    //        let bookmarkAction = UIAction(
    //            title: "Bookmark",
    //            image: UIImage(systemName: "bookmark")
    //        ) { _ in
    //
    //        }
    //
    //        let reportAction = UIAction(
    //            title: "Report this user",
    //            image: UIImage(systemName: "flag"),
    //            attributes: .destructive
    //        ) { _ in
    //
    //        }
    //
    //        let blockAction = UIAction(
    //            title: "Block user",
    //            image: UIImage(systemName: "hand.raised"),
    //            attributes: .destructive
    //        ) { _ in
    //
    //        }
    //
    //        let notInterestedAction = UIAction(
    //            title: "Not interested in this post",
    //            image: UIImage(systemName: "exclamationmark.triangle")
    //        ) { _ in
    //
    //        }
    //
    //        moreButton.menu = UIMenu(
    //            title: "",
    //            children: [
    //                followAction,
    //                bookmarkAction,
    //                reportAction,
    //                blockAction,
    //                notInterestedAction
    //            ]
    //        )
    //
    //        moreButton.showsMenuAsPrimaryAction = true
    //    }
    //}
    private func setupMoreMenu() {
        
        var actions: [UIAction] = []
        
        if shouldShowFollowAction {
                let followTitle = isFollowingUser ? "Unfollow" : "Follow"
                let followImageName = isFollowingUser
                    ? "person.badge.minus"
                    : "person.badge.plus"

                let followAction = UIAction(
                    title: followTitle,
                    image: UIImage(systemName: followImageName)
                ) { [weak self] _ in
                    self?.onFollowTapped?()
                }

                actions.append(followAction)
            }
        
        let bookmarkAction = UIAction(
            title: "Bookmark",
            image: UIImage(systemName: "bookmark")
        ) { _ in }
        
        let reportAction = UIAction(
            title: "Report this user",
            image: UIImage(systemName: "flag"),
            attributes: .destructive
        ) { _ in }
        
        let blockAction = UIAction(
            title: "Block user",
            image: UIImage(systemName: "hand.raised"),
            attributes: .destructive
        ) { _ in }
        
        let notInterestedAction = UIAction(
            title: "Not interested in this post",
            image: UIImage(systemName: "exclamationmark.triangle")
        ) { _ in }
        
        actions.append(contentsOf: [
            bookmarkAction,
            reportAction,
            blockAction,
            notInterestedAction
        ])
        
        moreButton.menu = UIMenu(title: "", children: actions)
           moreButton.showsMenuAsPrimaryAction = true
    }
}
