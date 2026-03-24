import Foundation

class AuthenticationService {
    static let shared = AuthenticationService()
    private let apiService = APIService.shared
    private let credentialStorage = CredentialStorageService.shared

    // MARK: - Sign Up

    func signUp(
        name: String,
        email: String,
        password: String,
        phone: String,
        level: String,
        dob: String,
        gender: String,
        hasOnboarding: Bool,
        profileImageData: Data? = nil,       // ✅ actual image bytes from the view
        profileImageFileName: String? = nil, // ✅ e.g. "avatar.jpg"
        completion: @escaping (Bool, String?) -> Void
    ) {
        let levelEnum: APILevel
        switch level.uppercased() {
        case "BEGINNER":              levelEnum = .beginner
        case "INTERMEDIATE":          levelEnum = .intermediate
        case "ADVANCE", "ADVANCED":   levelEnum = .advance
        default:                      levelEnum = .beginner
        }

        let genderEnum: APIGender
        switch gender.uppercased() {
        case "MALE":           genderEnum = .male
        case "FEMALE":         genderEnum = .female
        case "OTHER", "OTHERS": genderEnum = .others
        default:               genderEnum = .male
        }

        let payload = APISignUpRequest(
            name: name,
            email: email,
            password: password,
            phone: phone,
            level: levelEnum,
            dob: dob,
            gender: genderEnum,
            hasOnboarding: hasOnboarding,
            profileImageData: profileImageData,
            profileImageFileName: profileImageFileName ?? "avatar.jpg"
        )

        apiService.signUp(payload: payload) { result in
            switch result {
            case .success:
                let saved = self.credentialStorage.saveCredentials(email: email, password: password)
                DispatchQueue.main.async {
                    completion(saved, nil)
                }

            case .failure(let error):
                print("❌ Sign up error: \(error)")
                DispatchQueue.main.async {
                    completion(false, error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Sign In

    func signIn(
        email: String,
        password: String,
        completion: @escaping (Bool, String?, String?) -> Void
    ) {
        guard !email.isEmpty, !password.isEmpty else {
            completion(false, nil, "Email and password required")
            return
        }

        let payload = APISignInRequest(email: email, password: password)

        apiService.signIn(payload: payload) { result in
            switch result {
            case .success(let response):
                let saved = self.credentialStorage.saveCredentials(email: email, password: password)
                let token = response.token
                SessionManager.shared.authToken = token
                UserDefaults.standard.set(token, forKey: "authToken")
                UserDefaults.standard.set(response.userId, forKey: "userId")

                DispatchQueue.main.async {
                    completion(saved, token, nil)
                }

            case .failure(let error):
                print("❌ Sign in error: \(error)")
                DispatchQueue.main.async {
                    completion(false, nil, error.localizedDescription)
                }
            }
        }
    }

    // MARK: - Sign Out

    func signOut(completion: @escaping (Bool) -> Void) {
        SessionManager.shared.logout()
        credentialStorage.deleteCredentials()
        DispatchQueue.main.async {
            completion(true)
        }
    }
}
