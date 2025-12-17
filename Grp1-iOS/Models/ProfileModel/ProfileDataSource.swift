import UIKit
struct ProfileDataSource {
    static let items: [ProfileOption] = [
        ProfileOption(title: "Progress", isDestructive: false),
        ProfileOption(title: "Interests", isDestructive: false),
        ProfileOption(title: "Bookmarks", isDestructive: false),
        ProfileOption(title: "Achievements", isDestructive: false),
        ProfileOption(title: "About Us", isDestructive: false),
        ProfileOption(title: "Logout", isDestructive: true)
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

struct User {
    static var current = UserProfile(
        image: "profile",
        name: "Anandita Babar",
        phone: "8446153201",
        email: "anandita0902@gmail.com",
        level: .beginner,
        dob: "09/02/2025",
        gender: .female
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

struct ProgressMockData {
    static let overallProgress = OverallProgress(
        progressPercentage: 0.775,
        quizCompletionNumber: "2/3 Completed",
        levelNumber: "Level 5"
    )
    
    static let stats = ProgressStats(
        dayStreak: 12,
        totalXP: 2400,
        accuracyPercentage: 82
    )
    
    static let quizzes: [Quiz] = [
        Quiz(title: "Quiz 1", date: "17 Dec 2025", accuracy: 82),
        Quiz(title: "Quiz 2", date: "15 Dec 2025", accuracy: 76),
        Quiz(title: "Quiz 3", date: "13 Dec 2025", accuracy: 91),
        Quiz(title: "Quiz 4", date: "10 Dec 2025", accuracy: 68)
    ]
}
