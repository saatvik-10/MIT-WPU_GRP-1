//
//  OnboardingPageViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class OnboardingPageViewController: UIPageViewController {
    
    var pagesData: [OnboardingPage] = []
    var controllers : [UIViewController] = []
    var currentIndex : Int = 0
    
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

        // STEP 1 — Investment Level
        let step1 = onboardingStoryboard.instantiateViewController(
            withIdentifier: "OnboardingContentViewController"
        ) as! OnboardingContentViewController

        step1.loadViewIfNeeded()
        step1.configure(with: pagesData[0])
        step1.onNextTapped = { [weak self] in
            self?.goToNextPage()
        }

        // STEP 2 — Domain Selection
        let step2 = onboardingStoryboard.instantiateViewController(
            withIdentifier: "DomainSelectionViewController"
        ) as! DomainSelectionViewController

        step2.onNextTapped = { [weak self] in
            self?.goToNextPage()
        }
        
        step2.onBackTapped = { [weak self] in
            self?.goToPreviousPage()
        }


        controllers = [step1, step2]
        setViewControllers([controllers[0]],
                           direction: .forward,
                           animated: false)
    }

    
    func goToNextPage() {
        let nextIndex = currentIndex + 1

        if nextIndex < controllers.count {
            currentIndex = nextIndex
            setViewControllers(
                [controllers[currentIndex]],
                direction: .forward,
                animated: true
            )
        } else {
            print("Onboarding finished!")
        }
    }
    
    func goToPreviousPage() {
        let previousIndex = currentIndex - 1

        guard previousIndex >= 0 else { return }

        currentIndex = previousIndex

        setViewControllers(
            [controllers[currentIndex]],
            direction: .reverse,
            animated: true
        )
    }

}
