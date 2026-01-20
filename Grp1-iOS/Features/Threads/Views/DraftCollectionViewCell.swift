//
//  DraftCollectionViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class DraftCollectionViewCell: UICollectionViewCell {

//    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var draftImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contentView.layer.cornerRadius = 16
                contentView.layer.masksToBounds = true

                // Cell itself should not clip
                clipsToBounds = false

                // Image fills the card
                draftImgView.contentMode = .scaleAspectFill
                draftImgView.clipsToBounds = true
            }

            func configure(imageName: String) {
                draftImgView.image = UIImage(named: imageName)
            }
    }


