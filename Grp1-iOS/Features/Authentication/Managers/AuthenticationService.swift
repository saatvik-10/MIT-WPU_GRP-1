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
        profileImageUrl: String? = nil,
        completion: @escaping (Bool, String?) -> Void
    ) {
        // Convert String to APILevel enum
        let levelEnum: APILevel
        switch level.uppercased() {
        case "BEGINNER": levelEnum = .beginner
        case "INTERMEDIATE": levelEnum = .intermediate
        case "ADVANCE", "ADVANCED": levelEnum = .advance
        default: levelEnum = .beginner
        }
        
        // Convert String to APIGender enum
        let genderEnum: APIGender
        switch gender.uppercased() {
        case "MALE": genderEnum = .male
        case "FEMALE": genderEnum = .female
        case "OTHER", "OTHERS": genderEnum = .others
        default: genderEnum = .male
        }
        
        // Create payload using ApiModel.swift structs
        let payload = APISignUpRequest(
            name: name,
            email: email,
            password: password,
            profileImageUrl: profileImageUrl,
            phone: phone,
            level: levelEnum,
            dob: dob,
            gender: genderEnum,
            hasOnboarding: hasOnboarding
        )

        // ✅ Use APIService.signUp()
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
        guard let token = SessionManager.shared.authToken else {
            completion(false)
            return
        }

        SessionManager.shared.logout()
        self.credentialStorage.deleteCredentials()
        
        DispatchQueue.main.async {
            completion(true)
        }
    }
}