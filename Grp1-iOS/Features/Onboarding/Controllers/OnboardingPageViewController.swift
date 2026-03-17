import UIKit

class OnboardingPageViewController: UIPageViewController {

    private var controllers: [UIViewController] = []
    private var currentIndex: Int = 0

    var selectedLevel: String?
    var selectedDomains: [String] = []
    var selectedInterests: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupControllers()
    }

    private func setupControllers() {
        let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)

        // STEP 1 — Investment Level
        let step1 = storyboard.instantiateViewController(
            withIdentifier: "OnboardingContentViewController"
        ) as! OnboardingContentViewController

        step1.loadViewIfNeeded()
        step1.configure(
            with: OnboardingPage(
                title: "Select your investment experience level",
                options: [
                    (title: "Beginner", subtitle: "Just starting my financial journey"),
                    (title: "Intermediate", subtitle: "I have some experience"),
                    (title: "Advanced", subtitle: "I understand markets")
                ]
            )
        )

        step1.onOptionSelected = { [weak self] selected in
            self?.selectedLevel = selected
        }

        step1.onNextTapped = { [weak self] in
            self?.goToNextPage()
        }

        // STEP 2 — Interest Selection
        let step2 = storyboard.instantiateViewController(
            withIdentifier: "InterestCollectionViewController"
        ) as! InterestCollectionViewController

        step2.onFinishTapped = { [weak self] in
            if let indexPaths = step2.interestCollectionView.indexPathsForSelectedItems {
                self?.selectedInterests = indexPaths.map { preferences[$0.item].title }
            }
            self?.submitOnboardingToBackend()
        }

        step2.onBackTapped = { [weak self] in
            self?.goToPreviousPage()
        }

        controllers = [step1, step2]

        setViewControllers(
            [controllers[0]],
            direction: .forward,
            animated: false
        )
    }

    // MARK: - Navigation

    func goToNextPage() {
        guard currentIndex + 1 < controllers.count else {
            print("Onboarding finished")
            return
        }
        currentIndex += 1
        setViewControllers(
            [controllers[currentIndex]],
            direction: .forward,
            animated: true
        )
    }

    func goToPreviousPage() {
        guard currentIndex - 1 >= 0 else { return }
        currentIndex -= 1
        setViewControllers(
            [controllers[currentIndex]],
            direction: .reverse,
            animated: true
        )
    }

    // MARK: - Submission (saves to DATABASE via API)

    func submitOnboardingToBackend() {
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("❌ No auth token found")
            return
        }

        let api = OnboardingAPIService.shared

        // 1) Save level
        if let level = selectedLevel {
            api.saveLevel(level, token: token) { success in
                print("Level saved to DB: \(success)")
            }
        }

        // 2) Fetch available interests from DB, match by name, then POST each
        api.fetchAvailableInterests { [weak self] availableInterests in
            guard let self = self else { return }

            let allSelected = self.selectedDomains + self.selectedInterests

            for selected in allSelected {
                if let match = availableInterests.first(where: {
                    ($0["name"] as? String)?.lowercased() == selected.lowercased()
                }),
                   let interestId = match["id"] as? String {
                    api.saveInterest(interestId: interestId, token: token) { success in
                        print("Saved interest '\(selected)' to DB: \(success)")
                    }
                }
            }

            // 3) Mark onboarding as complete and navigate to Home
            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: "hasOnboarding")
                print("✅ Onboarding complete — navigating to Home")
                self.navigateToHome()
            }
        }
    }

    func navigateToHome() {
        let storyboard = UIStoryboard(name: "HomeMain", bundle: nil)
        if let homeVC = storyboard.instantiateInitialViewController() {
            // Set as root so user can't swipe back
            if let window = self.view.window {
                window.rootViewController = homeVC
                UIView.transition(with: window, duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: nil)
            }
        }
    }
}

