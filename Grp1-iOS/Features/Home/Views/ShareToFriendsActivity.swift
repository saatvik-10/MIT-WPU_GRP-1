import UIKit

class ShareToFriendsActivity: UIActivity {

    var article: NewsArticle?

    override var activityTitle: String? {
        return "Share to Friends"
    }

    override var activityImage: UIImage? {
        return UIImage(systemName: "person.3.fill")
    }

    override class var activityCategory: UIActivity.Category {
        return .share
    }

    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }

    override func perform() {
        print("Sharing to friends inside the app")

        // 1. Get the key window’s root VC
        guard let root = UIApplication.shared.keyWindowInConnectedScenes?.rootViewController else {
            print("❌ No key window / rootViewController found")
            activityDidFinish(false)
            return
        }

        // 2. Find the top-most VC to present from
        let topVC = root.topMostViewController()

        // 3. Create bottom-sheet
        let sheetVC = ShareBottomSheetViewController(
            nibName: "ShareBottomSheetViewController",
            bundle: nil
        )
        sheetVC.modalPresentationStyle = .overFullScreen
        sheetVC.modalTransitionStyle = .crossDissolve

        // 4. Present
        topVC.present(sheetVC, animated: true) { [weak self] in
            self?.activityDidFinish(true)
        }
    }
}
