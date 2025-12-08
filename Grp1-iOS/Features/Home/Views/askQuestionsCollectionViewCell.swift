//
//  askQuestionsCollectionViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 08/12/25.
//

import UIKit

class askQuestionsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
            super.awakeFromNib()
            
            contentView.backgroundColor = UIColor.systemBackground
            contentView.layer.cornerRadius = 20
            contentView.layer.masksToBounds = true
            
            // TEXT STYLING
            questionLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            questionLabel.textColor = .black
            questionLabel.numberOfLines = 0
            
            answerLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            answerLabel.textColor = .darkGray
            answerLabel.numberOfLines = 0
            
            timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            timeLabel.textColor = .gray
        }

        func configureCell(with qa: ArticleQA) {
            questionLabel.text = qa.question
            answerLabel.text = qa.answer
            
            // Format date to time string (e.g. 12:45 PM)
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            timeLabel.text = formatter.string(from: qa.createdAt)
        }

}
