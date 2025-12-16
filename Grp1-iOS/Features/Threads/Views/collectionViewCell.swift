//
//  collectionViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 10/12/25.
//

import UIKit

class collectionViewCell: UICollectionViewCell {
    var onMoreTapped: (() -> Void)?
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var threadImg: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var likesButton: UIButton!
    
    @IBOutlet weak var commentsButton: UIButton!
   
    @IBOutlet weak var sharesButton: UIButton!
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        onMoreTapped?()
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
        
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

            // Profile Img
            profileImg.contentMode = .scaleAspectFill
            profileImg.clipsToBounds = true

            // Username
            userNameLabel.numberOfLines = 1
            userNameLabel.lineBreakMode = .byTruncatingTail

            // Time Ago
            timeAgoLabel.font = UIFont.systemFont(ofSize: 15)
            timeAgoLabel.textColor = .secondaryLabel

            // Title
            titleLabel.numberOfLines = 0
            titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

            // Thread Image
            threadImg.contentMode = .scaleAspectFill
            threadImg.layer.cornerRadius = 12
        
            threadImg.clipsToBounds = true

            // Description Text
            descriptionLabel.numberOfLines = 0
            descriptionLabel.font = UIFont.systemFont(ofSize: 15)

            // Buttons Row
            likesButton.tintColor = .systemBlue
            commentsButton.tintColor = .systemBlue
            sharesButton.tintColor = .systemBlue

            // More Button
           // moreButton.setImage(UIImage(systemName: "ellipsis"), for: .normal)
            moreButton.tintColor = .secondaryLabel
        }

        // MARK: - Configure Cell
        func configure(with post: ThreadPost) {

            userNameLabel.text = post.userName
            timeAgoLabel.text = post.timeAgo
            titleLabel.text = post.title
            descriptionLabel.text = post.description

            // Profile
            profileImg.image = UIImage(named: post.userProfileImage)
                ?? UIImage(systemName: "person.circle.fill")

            // Thread Image
            if post.imageName.isEmpty {
                threadImg.isHidden = true
            } else {
                threadImg.isHidden = false
                threadImg.image = UIImage(named: post.imageName)
            }

            // Buttons numbers
            likesButton.setTitle("\(post.likes)", for: .normal)
            commentsButton.setTitle("\(post.comments)", for: .normal)
            sharesButton.setTitle("\(post.shares)", for: .normal)
        }
    }
