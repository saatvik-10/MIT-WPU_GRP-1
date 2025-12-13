//
//  DomainViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class DomainViewCell: UICollectionViewCell {
    @IBOutlet weak var domainImageView: UIImageView!
    @IBOutlet weak var domainTitle: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            
        }
    
    func configure(_ model: InterestModel) {
        domainTitle.text = model.title
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
            if let iconName = model.icon {
                domainImageView.image = UIImage(systemName: iconName)
                domainImageView.tintColor = .black
                domainImageView.isHidden = false
            } else {
                domainImageView.isHidden = true
            }
        }


}
