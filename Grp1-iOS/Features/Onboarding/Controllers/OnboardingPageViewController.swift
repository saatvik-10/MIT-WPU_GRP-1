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
        loadPageData()
        // Do any additional setup after loading the view.
        setupControllers()
    }
    func loadPageData(){
        pagesData = [
                OnboardingPage(
                    title: "What’s your investment level?",
                    options: [
                        (title: "Beginner",subtitle: "Just starting my Financial Journey"),
                        (title: "Intermediate",subtitle: "I have some experience"),
                        (title: "Advanced",subtitle: "I understand markets")
                    ]
                )
        ]
    }
    
    func setupControllers() {

        let onboardingStoryboard = UIStoryboard(name: "Onboarding", bundle: nil)

        controllers = pagesData.map { page in
            let vc = onboardingStoryboard.instantiateViewController(
                withIdentifier: "OnboardingContentViewController"
            ) as! OnboardingContentViewController
            
            vc.loadViewIfNeeded()

            vc.configure(with: page)

            vc.onOptionSelected = { selected in
                print("Selected \(selected)")
            }

            return vc
        }

        if let first = controllers.first {
            setViewControllers([first], direction: .forward, animated: false)
        }
    }
    
    func goToNextPage(){
        guard let currentVC = viewControllers?.first,
              let index = controllers.firstIndex(of: currentVC as! OnboardingContentViewController) else { return }

                if index + 1 < controllers.count {
                    setViewControllers([controllers[index + 1]], direction: .forward, animated: true)
                } else {
                    print("Onboarding finished!")
                }
        }

}
