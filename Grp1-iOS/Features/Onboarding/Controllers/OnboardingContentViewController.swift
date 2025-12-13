//
//  OnboardingContentViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 11/12/25.
//
import UIKit

class OnboardingContentViewController : UIViewController {
    
    @IBOutlet weak var stepHeaderLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stepHeaderLabel.layer.cornerRadius = 10
    }
    
}
