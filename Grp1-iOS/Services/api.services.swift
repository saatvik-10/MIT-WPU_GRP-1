import Foundation

final class APIService {
	static let shared = APIService()

	var baseURL: String
	private let session: URLSession

	private init(session: URLSession = .shared) {
		if let configuredURL = Bundle.main.object(forInfoDictionaryKey: "API_BASE_URL") as? String,
		   !configuredURL.isEmpty {
			self.baseURL = configuredURL
		} else {
			self.baseURL = "http://localhost:8081"
		}
		self.session = session
	}

	// ─────────────────────────────────────────────
	// MARK: - URL Builder
	// ─────────────────────────────────────────────

	private func makeURL(path: String, queryItems: [URLQueryItem] = []) -> URL? {
		guard var components = URLComponents(string: baseURL + path) else { return nil }
		if !queryItems.isEmpty { components.queryItems = queryItems }
		return components.url
	}

	// ─────────────────────────────────────────────
	// MARK: - Date Decoder
	// ─────────────────────────────────────────────

	private func decoder() -> JSONDecoder {
		let decoder = JSONDecoder()
		let plain = ISO8601DateFormatter()
		plain.formatOptions = [.withInternetDateTime]
		let fractional = ISO8601DateFormatter()
		fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

		decoder.dateDecodingStrategy = .custom { d in
			let container = try d.singleValueContainer()
			let raw = try container.decode(String.self)
			if let value = fractional.date(from: raw) ?? plain.date(from: raw) { return value }
			throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date: \(raw)")
		}
		return decoder
	}

	// ─────────────────────────────────────────────
	// MARK: - JSON Request (for non-image endpoints)
	// ─────────────────────────────────────────────

	private struct EmptyBody: Encodable {}

	private func request<Response: Decodable, Body: Encodable>(
		method: APIMethod,
		path: String,
		token: String? = nil,
		queryItems: [URLQueryItem] = [],
		body: Body? = nil,
		completion: @escaping (Result<Response, APIError>) -> Void
	) {
		guard let url = makeURL(path: path, queryItems: queryItems) else {
			completion(.failure(.invalidURL)); return
		}

		var req = URLRequest(url: url)
		req.httpMethod = method.rawValue
		req.setValue("application/json", forHTTPHeaderField: "Accept")

		if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }

		if let body {
			req.setValue("application/json", forHTTPHeaderField: "Content-Type")
			do { req.httpBody = try JSONEncoder().encode(body) }
			catch { completion(.failure(.transport(error))); return }
		}

		session.dataTask(with: req) { [weak self] data, response, error in
			self?.handleResponse(data: data, response: response, error: error, completion: completion)
		}.resume()
	}

	private func requestStatus<Body: Encodable>(
		method: APIMethod,
		path: String,
		token: String? = nil,
		body: Body? = nil,
		completion: @escaping (Result<Void, APIError>) -> Void
	) {
		guard let url = makeURL(path: path) else {
			completion(.failure(.invalidURL)); return
		}

		var req = URLRequest(url: url)
		req.httpMethod = method.rawValue
		req.setValue("application/json", forHTTPHeaderField: "Accept")

		if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }

		if let body {
			req.setValue("application/json", forHTTPHeaderField: "Content-Type")
			do { req.httpBody = try JSONEncoder().encode(body) }
			catch { completion(.failure(.transport(error))); return }
		}

		session.dataTask(with: req) { data, response, error in
			if let error { DispatchQueue.main.async { completion(.failure(.transport(error))) }; return }
			guard let http = response as? HTTPURLResponse else {
				DispatchQueue.main.async { completion(.failure(.invalidResponse)) }; return
			}
			if http.statusCode == 401 { DispatchQueue.main.async { completion(.failure(.unauthorized)) }; return }
			guard (200...299).contains(http.statusCode) else {
				let message = data.flatMap { String(data: $0, encoding: .utf8) }
				DispatchQueue.main.async { completion(.failure(.server(statusCode: http.statusCode, message: message))) }
				return
			}
			DispatchQueue.main.async { completion(.success(())) }
		}.resume()
	}

	// ─────────────────────────────────────────────
	// MARK: - ✅ Multipart Form-Data Request
	// Use this for any endpoint that accepts images
	// ─────────────────────────────────────────────

	private func multipartRequest<Response: Decodable>(
		method: APIMethod,
		path: String,
		token: String? = nil,
		fields: [String: String],           // text fields e.g. ["title": "Hello"]
		tagsField: [String]? = nil,         // tags array sent as multiple "tags[]" fields
		imageData: Data? = nil,             // the image bytes
		imageFileName: String? = nil,       // e.g. "photo.jpg"
		imageFieldName: String = "threadImage", // backend field name — "threadImage" or "profileImage"
		completion: @escaping (Result<Response, APIError>) -> Void
	) {
		guard let url = makeURL(path: path) else {
			completion(.failure(.invalidURL)); return
		}

		let boundary = "Boundary-\(UUID().uuidString)"
		var body = Data()

		// ── Helper closures ──────────────────────────────────────
		func appendField(_ name: String, value: String) {
			body.append("--\(boundary)\r\n".data(using: .utf8)!)
			body.append("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".data(using: .utf8)!)
			body.append("\(value)\r\n".data(using: .utf8)!)
		}

		func appendImageData(_ data: Data, fieldName: String, fileName: String) {
			let mimeType = fileName.lowercased().hasSuffix(".png") ? "image/png" : "image/jpeg"
			body.append("--\(boundary)\r\n".data(using: .utf8)!)
			body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
			body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
			body.append(data)
			body.append("\r\n".data(using: .utf8)!)
		}
		// ─────────────────────────────────────────────────────────

		// Append plain text fields
		for (key, value) in fields {
			appendField(key, value: value)
		}

		// ✅ Tags must be sent as repeated fields: tags[]=swift&tags[]=ios
		// Your Hono backend reads them as an array via formidable
		if let tags = tagsField {
			for tag in tags {
				appendField("tags[]", value: tag)
			}
		}

		// Append image if provided
		if let imageData, let imageFileName {
			appendImageData(imageData, fieldName: imageFieldName, fileName: imageFileName)
		}

		// Close boundary
		body.append("--\(boundary)--\r\n".data(using: .utf8)!)

		var req = URLRequest(url: url)
		req.httpMethod = method.rawValue
		req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
		req.setValue("application/json", forHTTPHeaderField: "Accept")
		if let token { req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
		req.httpBody = body

		session.dataTask(with: req) { [weak self] data, response, error in
			self?.handleResponse(data: data, response: response, error: error, completion: completion)
		}.resume()
	}

	// ─────────────────────────────────────────────
	// MARK: - Shared Response Handler
	// ─────────────────────────────────────────────

	private func handleResponse<Response: Decodable>(
		data: Data?,
		response: URLResponse?,
		error: Error?,
		completion: @escaping (Result<Response, APIError>) -> Void
	) {
		if let error {
			DispatchQueue.main.async { completion(.failure(.transport(error))) }
			return
		}

		guard let http = response as? HTTPURLResponse else {
			DispatchQueue.main.async { completion(.failure(.invalidResponse)) }
			return
		}

		if http.statusCode == 401 {
			DispatchQueue.main.async { completion(.failure(.unauthorized)) }
			return
		}

		guard (200...299).contains(http.statusCode) else {
			let message = data.flatMap { String(data: $0, encoding: .utf8) }
			DispatchQueue.main.async {
				completion(.failure(.server(statusCode: http.statusCode, message: message)))
			}
			return
		}

		guard let data else {
			DispatchQueue.main.async { completion(.failure(.invalidResponse)) }
			return
		}

		do {
			let parsed = try self.decoder().decode(Response.self, from: data)
			DispatchQueue.main.async { completion(.success(parsed)) }
		} catch {
			// ✅ Print the raw response so you can debug decode failures
			if let raw = String(data: data, encoding: .utf8) {
				print("[APIService] Decode error. Raw response: \(raw)")
			}
			DispatchQueue.main.async { completion(.failure(.decodingError)) }
		}
	}

	// ─────────────────────────────────────────────
	// MARK: - Auth
	// ─────────────────────────────────────────────

	/// ✅ Uses multipart so profileImage Data reaches the backend
	func signUp(
		payload: APISignUpRequest,
		completion: @escaping (Result<String, APIError>) -> Void
	) {
		let fields: [String: String] = [
			"name":          payload.name,
			"email":         payload.email,
			"password":      payload.password,
			"phone":         payload.phone,
			"level":         payload.level.rawValue,
			"dob":           payload.dob,
			"gender":        payload.gender.rawValue,
			"hasOnboarding": payload.hasOnboarding ? "true" : "false",
		]

		multipartRequest(
			method: .post,
			path: "/api/auth/signup",
			token: nil,
			fields: fields,
			tagsField: nil,
			imageData: payload.profileImageData,
			imageFileName: payload.profileImageFileName,
			imageFieldName: "profileImage",   // ✅ matches backend: files.profileImage
			completion: completion
		)
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

	// ─────────────────────────────────────────────
	// MARK: - Profile / Onboarding
	// ─────────────────────────────────────────────

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
		let queryItems: [URLQueryItem] = type.map { [URLQueryItem(name: "type", value: $0.rawValue)] } ?? []
		request(method: .get, path: "/api/profile/interests/available", queryItems: queryItems, body: Optional<EmptyBody>.none, completion: completion)
	}

	func addInterest(
		interestId: String,
		token: String,
		completion: @escaping (Result<APIInterest, APIError>) -> Void
	) {
		request(method: .post, path: "/api/profile/interests", token: token, body: APIAddInterestRequest(interestId: interestId), completion: completion)
	}

	func deleteInterest(
		interestId: String,
		token: String,
		completion: @escaping (Result<Void, APIError>) -> Void
	) {
		requestStatus(method: .delete, path: "/api/profile/interests/\(interestId)", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	func saveLevel(
		_ level: APILevel,
		token: String,
		completion: @escaping (Result<Void, APIError>) -> Void
	) {
		requestStatus(method: .patch, path: "/api/profile/level", token: token, body: APISetLevelRequest(level: level), completion: completion)
	}

	// ─────────────────────────────────────────────
	// MARK: - Threads ✅ NOW USES MULTIPART
	// ─────────────────────────────────────────────

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

	/// ✅ Creates a thread with optional image via multipart/form-data
	func createThread(
		payload: APICreateThreadRequest,
		token: String,
		completion: @escaping (Result<APIThread, APIError>) -> Void
	) {
		multipartRequest(
			method: .post,
			path: "/api/create-thread",
			token: token,
			fields: [
				"title": payload.title,
				"description": payload.description,
			],
			tagsField: payload.tags,
			imageData: payload.imageData,
			imageFileName: payload.imageFileName,
			imageFieldName: "threadImage",   // ✅ must match backend: files.threadImage
			completion: completion
		)
	}

	/// ✅ Saves a draft with optional image via multipart/form-data
	func saveDraft(
		payload: APICreateDraftRequest,
		token: String,
		completion: @escaping (Result<APIThreadDraft, APIError>) -> Void
	) {
		var fields: [String: String] = [
			"title": payload.title,
			"description": payload.description,
		]
		if let threadId = payload.threadId { fields["threadId"] = threadId }

		multipartRequest(
			method: .post,
			path: "/api/draft",
			token: token,
			fields: fields,
			tagsField: payload.tags,
			imageData: payload.imageData,
			imageFileName: payload.imageFileName,
			imageFieldName: "threadImage",
			completion: completion
		)
	}

	func fetchDrafts(
		token: String,
		completion: @escaping (Result<[APIThreadDraft], APIError>) -> Void
	) {
		request(method: .get, path: "/api/drafts", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	/// ✅ Updates a draft — supports optional new image via multipart
	func updateDraft(
		draftId: String,
		title: String? = nil,
		description: String? = nil,
		tags: [String]? = nil,
		imageData: Data? = nil,
		imageFileName: String? = nil,
		token: String,
		completion: @escaping (Result<APIThreadDraft, APIError>) -> Void
	) {
		var fields: [String: String] = [:]
		if let title { fields["title"] = title }
		if let description { fields["description"] = description }

		multipartRequest(
			method: .put,
			path: "/api/draft/\(draftId)",
			token: token,
			fields: fields,
			tagsField: tags,
			imageData: imageData,
			imageFileName: imageFileName,
			imageFieldName: "threadImage",
			completion: completion
		)
	}

	func deleteDraft(
		draftId: String,
		token: String,
		completion: @escaping (Result<Void, APIError>) -> Void
	) {
		requestStatus(method: .delete, path: "/api/draft?draftId=\(draftId)", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	func deleteThread(
		threadId: String,
		token: String,
		completion: @escaping (Result<Void, APIError>) -> Void
	) {
		requestStatus(method: .delete, path: "/api/thread?threadId=\(threadId)", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	// ─────────────────────────────────────────────
	// MARK: - Comments & Likes
	// ─────────────────────────────────────────────

	func createComment(
		payload: APICreateCommentRequest,
		token: String,
		completion: @escaping (Result<APIThreadComment, APIError>) -> Void
	) {
		request(method: .post, path: "/api/comment", token: token, body: payload, completion: completion)
	}

	func fetchComments(
		threadId: String,
		completion: @escaping (Result<[APIThreadComment], APIError>) -> Void
	) {
		request(method: .get, path: "/api/comments", queryItems: [URLQueryItem(name: "threadId", value: threadId)], body: Optional<EmptyBody>.none, completion: completion)
	}

	func toggleThreadLike(
		threadId: String,
		token: String,
		completion: @escaping (Result<APIThreadLikeResponse, APIError>) -> Void
	) {
		request(method: .post, path: "/api/like", token: token, body: APIThreadLikeRequest(threadId: threadId), completion: completion)
	}

	// ─────────────────────────────────────────────
	// MARK: - Follow
	// ─────────────────────────────────────────────

	func updateFollow(
		followingId: String,
		token: String,
		completion: @escaping (Result<APIFollowResponse, APIError>) -> Void
	) {
		request(method: .post, path: "/api/follow", token: token, body: APIFollowRequest(followingId: followingId), completion: completion)
	}

	func fetchAllFollowers(
		token: String,
		completion: @escaping (Result<[APIUserBasicInfo], APIError>) -> Void
	) {
		request(method: .get, path: "/api/all-followers", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	func fetchAllFollowing(
		token: String,
		completion: @escaping (Result<[APIUserBasicInfo], APIError>) -> Void
	) {
		request(method: .get, path: "/api/all-following", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	// ─────────────────────────────────────────────
	// MARK: - User Profile
	// ─────────────────────────────────────────────

	func fetchUserProfile(
		userId: String,
		token: String,
		completion: @escaping (Result<APIUserProfileResponse, APIError>) -> Void
	) {
		request(method: .get, path: "/api/users/\(userId)/profile", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	func fetchUserFollowers(
		userId: String,
		token: String,
		completion: @escaping (Result<[APIUserBasicInfo], APIError>) -> Void
	) {
		request(method: .get, path: "/api/users/\(userId)/followers", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	func fetchUserFollowing(
		userId: String,
		token: String,
		completion: @escaping (Result<[APIUserBasicInfo], APIError>) -> Void
	) {
		request(method: .get, path: "/api/users/\(userId)/following", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	func fetchUserInterests(
		token: String,
		type: APIInterestType? = nil,
		completion: @escaping (Result<[APIInterest], APIError>) -> Void
	) {
		let queryItems: [URLQueryItem] = type.map { [URLQueryItem(name: "type", value: $0.rawValue)] } ?? []
		request(method: .get, path: "/api/interests", token: token, queryItems: queryItems, body: Optional<EmptyBody>.none, completion: completion)
	}

	// ─────────────────────────────────────────────
	// MARK: - Articles
	// ─────────────────────────────────────────────

	func postArticleChatQuestion(
		question: String,
		answer: String,
		completion: @escaping (Result<String, APIError>) -> Void
	) {
		request(method: .post, path: "/api/chat/question", body: APIArticleChatQuestionRequest(question: question, answer: answer)) {
			(result: Result<String, APIError>) in completion(result)
		}
	}

	func fetchArticleChatQuestions(
		completion: @escaping (Result<[APIArticleChatQuestion], APIError>) -> Void
	) {
		request(method: .get, path: "/api/chat/questions", body: Optional<EmptyBody>.none, completion: completion)
	}

	// ─────────────────────────────────────────────
	// MARK: - Bookmark Folders
	// ─────────────────────────────────────────────

	func fetchBookmarkFolders(
		token: String,
		completion: @escaping (Result<[APIBookmarkFolder], APIError>) -> Void
	) {
		request(method: .get, path: "/api/folders", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	func createBookmarkFolder(
		name: String,
		token: String,
		completion: @escaping (Result<APIBookmarkFolder, APIError>) -> Void
	) {
		request(method: .post, path: "/api/folders", token: token, body: APICreateBookmarkFolderRequest(name: name), completion: completion)
	}

	func deleteBookmarkFolder(
		folderId: String,
		token: String,
		completion: @escaping (Result<Void, APIError>) -> Void
	) {
		requestStatus(method: .delete, path: "/api/folders/\(folderId)", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	// ─────────────────────────────────────────────
	// MARK: - Bookmarks
	// ─────────────────────────────────────────────

	func fetchBookmarks(
		folderId: String,
		token: String,
		completion: @escaping (Result<[APIBookmark], APIError>) -> Void
	) {
		request(method: .get, path: "/api/bookmarks", token: token, queryItems: [URLQueryItem(name: "folderId", value: folderId)], body: Optional<EmptyBody>.none, completion: completion)
	}

	func createBookmark(
		payload: APICreateBookmarkRequest,
		token: String,
		completion: @escaping (Result<APIBookmark, APIError>) -> Void
	) {
		request(method: .post, path: "/api/bookmarks", token: token, body: payload, completion: completion)
	}

	func fetchBookmarkedArticles(
		token: String,
		folderId: String? = nil,
		completion: @escaping (Result<[APIBookmarkedArticle], APIError>) -> Void
	) {
		let queryItems: [URLQueryItem] = folderId.map { [URLQueryItem(name: "folderId", value: $0)] } ?? []
		request(method: .get, path: "/api/articles", token: token, queryItems: queryItems, body: Optional<EmptyBody>.none, completion: completion)
	}

	func createBookmarkedArticle(
		payload: APICreateBookmarkedArticleRequest,
		token: String,
		completion: @escaping (Result<APIBookmarkedArticle, APIError>) -> Void
	) {
		request(method: .post, path: "/api/articles", token: token, body: payload, completion: completion)
	}

	func deleteBookmarkedArticle(
		articleId: String,
		token: String,
		completion: @escaping (Result<Void, APIError>) -> Void
	) {
		requestStatus(method: .delete, path: "/api/articles/\(articleId)", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	func fetchBookmarkedThreads(
		token: String,
		folderId: String? = nil,
		completion: @escaping (Result<[APIBookmarkedThread], APIError>) -> Void
	) {
		let queryItems: [URLQueryItem] = folderId.map { [URLQueryItem(name: "folderId", value: $0)] } ?? []
		request(method: .get, path: "/api/threads", token: token, queryItems: queryItems, body: Optional<EmptyBody>.none, completion: completion)
	}

	func createBookmarkedThread(
		payload: APICreateBookmarkedThreadRequest,
		token: String,
		completion: @escaping (Result<APIBookmarkedThread, APIError>) -> Void
	) {
		request(method: .post, path: "/api/threads", token: token, body: payload, completion: completion)
	}

	func deleteBookmarkedThread(
		threadId: String,
		token: String,
		completion: @escaping (Result<Void, APIError>) -> Void
	) {
		requestStatus(method: .delete, path: "/api/threads/\(threadId)", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	// ─────────────────────────────────────────────
	// MARK: - Progress
	// ─────────────────────────────────────────────

	func fetchUserProgress(
		token: String,
		completion: @escaping (Result<APIUserProgress, APIError>) -> Void
	) {
		request(method: .get, path: "/api/progress", token: token, body: Optional<EmptyBody>.none, completion: completion)
	}

	func updateProgress(
		payload: APIUpdateProgressRequest,
		token: String,
		completion: @escaping (Result<APIUpdateProgressResponse, APIError>) -> Void
	) {
		request(method: .post, path: "/api/progress", token: token, body: payload, completion: completion)
	}

	// ─────────────────────────────────────────────
	// MARK: - Compatibility Helpers
	// ─────────────────────────────────────────────

	func saveLevel(
		_ level: String,
		token: String,
		completion: @escaping (Bool) -> Void
	) {
		let mapped: APILevel
		switch level.lowercased() {
		case "beginner": mapped = .beginner
		case "intermediate": mapped = .intermediate
		case "advanced": mapped = .advance
		default: mapped = .beginner
		}
		saveLevel(mapped, token: token) { result in
			completion((try? result.get()) != nil)
		}
	}

	func saveInterest(
		interestId: String,
		token: String,
		completion: @escaping (Bool) -> Void
	) {
		addInterest(interestId: interestId, token: token) { result in
			completion((try? result.get()) != nil)
		}
	}
}