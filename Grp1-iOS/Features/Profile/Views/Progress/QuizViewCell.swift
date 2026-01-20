//
//  QuizViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 17/12/25.
//

import UIKit

class QuizViewCell: UICollectionViewCell {
    @IBOutlet weak var quizNum: UILabel!
    @IBOutlet weak var quizDate: UILabel!
    @IBOutlet weak var quizAccuracy: UILabel!
    override func awakeFromNib() {
            super.awakeFromNib()
            contentView.layer.cornerRadius = 12
            contentView.layer.masksToBounds = true
        }

        func configure(with quiz: Quiz) {
            quizNum.text = quiz.title
            quizDate.text = quiz.date
            quizAccuracy.text = "\(quiz.accuracy)%"
        }

}
