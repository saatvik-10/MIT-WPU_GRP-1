//
//  recentsHeaderCollectionViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 18/12/25.
//

import UIKit

class recentsHeaderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var onClearTapped: (() -> Void)?

        override func awakeFromNib() {
            super.awakeFromNib()
            titleLabel.text = "Recents"
            titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        }
    @IBAction func clearButtonTapped(_ sender: UIButton) {
            onClearTapped?()
        }
}
