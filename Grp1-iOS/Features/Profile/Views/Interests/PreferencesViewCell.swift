//
//  InterestCollectionViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class PreferencesViewCell: UICollectionViewCell {
    
    @IBOutlet weak var interestIconView: UIImageView!
    @IBOutlet weak var interestLabel: UILabel!
    @IBOutlet weak var subtitleInterestLabel: UILabel!
    
    let config = UIImage.SymbolConfiguration(weight: .light)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        contentView.layer.cornerRadius = 16
        contentView.backgroundColor = UIColor.white
    }
    
    func configure(_ model: InterestModel) {
        interestLabel.text = model.title
        subtitleInterestLabel.text = model.subtitle
        
        if let iconName = model.icon {
            interestIconView.image = UIImage(systemName: iconName ,withConfiguration: config)
            interestIconView.tintColor = .systemBlue
            interestIconView.isHidden = false
        } else {
            interestIconView.isHidden = true
        }
    }
}
