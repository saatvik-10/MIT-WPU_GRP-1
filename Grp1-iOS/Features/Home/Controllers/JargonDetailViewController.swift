//
//  JargonDetailViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit

class JargonDetailViewController: UIViewController {
    @IBOutlet weak var questionMark: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var jargonWord: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.shared.dominantColor.withAlphaComponent(0.1)

        titleLabel.text = selectedWord.word
        questionMark.tintColor = AppTheme.shared.dominantColor
        
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
