import Foundation

enum APIMethod: String {
	case get = "GET"
	case post = "POST"
	case patch = "PATCH"
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
	let createdAt: Date
	let updatedAt: Date
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