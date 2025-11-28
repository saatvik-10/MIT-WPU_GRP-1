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
            contentView.layer.cornerRadius = 16
            contentView.backgroundColor = .systemGray6
        }
    
    func configure(_ model: InterestModel) {
        domainTitle.text = model.title

            if let iconName = model.icon {
                domainImageView.image = UIImage(named: iconName)
                domainImageView.isHidden = false
            } else {
                domainImageView.isHidden = true
            }
        }


}
