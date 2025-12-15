import Foundation
import UIKit

enum UserLevel: String {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    var color: UIColor {
        switch self {
        case .beginner:
            return .systemGreen
        case .intermediate:
            return .systemYellow
        case .advanced:
            return .systemRed
        }
    }
}

struct ProfileOption {
    let title: String
    let subTitle: String
    let isDestructive: Bool
}

enum InterestType {
    case domain
    case company

    var title: String {
        switch self {
        case .domain: return "Add New Domain"
        case .company: return "Add New Company"
        }
    }

    var searchPlaceholder: String {
        switch self {
        case .domain: return "Search Domains"
        case .company: return "Search Companies"
        }
    }
}

struct InterestModel {
    let title: String
    let subtitle: String?
    let icon: String?
}

struct ProfileView {
    let image: String
    let name: String
    let level: UserLevel
}

struct UserProfile {
    let image: String
    let name: String
    let phone: String
    let email: String
    let level: UserLevel
}

struct BookmarkItem {
    let icon: UIImage
    let title: String
}
