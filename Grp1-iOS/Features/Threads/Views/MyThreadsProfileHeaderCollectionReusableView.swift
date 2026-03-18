//
//  MyThreadsProfileHeaderCollectionReusableView.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class MyThreadsProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var followingCountLabel: UILabel!
   
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var postsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
   // @IBOutlet weak var gridTitleLabel: UILabel!
    
    var onFollowersTapped: (() -> Void)?
        var onFollowingTapped: (() -> Void)?
        
        override func awakeFromNib() {
            super.awakeFromNib()
            setupUI()
     
            let followersTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowersTap))
            followersCountLabel.isUserInteractionEnabled = true
            followersCountLabel.addGestureRecognizer(followersTap)
     
            let followingTap = UITapGestureRecognizer(target: self, action: #selector(handleFollowingTap))
            followingCountLabel.isUserInteractionEnabled = true
            followingCountLabel.addGestureRecognizer(followingTap)
        }
     
        @objc private func handleFollowersTap() { onFollowersTapped?() }
        @objc private func handleFollowingTap() { onFollowingTapped?() }
        override func layoutSubviews() {
               super.layoutSubviews()
               // Ensure circular image AFTER Auto Layout
               profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
           }
        
        private func setupUI() {
                backgroundColor = .clear
                
                //profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
                profileImageView.clipsToBounds = true
                
           // userNameLabel.font = .systemFont(ofSize: 18, weight: .medium)
            userNameLabel.textColor = .black
            
                [postsCountLabel, followersCountLabel, followingCountLabel].forEach {
                    //$0?.font = .systemFont(ofSize: 15, weight: .medium)
                    $0?.textColor = .black
                    $0?.numberOfLines = 0
                    $0?.textAlignment = .left
                }
    //        gridTitleLabel.text = "Posts"
    //                gridTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
    //                gridTitleLabel.textColor = .darkGray
    //                gridTitleLabel.textAlignment = .center
         }
            
            func configure(
                userName: String,
                profileImage: String,
                posts: Int,
                followers: Int,
                following: Int
            ) {
                userNameLabel.text = userName
                profileImageView.image = UIImage(named: profileImage)
                
                postsCountLabel.text = "\(posts)\nposts"
                followersCountLabel.text = "\(followers)\nfollowers"
                followingCountLabel.text = "\(following)\nfollowing"
            }
        
        
    }  
