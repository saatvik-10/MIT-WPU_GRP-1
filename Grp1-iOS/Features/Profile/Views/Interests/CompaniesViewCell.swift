//
//  CompaniesViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 28/11/25.
//

import UIKit

class CompaniesViewCell: UICollectionViewCell {

    @IBOutlet weak var companyName: UILabel!
    @IBOutlet weak var companySymbol: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(_ model: InterestModel) {
        companyName.text = model.title
        companySymbol.text = model.subtitle
    }

}
