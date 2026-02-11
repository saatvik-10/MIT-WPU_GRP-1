//
//  DraftCollectionViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 09/01/26.
//

import UIKit

class DraftCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var draftImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
        clipsToBounds = false
        
        
        draftImgView.contentMode = .scaleAspectFill
        draftImgView.clipsToBounds = true
    }
    
    func configure(imagePath: String?) {
            if let path = imagePath {
                let url = URL(fileURLWithPath: path)
                draftImgView.image = UIImage(contentsOfFile: url.path)
                draftImgView.isHidden = false
            } else {
                draftImgView.image = nil
                draftImgView.isHidden = false // show grey placeholder if you want
                draftImgView.backgroundColor = .systemGray5
            }
        }
} 
