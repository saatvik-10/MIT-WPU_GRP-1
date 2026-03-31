//
//  CommentTableViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 11/02/26.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var commentLabel: UILabel!
    
   
    @IBOutlet weak var likeButton: UIButton!
    
    var onLikeTapped: (() -> Void)?
        var onReplyTapped: (() -> Void)?

        override func awakeFromNib() {
            super.awakeFromNib()
            selectionStyle = .none

            profileImageView.layer.cornerRadius = 20
            profileImageView.clipsToBounds = true
            commentLabel.numberOfLines = 0
            nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
            commentLabel.font = .systemFont(ofSize: 16)

            preservesSuperviewLayoutMargins = false
            contentView.preservesSuperviewLayoutMargins = false
            separatorInset = .zero
            layoutMargins = .zero
        }

    @IBAction func didTapLike(_ sender: UIButton) {
        onLikeTapped?()
    }

        func configure(with comment: Comment) {
            nameLabel.text = comment.userName
            commentLabel.text = comment.text

            if let image = UIImage(named: comment.userProfileImage) {
                profileImageView.image = image
            } else if let systemImage = UIImage(systemName: comment.userProfileImage) {
                profileImageView.image = systemImage
            } else {
                profileImageView.image = UIImage(systemName: "person.circle.fill")
            }

            let imageName = comment.isLiked ? "heart.fill" : "heart"
            likeButton.setImage(UIImage(systemName: imageName), for: .normal)
            likeButton.tintColor = comment.isLiked ? .systemRed : .systemGray
        }
    }
