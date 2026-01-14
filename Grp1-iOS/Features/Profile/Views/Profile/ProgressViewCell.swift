//
//  ProfileViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 13/01/26.
//

import UIKit

class ProgressViewCell: UICollectionViewCell {
    
    @IBOutlet weak var progressPercent: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.layer.cornerRadius = 16
        contentView.clipsToBounds = true
        
        progress.progress = 0
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
    }
    
    func configure(title: String, progressValue: Float) {
        progressLabel.text = title
        progress.setProgress(progressValue, animated: true)
        
        let percentage = Int(progressValue * 100)
        progressPercent.text = "\(percentage)% completed"
    }
}
