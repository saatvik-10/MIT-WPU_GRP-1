//
//  DomainViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class DomainCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var domainIconView: UIImageView!
    @IBOutlet weak var domainName: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            
        }
    
    func configure(_ model: DomainModel) {
        domainName.text = model.title
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        contentView.backgroundColor = .white
        if let iconName = model.icon {
                domainIconView.image = UIImage(systemName: iconName)
                domainIconView.tintColor = .black
                domainIconView.isHidden = false
            } else {
                domainIconView.isHidden = true
            }
        }


}
