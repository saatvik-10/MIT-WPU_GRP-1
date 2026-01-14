//
//  InterestsViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 14/01/26.
//

import UIKit

class InterestsViewCell: UICollectionViewCell {

    @IBOutlet var interestLabels: [UILabel]!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(interests: [String]) {
        for (index, label) in interestLabels.enumerated() {
            if index < interests.count {
                label.text = interests[index]
                label.isHidden = false
            } else {
                label.isHidden = true
            }
        }
    }

}
