//
//  JargonDetailViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 15/12/25.
//

import UIKit

class JargonDetailViewController: UIViewController {
    @IBOutlet weak var questionMark: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    var jargonWord: String?
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = jargonWord  
        questionMark.tintColor = AppTheme.shared.dominantColor
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
