//
//  OnboardingAPIService.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 09/03/26.
//

// NEW FILE: OnboardingAPIService.swift

import Foundation

class OnboardingAPIService {

    static let shared = OnboardingAPIService()
    private init() {}

    private let baseURL = "http://localhost:8000" 

    /// Save the user's level to the backend (updates the User record)
    func saveLevel(_ level: String, token: String, completion: @escaping (Bool) -> Void) {
        // Map UI text to the Prisma enum value
        let levelEnum: String
        switch level.lowercased() {
        case "beginner":    levelEnum = "BEGINNER"
        case "intermediate": levelEnum = "INTERMEDIATE"
        case "advanced":    levelEnum = "ADVANCE"
        default:            levelEnum = "BEGINNER"
        }

        guard let url = URL(string: "\(baseURL)/api/profile/level") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["level": levelEnum])

        URLSession.shared.dataTask(with: request) { _, response, error in
            let success = (response as? HTTPURLResponse)?.statusCode == 200
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }

    /// Save a single interest (domain or preference) to the backend
    func saveInterest(interestId: String, token: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/profile/interests") else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["interestId": interestId])

        URLSession.shared.dataTask(with: request) { _, response, error in
            let success = (response as? HTTPURLResponse)?.statusCode == 201
            DispatchQueue.main.async { completion(success) }
        }.resume()
    }

    /// Fetch all available interests from the backend (to get their IDs)
    func fetchAvailableInterests(type: String? = nil, completion: @escaping ([[String: Any]]) -> Void) {
        var urlString = "\(baseURL)/api/profile/interests/available"
        if let type = type {
            urlString += "?type=\(type)"
        }

        guard let url = URL(string: urlString) else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            DispatchQueue.main.async { completion(json) }
        }.resume()
    }
}
