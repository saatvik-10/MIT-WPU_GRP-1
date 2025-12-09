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

enum ProfileCellType {
    case progress
    case option
}

struct ProfileOption {
    let title: String
    let cellType: ProfileCellType
    let isDestructive: Bool
}

struct Domain {
    let title: String
    let iconName: String
}

struct Company {
    let name: String
    let symbol: String
}

struct InterestModel {
    let title: String
    let subtitle: String?      // for companies
    let icon: String?          // for domains
}

struct ProfileView {
    let image: String
    let name: String
    let level: UserLevel
}
