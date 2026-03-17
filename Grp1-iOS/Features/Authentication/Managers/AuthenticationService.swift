import Foundation

class AuthenticationService {
    static let shared = AuthenticationService()

    // ⚠️ UPDATE THIS to your actual backend URL
    private let baseURL = "http://localhost:8080/"

    // MARK: - Sign Up (sends all data to the database)
    func signUp(
        name: String,
        email: String,
        password: String,
        phone: String,
        level: String,
        dob: String,
        gender: String,
        hasOnboarding: Bool,
        completion: @escaping (Bool, String?) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/auth/signup") else {
            completion(false, "Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "name": name,
            "email": email,
            "password": password,
            "phone": phone,
            "level": level,
            "dob": dob,
            "gender": gender,
            "hasOnboarding": hasOnboarding
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(false, "Failed to encode request")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(false, error.localizedDescription) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(false, "Invalid response") }
                return
            }

            switch httpResponse.statusCode {
            case 201:
                DispatchQueue.main.async { completion(true, nil) }
            case 409:
                DispatchQueue.main.async { completion(false, "Email already registered") }
            case 422:
                DispatchQueue.main.async { completion(false, "Invalid input. Check all fields.") }
            default:
                DispatchQueue.main.async { completion(false, "Sign up failed (status \(httpResponse.statusCode))") }
            }
        }.resume()
    }

    // MARK: - Sign In (returns userId + token)
    func signIn(
        email: String,
        password: String,
        completion: @escaping (Bool, String?, String?) -> Void // (success, token, error)
    ) {
        guard let url = URL(string: "\(baseURL)/auth/signin") else {
            completion(false, nil, "Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "email": email,
            "password": password
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(false, nil, "Failed to encode request")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(false, nil, error.localizedDescription) }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async { completion(false, nil, "Invalid response") }
                return
            }

            switch httpResponse.statusCode {
            case 200:
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                      let token = json["token"] as? String
                else {
                    DispatchQueue.main.async { completion(false, nil, "Failed to parse response") }
                    return
                }

                // Also store userId if returned
                if let userId = json["userId"] as? String {
                    DispatchQueue.main.async {
                        SessionManager.shared.userId = userId
                        UserDefaults.standard.set(userId, forKey: "userId")
                    }
                }

                DispatchQueue.main.async { completion(true, token, nil) }

            case 400:
                DispatchQueue.main.async { completion(false, nil, "Email or password is wrong") }
            case 404:
                DispatchQueue.main.async { completion(false, nil, "No account found with this email") }
            case 422:
                DispatchQueue.main.async { completion(false, nil, "Invalid input") }
            default:
                DispatchQueue.main.async { completion(false, nil, "Sign in failed (status \(httpResponse.statusCode))") }
            }
        }.resume()
    }

    // MARK: - Sign Out
    func signOut(completion: @escaping (Bool) -> Void) {
        guard let token = SessionManager.shared.authToken,
              let url = URL(string: "\(baseURL)/auth/signout") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { _, response, _ in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async {
                // Clear local session regardless
                SessionManager.shared.logout()
                completion(success)
            }
        }.resume()
    }
}

