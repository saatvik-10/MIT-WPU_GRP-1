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

        titleLabel.text = jargonWord   // or wherever you want to show it
        questionMark.tintColor = AppTheme.shared.dominantColor
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
}
