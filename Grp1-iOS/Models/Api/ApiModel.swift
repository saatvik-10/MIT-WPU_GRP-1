import Foundation

// ─────────────────────────────────────────────
// MARK: - Enums
// ─────────────────────────────────────────────

enum APIMethod: String {
	case get    = "GET"
	case post   = "POST"
	case patch  = "PATCH"
	case put    = "PUT"
	case delete = "DELETE"
}

enum APIError: Error {
	case invalidURL
	case invalidResponse
	case unauthorized
	case server(statusCode: Int, message: String?)
	case decodingError
	case transport(Error)
}

enum APILevel: String, Codable {
	case beginner     = "BEGINNER"
	case intermediate = "INTERMEDIATE"
	case advance      = "ADVANCE"
}

enum APIInterestType: String, Codable {
	case domain     = "DOMAIN"
	case preference = "PREFERENCE"
}

enum APIGender: String, Codable {
	case male   = "MALE"
	case female = "FEMALE"
	case others = "OTHERS"
}

// ─────────────────────────────────────────────
// MARK: - Auth
// ─────────────────────────────────────────────

// ✅ FIXED: Removed profileImageUrl: String (useless for uploading).
//           Added profileImageData + profileImageFileName for multipart upload.
//           NOT Encodable — sent via multipart, not JSON.
struct APISignUpRequest {
	let name: String
	let email: String
	let password: String
	let phone: String
	let level: APILevel
	let dob: String
	let gender: APIGender
	let hasOnboarding: Bool
	let profileImageData: Data?       // nil if user skipped photo
	let profileImageFileName: String? // e.g. "avatar.jpg"
}

struct APISignInRequest: Encodable {
	let email: String
	let password: String
}

struct APISignInResponse: Decodable {
	let userId: String
	let token: String
}

struct APIGetMeResponse: Decodable {
	let userId: String
}

// ─────────────────────────────────────────────
// MARK: - Profile
// ─────────────────────────────────────────────

struct APIProfileResponse: Decodable {
	let name: String
	let username: String
	let email: String
	let phone: String
	let dob: String
	let gender: String
	let profileImageUrl: String? // presigned R2 URL returned by backend
	let level: String
	let hasOnboarding: Bool?
}

struct APIUserProfileResponse: Decodable {
	let id: String
	let name: String
	let username: String
	let email: String
	let phone: String
	let dob: String
	let gender: String
	let profileImageUrl: String? // presigned R2 URL returned by backend
	let level: String
	let followersCount: Int?
	let followingCount: Int?
	let threadCount: Int?
	let isSelf: Bool?
	let isFollowing: Bool?
}

struct APIUserBasicInfo: Decodable {
	let id: String
	let name: String
	let username: String
	let profileImageUrl: String? // presigned R2 URL returned by backend
	let level: String?
}

struct APIEditProfileRequest: Encodable {
	let name: String?
	let email: String?
	let phone: String?
	let dob: String?
	let gender: String?
}

// ─────────────────────────────────────────────
// MARK: - Interests
// ─────────────────────────────────────────────

struct APIInterest: Codable {
	let id: String
	let name: String
	let type: APIInterestType
	let iconName: String
	let subTitle: String?
}

struct APIAddInterestRequest: Encodable {
	let interestId: String
}

struct APISetLevelRequest: Encodable {
	let level: APILevel
}

// ─────────────────────────────────────────────
// MARK: - Threads
// ─────────────────────────────────────────────

struct APIThreadUser: Decodable {
	let id: String
	let name: String
	let username: String
	let profileImageUrl: String? // presigned R2 URL returned by backend
}

// ✅ FIXED: imageName is now Optional (backend stores null when no image).
//           imageUrl added — this is the presigned R2 URL your UI should load.
//           NOT Encodable — use APICreateThreadRequest for sending.
struct APIThread: Decodable {
	let id: String
	let userId: String
	let title: String
	let description: String
	let imageName: String?  // the S3 key stored in DB — may be null
	let imageUrl: String?   // ✅ presigned R2 URL for display — use this in your ImageView
	let tags: [String]
	let likesCount: Int
	let commentsCount: Int
	let sharesCount: Int
	let createdAt: String
	let updatedAt: String
	let user: APIThreadUser?
}

// ✅ FIXED: NOT Encodable — sent via multipart, not JSON.
//           Added imageData + imageFileName for actual image upload.
struct APICreateThreadRequest {
	let title: String
	let description: String
	let tags: [String]
	let imageData: Data?       // nil if no image
	let imageFileName: String? // e.g. "thread.jpg"
}

// ✅ FIXED: NOT Encodable — sent via multipart, not JSON.
struct APICreateDraftRequest {
	let title: String
	let description: String
	let tags: [String]
	let threadId: String?
	let imageData: Data?
	let imageFileName: String?
}

struct APIThreadDraft: Decodable {
	let id: String
	let userId: String
	let threadId: String?
	let title: String
	let description: String
	let imageName: String? // S3 key — may be null
	let tags: [String]
	let createdAt: Date
	let updatedAt: Date
}

// ✅ Used only for JSON-only draft updates (no image change).
//    If updating image too, use updateDraft() which sends multipart.
struct APIUpdateDraftRequest: Encodable {
	let title: String?
	let description: String?
	let tags: [String]?
}

struct APIThreadComment: Decodable {
	let id: String
	let userId: String
	let threadId: String
	let description: String
	let createdAt: Date
	let user: APIThreadUser?
}

struct APICreateCommentRequest: Encodable {
	let threadId: String
	let description: String
}

struct APIThreadLikeResponse: Decodable {
	let liked: Bool
	let likesCount: Int
}

struct APIThreadLikeRequest: Encodable {
	let threadId: String
}

// ─────────────────────────────────────────────
// MARK: - Follow
// ─────────────────────────────────────────────

struct APIFollowRequest: Encodable {
	let followingId: String
}

struct APIFollowResponse: Decodable {
	let action: String
	let followersCount: Int
	let followingCount: Int
}

// ─────────────────────────────────────────────
// MARK: - Articles (Chat)
// ─────────────────────────────────────────────

struct APIArticleChatQuestionRequest: Encodable {
	let question: String
	let answer: String
}

struct APIArticleChatQuestion: Decodable {
	let id: String?
	let question: String
	let answer: String
	let createdAt: Date?
}

// ─────────────────────────────────────────────
// MARK: - Bookmark Folders
// ─────────────────────────────────────────────

struct APIBookmarkFolder: Decodable {
	let id: String
	let userId: String
	let name: String
	let createdAt: Date
	let updatedAt: Date?
	let bookmarksCount: Int?
}

struct APICreateBookmarkFolderRequest: Encodable {
	let name: String
}

// ─────────────────────────────────────────────
// MARK: - Bookmarks (General)
// ─────────────────────────────────────────────

struct APIBookmark: Decodable {
	let id: String
	let userId: String
	let folderId: String
	let title: String
	let url: String
	let imageUrl: String?
	let description: String
	let sourceType: String?
	let createdAt: Date
}

struct APICreateBookmarkRequest: Encodable {
	let folderId: String
	let title: String
	let url: String
	let sourceType: String
	let imageUrl: String
	let description: String
}

// ─────────────────────────────────────────────
// MARK: - Bookmarked Articles
// ─────────────────────────────────────────────

struct APIBookmarkedArticle: Decodable {
	let id: String
	let userId: String
	let folderId: String
	let title: String
	let description: String
	let imageName: String?
	let source: String
	let overview: [String]
	let keyTakeaways: [String]
	let jargons: [String]
	let date: String
	let createdAt: Date
}

struct APICreateBookmarkedArticleRequest: Encodable {
	let folderId: String
	let title: String
	let description: String
	let imageName: String
	let source: String
	let overview: [String]
	let keyTakeaways: [String]
	let jargons: [String]
	let date: String
}

// ─────────────────────────────────────────────
// MARK: - Bookmarked Threads
// ─────────────────────────────────────────────

struct APIBookmarkedThread: Decodable {
	let id: String
	let userId: String
	let folderId: String
	let title: String
	let description: String
	let imageName: String?
	let tags: [String]
	let createdAt: Date
}

struct APICreateBookmarkedThreadRequest: Encodable {
	let folderId: String
	let threadId: String
	let title: String
	let description: String
	let imageName: String
	let tags: [String]
}

// ─────────────────────────────────────────────
// MARK: - Progress
// ─────────────────────────────────────────────

struct APIUserProgress: Decodable {
	let id: String?
	let userId: String
	let currentStreak: Int
	let createdAt: Date?
	let updatedAt: Date?
}

struct APIUpdateProgressRequest: Encodable {
	let streakIncrement: Int
}

struct APIUpdateProgressResponse: Decodable {
	let message: String
	let progress: APIUserProgress
}