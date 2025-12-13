import UIKit
struct ProfileDataSource {
    static let items: [ProfileOption] = [
        ProfileOption(title: "Progress", subTitle: "Level 2", isDestructive: false),
        ProfileOption(title: "Interests", subTitle: "Details", isDestructive: false),
        ProfileOption(title: "Bookmarks", subTitle: "3", isDestructive: false),
        ProfileOption(title: "Achievements", subTitle: "", isDestructive: false),
        ProfileOption(title: "About Us", subTitle: "5", isDestructive: false),
        ProfileOption(title: "Logout", subTitle: "", isDestructive: true)
    ]
}

struct InterestsDataSource {
    static let domains: [InterestModel] = [
        InterestModel(title: "Stocks", subtitle: nil, icon: "chart.bar"),
        InterestModel(title: "Crypto", subtitle: nil, icon: "bitcoinsign.circle"),
        InterestModel(title: "Macroeconomy", subtitle: nil, icon: "globe"),
        InterestModel(title: "Banking", subtitle: nil, icon: "indianrupeesign.bank.building"),
        InterestModel(title: "Commodities", subtitle: nil, icon: "shippingbox")
    ]

    static let companies: [InterestModel] = [
        InterestModel(title: "Infosys", subtitle: "INFY", icon: nil),
        InterestModel(title: "Tata", subtitle: "TATA", icon: nil),
        InterestModel(title: "HDFC Bank", subtitle: "HDFC", icon: nil),
        InterestModel(title: "Reliance", subtitle: "RIL", icon: nil),
        InterestModel(title: "Suzlon", subtitle: "SUZ", icon: nil)
    ]
}

struct Profile {
    static let current: ProfileView = ProfileView(
        image: "profile",
        name: "Anandita Babar",
        level: .beginner
    )
}

struct Bookmarks {
    static let mockBookmarks: [BookmarkItem] = [
        BookmarkItem(
            icon: UIImage(systemName: "folder")!,
            title: "Swift",
        ),
        BookmarkItem(
            icon: UIImage(systemName: "folder")!,
            title: "Blockchain",
        ),
        BookmarkItem(
            icon: UIImage(systemName: "folder")!,
            title: "Web Development",
        )
    ]
}
