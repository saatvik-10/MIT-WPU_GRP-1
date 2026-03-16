import Foundation

final class APIService {
	static let shared = APIService()

	private let baseURL: String
	private let session: URLSession

	private init(session: URLSession = .shared) {
		if let configuredURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
		   !configuredURL.isEmpty {
			self.baseURL = configuredURL
		} else {
			self.baseURL = "https://your-backend-name.onrender.com"
		}
		self.session = session
	}

	private func makeURL(path: String, queryItems: [URLQueryItem] = []) -> URL? {
		guard var components = URLComponents(string: baseURL + path) else {
			return nil
		}
		if !queryItems.isEmpty {
			components.queryItems = queryItems
		}
		return components.url
	}

	private func decoder() -> JSONDecoder {
		let decoder = JSONDecoder()

		let plain = ISO8601DateFormatter()
		plain.formatOptions = [.withInternetDateTime]

		let fractional = ISO8601DateFormatter()
		fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

		decoder.dateDecodingStrategy = .custom { d in
			let container = try d.singleValueContainer()
			let raw = try container.decode(String.self)

			if let value = fractional.date(from: raw) ?? plain.date(from: raw) {
				return value
			}

			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Invalid ISO8601 date: \(raw)"
			)
		}

		return decoder
	}

	private func request<Response: Decodable, Body: Encodable>(
		method: APIMethod,
		path: String,
		token: String? = nil,
		queryItems: [URLQueryItem] = [],
		body: Body? = nil,
		completion: @escaping (Result<Response, APIError>) -> Void
	) {
		guard let url = makeURL(path: path, queryItems: queryItems) else {
			completion(.failure(.invalidURL))
			return
		}

		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		request.setValue("application/json", forHTTPHeaderField: "Accept")

		if let token {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}

		if let body {
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			do {
				request.httpBody = try JSONEncoder().encode(body)
			} catch {
				completion(.failure(.transport(error)))
				return
			}
		}

		session.dataTask(with: request) { [weak self] data, response, error in
			if let error {
				DispatchQueue.main.async {
					completion(.failure(.transport(error)))
				}
				return
			}

			guard let http = response as? HTTPURLResponse else {
				DispatchQueue.main.async {
					completion(.failure(.invalidResponse))
				}
				return
			}

			if http.statusCode == 401 {
				DispatchQueue.main.async {
					completion(.failure(.unauthorized))
				}
				return
			}

			guard (200...299).contains(http.statusCode) else {
				let message: String?
				if let data,
				   let decodedMessage = String(data: data, encoding: .utf8),
				   !decodedMessage.isEmpty {
					message = decodedMessage
				} else {
					message = nil
				}

				DispatchQueue.main.async {
					completion(.failure(.server(statusCode: http.statusCode, message: message)))
				}
				return
			}

			guard let data else {
				DispatchQueue.main.async {
					completion(.failure(.invalidResponse))
				}
				return
			}

			do {
				guard let self else {
					return
				}
				let parsed = try self.decoder().decode(Response.self, from: data)
				DispatchQueue.main.async {
					completion(.success(parsed))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(.decodingError))
				}
			}
		}.resume()
	}

	private struct EmptyBody: Encodable {}

	private func requestStatus<Body: Encodable>(
		method: APIMethod,
		path: String,
		token: String? = nil,
		body: Body? = nil,
		completion: @escaping (Result<Void, APIError>) -> Void
	) {
		guard let url = makeURL(path: path) else {
			completion(.failure(.invalidURL))
			return
		}

		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		request.setValue("application/json", forHTTPHeaderField: "Accept")

		if let token {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}

		if let body {
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			do {
				request.httpBody = try JSONEncoder().encode(body)
			} catch {
				completion(.failure(.transport(error)))
				return
			}
		}

		session.dataTask(with: request) { data, response, error in
			if let error {
				DispatchQueue.main.async {
					completion(.failure(.transport(error)))
				}
				return
			}

			guard let http = response as? HTTPURLResponse else {
				DispatchQueue.main.async {
					completion(.failure(.invalidResponse))
				}
				return
			}

			if http.statusCode == 401 {
				DispatchQueue.main.async {
					completion(.failure(.unauthorized))
				}
				return
			}

			guard (200...299).contains(http.statusCode) else {
				let message: String?
				if let data,
				   let decodedMessage = String(data: data, encoding: .utf8),
				   !decodedMessage.isEmpty {
					message = decodedMessage
				} else {
					message = nil
				}

				DispatchQueue.main.async {
					completion(.failure(.server(statusCode: http.statusCode, message: message)))
				}
				return
			}

			DispatchQueue.main.async {
				completion(.success(()))
			}
		}.resume()
	}

	// MARK: - Auth

	func signUp(
		payload: APISignUpRequest,
		completion: @escaping (Result<String, APIError>) -> Void
	) {
		request(method: .post, path: "/api/auth/signup", body: payload) {
			(result: Result<String, APIError>) in
			completion(result)
		}
	}

	func signIn(
		payload: APISignInRequest,
		completion: @escaping (Result<APISignInResponse, APIError>) -> Void
	) {
		request(method: .post, path: "/api/auth/signin", body: payload, completion: completion)
	}

	func getMe(
		token: String,
		completion: @escaping (Result<APIGetMeResponse, APIError>) -> Void
	) {
		request(method: .get, path: "/api/auth/me", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	// MARK: - Profile / Onboarding

	func fetchProfile(
		token: String,
		completion: @escaping (Result<APIProfileResponse, APIError>) -> Void
	) {
		request(method: .get, path: "/api/profile", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	func fetchAvailableInterests(
		type: APIInterestType? = nil,
		completion: @escaping (Result<[APIInterest], APIError>) -> Void
	) {
		let queryItems: [URLQueryItem]
		if let type {
			queryItems = [URLQueryItem(name: "type", value: type.rawValue)]
		} else {
			queryItems = []
		}

		request(
			method: .get,
			path: "/api/profile/interests/available",
			queryItems: queryItems,
			body: Optional<EmptyBody>.none,
			completion: completion
		)
	}

	func addInterest(
		interestId: String,
		token: String,
		completion: @escaping (Result<APIInterest, APIError>) -> Void
	) {
		let payload = APIAddInterestRequest(interestId: interestId)
		request(method: .post, path: "/api/profile/interests", token: token, body: payload, completion: completion)
	}

	func deleteInterest(
		interestId: String,
		token: String,
		completion: @escaping (Result<Void, APIError>) -> Void
	) {
		requestStatus(
			method: .delete,
			path: "/api/profile/interests/\(interestId)",
			token: token,
			body: Optional<EmptyBody>.none,
			completion: completion
		)
	}

	// Keeping this endpoint for compatibility with current app flow.
	// If backend removes this route, this method will fail with .server.
	func saveLevel(
		_ level: APILevel,
		token: String,
		completion: @escaping (Result<Void, APIError>) -> Void
	) {
		let payload = APISetLevelRequest(level: level)
		requestStatus(
			method: .patch,
			path: "/api/profile/level",
			token: token,
			body: payload,
			completion: completion
		)
	}

	// MARK: - Threads

	func fetchForYouThreads(
		completion: @escaping (Result<[APIThread], APIError>) -> Void
	) {
		request(method: .get, path: "/api/for-you-threads", body: Optional<EmptyBody>.none, completion: completion)
	}

	func fetchFollowingThreads(
		token: String,
		completion: @escaping (Result<[APIThread], APIError>) -> Void
	) {
		request(method: .post, path: "/api/following-threads", token: token, body: EmptyBody(), completion: completion)
	}

	// MARK: - Compatibility Helpers

	func saveLevel(
		_ level: String,
		token: String,
		completion: @escaping (Bool) -> Void
	) {
		let mapped: APILevel
		switch level.lowercased() {
		case "beginner":
			mapped = .beginner
		case "intermediate":
			mapped = .intermediate
		case "advanced":
			mapped = .advance
		default:
			mapped = .beginner
		}

		saveLevel(mapped, token: token) { result in
			switch result {
			case .success:
				completion(true)
			case .failure:
				completion(false)
			}
		}
	}

	func saveInterest(
		interestId: String,
		token: String,
		completion: @escaping (Bool) -> Void
	) {
		addInterest(interestId: interestId, token: token) { result in
			switch result {
			case .success:
				completion(true)
			case .failure:
				completion(false)
			}
		}
	}
}
