//
//  ProfileViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 13/01/26.
//

import UIKit

class ProgressViewCell: UICollectionViewCell {
    
    @IBOutlet weak var requirementNextLevel: UILabel!
    @IBOutlet weak var progressLevel: UILabel!
    @IBOutlet weak var progressPercentage: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        progressPercentage.progress = 0
        progressPercentage.layer.cornerRadius = 4
        progressPercentage.clipsToBounds = true
        
        progressPercentage.translatesAutoresizingMaskIntoConstraints = false
        progressPercentage.heightAnchor.constraint(equalToConstant: 8).isActive = true
    }
    
    func configure(level: Int, progressValue: Float) {
        progressLevel.text = "Level \(level)"
        
        progressPercentage.setProgress(progressValue, animated: true)
        
        let remainingPercent = Int((1.0 - progressValue) * 100)
        requirementNextLevel.text = "\(remainingPercent)% to Level \(level + 1)"
    }
}
