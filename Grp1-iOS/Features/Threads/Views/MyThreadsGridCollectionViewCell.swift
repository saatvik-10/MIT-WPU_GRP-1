//
//  MyThreadsGridCollectionViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class MyThreadsGridCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        postImageView.layer.cornerRadius = 16
                postImageView.clipsToBounds = true
                backgroundColor = .clear
    }
    func configure(imageName: String) {
            postImageView.image = UIImage(named: imageName)
        }
}
