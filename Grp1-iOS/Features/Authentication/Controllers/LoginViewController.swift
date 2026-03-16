//
//  LoginViewController.swift
//  Grp1-iOS
//

import UIKit
import AuthenticationServices

class LoginViewController: UIViewController,
                           ASAuthorizationControllerDelegate,
                           ASAuthorizationControllerPresentationContextProviding {

    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var subheadingLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        headingLabel.text = "Stay on top of your finance with us"
        subheadingLabel.text = "Understand the news, simplify complex jargon, practice with interactive games, and join a vibrant investor community."
    }

    // Apple login button action
    @IBAction func appleSignInTapped(_ sender: UIButton) {

        #if DEBUG
        // Mock login — skip Apple Sign In during development
        mockLogin()
        #else
        let request = AppleAuthManager.createRequest()
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        #endif
    }

    // MARK: - Mock Login (Development Only)

    #if DEBUG
    private func mockLogin() {
        let mockUser = AuthenticateUser(
            userId: "mock_user_\(UUID().uuidString.prefix(8))",
            email: nil,
            name: nil
        )

        SessionManager.shared.currentUser = mockUser
        KeyChainManager.saveUserId(mockUser.userId)
        UserDefaults.standard.set(true, forKey: "isLoggedIn")

        print("✅ Mock login successful — UserID: \(mockUser.userId)")

        // Navigate to profile input screen
        navigateToProfileInput()
    }
    #endif

    // MARK: - Apple Login Success

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {

        if let credential = authorization.credential as? ASAuthorizationAppleIDCredential {

            let userId = credential.user
            let email = credential.email
            let name = credential.fullName?.givenName

            let user = AuthenticateUser(userId: userId, email: email, name: name)
            SessionManager.shared.currentUser = user
            KeyChainManager.saveUserId(userId)
            UserDefaults.standard.set(true, forKey: "isLoggedIn")

            print("Login successful")
            print("UserID:", userId)

            // Navigate to profile input screen
            navigateToProfileInput()
        }
    }

    // MARK: - Apple Login Failure

    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithError error: Error) {
        print("Apple login failed:", error.localizedDescription)
    }

    // MARK: - Presentation Anchor

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window ?? UIWindow()
    }

    // MARK: - Navigation

    private func navigateToProfileInput() {
        let profileInputVC = ProfileInputViewController()
        profileInputVC.modalPresentationStyle = .fullScreen
        present(profileInputVC, animated: true)
    }
}

