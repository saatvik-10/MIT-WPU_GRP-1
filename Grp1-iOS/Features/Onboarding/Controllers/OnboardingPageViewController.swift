//
//  OnboardingPageViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class OnboardingPageViewController: UIPageViewController {
    
    var pagesData: [OnboardingPage] = []
    var controllers : [OnboardingContentViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    func loadPageData(){
        pagesData = [
            OnboardingPage(
                title: "What's your investment level",
                message: "Help us to personalize your investment journey"),
            OnboardingPage(
                title: "",
                message: ""),
            OnboardingPage(
                title: "",
                message: "")
        ]
    }

}
