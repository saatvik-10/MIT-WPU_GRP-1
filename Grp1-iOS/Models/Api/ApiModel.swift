import Foundation

enum APIMethod: String {
	case get = "GET"
	case post = "POST"
	case patch = "PATCH"
	case put = "PUT"
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
	case beginner = "BEGINNER"
	case intermediate = "INTERMEDIATE"
	case advance = "ADVANCE"
}

enum APIInterestType: String, Codable {
	case domain = "DOMAIN"
	case preference = "PREFERENCE"
}

enum APIGender: String, Codable {
	case male = "MALE"
	case female = "FEMALE"
	case others = "OTHERS"
}

struct APISignUpRequest: Encodable {
	let name: String
	let email: String
	let password: String
	let profileImageUrl: String?
	let phone: String
	let level: APILevel
	let dob: String
	let gender: APIGender
	let hasOnboarding: Bool
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

struct APIProfileResponse: Decodable {
	let name: String
	let username: String
	let email: String
	let phone: String
	let dob: String
	let gender: String
	let profileImageUrl: String?
	let level: String
}

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

struct APIThreadUser: Decodable {
	let id: String
	let name: String
	let username: String
	let profileImageUrl: String?
}

struct APIThread: Decodable {
	let id: String
	let userId: String
	let title: String
	let description: String
	let imageName: String
	let tags: [String]
	let likesCount: Int
	let commentsCount: Int
	let sharesCount: Int
	let createdAt: String
	let updatedAt: String
	let user: APIThreadUser?
}

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

// MARK: - User Profile

struct APIUserProfileResponse: Decodable {
	let id: String
	let name: String
	let username: String
	let email: String
	let phone: String
	let dob: String
	let gender: String
	let profileImageUrl: String?
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
	let profileImageUrl: String?
	let level: String?
}

// MARK: - Follow

struct APIFollowRequest: Encodable {
	let followingId: String
}

struct APIFollowResponse: Decodable {
	let action: String
	let followersCount: Int
	let followingCount: Int
}

// MARK: - Thread

struct APICreateThreadRequest: Encodable {
	let title: String
	let description: String
	let tags: [String]
}

struct APIThreadDraft: Decodable {
	let id: String
	let userId: String
	let threadId: String?
	let title: String
	let description: String
	let imageName: String?
	let tags: [String]
	let createdAt: Date
	let updatedAt: Date
}

struct APIUpdateDraftRequest: Encodable {
	let title: String?
	let description: String?
	let imageName: String?
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

// MARK: - Bookmark Folder

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

// MARK: - Bookmark (General)

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

// MARK: - Bookmarked Article

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

// MARK: - Bookmarked Thread

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

// MARK: - Progress

struct APIUserProgress: Decodable {
	let id: String?
	let userId: String
	let totalXP: Int
	let currentStreak: Int
	let overallProgress: Float
	let createdAt: Date?
	let updatedAt: Date?
}

struct APIUpdateProgressRequest: Encodable {
	let xpEarned: Int
	let streakIncrement: Int
	let progressIncrement: Float
}

struct APIUpdateProgressResponse: Decodable {
	let message: String
	let progress: APIUserProgress
}