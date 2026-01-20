import UIKit

class OnboardingPageViewController: UIPageViewController {

    private var controllers: [UIViewController] = []
    private var currentIndex: Int = 0

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

        step1.onNextTapped = { [weak self] in
            self?.goToNextPage()
        }

        // STEP 2 — Domain Selection
        let step2 = storyboard.instantiateViewController(
            withIdentifier: "DomainSelectionViewController"
        ) as! DomainSelectionViewController

        step2.loadViewIfNeeded()

        step2.onNextTapped = { [weak self] in
            self?.goToNextPage()
        }

        step2.onBackTapped = { [weak self] in
            self?.goToPreviousPage()
        }

        // STEP 3 — Interest Selection
        let step3 = storyboard.instantiateViewController(
            withIdentifier: "InterestCollectionViewController"
        ) as! InterestCollectionViewController

        step3.onBackTapped = { [weak self] in
            self?.goToPreviousPage()
        }

        controllers = [step1, step2, step3]

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
}

