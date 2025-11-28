import Foundation

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
