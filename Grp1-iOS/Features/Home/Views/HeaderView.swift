//
//  HeaderView.swift
//  TravelDestinationsApp
//
//  Created by SDC-USER on 21/11/25.
//

import UIKit

class HeaderView: UICollectionReusableView {

    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        headerLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        headerLabel.textColor = .label       // auto adjusts for dark/light mode
    }
}
