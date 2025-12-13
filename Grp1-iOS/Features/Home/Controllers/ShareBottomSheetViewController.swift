import UIKit

class ShareBottomSheetViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var tableView: UITableView!

    let friends = ["Ritik Sharma", "Raj Verma", "Naman Gupta"]

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        containerView.layer.cornerRadius = 22
        containerView.layer.masksToBounds = true

        tableView.dataSource = self
        tableView.delegate = self
    }

    @IBAction func dismissSheet(_ sender: Any) {
        dismiss(animated: true)
    }
}

extension ShareBottomSheetViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = friends[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        cell.imageView?.image = UIImage(systemName: "person.circle")
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Shared with: \(friends[indexPath.row])")
        dismiss(animated: true)
    }
}

extension UIApplication {
    /// The key window for the current active scene
    var keyWindowInConnectedScenes: UIWindow? {
        return connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}

extension UIViewController {
    /// Safely find the top-most presented view controller
    func topMostViewController() -> UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController()
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController() ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController() ?? tab
        }
        return self
    }
}
