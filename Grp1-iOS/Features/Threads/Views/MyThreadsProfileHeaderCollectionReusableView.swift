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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupUI()
    }
    
    private func setupUI() {
            backgroundColor = .clear
            
            profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
            profileImageView.clipsToBounds = true
            
        userNameLabel.font = .systemFont(ofSize: 18, weight: .medium)
            
            [postsCountLabel, followersCountLabel, followingCountLabel].forEach {
                $0?.font = .systemFont(ofSize: 15, weight: .medium)
                $0?.textColor = .black
                $0?.numberOfLines = 0
                $0?.textAlignment = .left
            }
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
