import UIKit
//struct ProfileDataSource {
//    static let items: [ProfileOption] = [
//        ProfileOption(title: "Progress", isDestructive: false),
//        ProfileOption(title: "Interests", isDestructive: false),
//        ProfileOption(title: "Bookmarks", isDestructive: false),
//        ProfileOption(title: "About Us", isDestructive: false),
//        ProfileOption(title: "Logout", isDestructive: true)
//    ]
//}

struct ProfileDataSource {
    static let progressSection = ProgressSectionModel(
        progressPercentage: ProgressSectionMockData.mockProgress.progressPercentage,
        progressLevel: ProgressSectionMockData.mockProgress.progressLevel,
        requirementNextLevel: ProgressSectionMockData.mockProgress.requirementNextLevel
    )
    
    static let interestsSection = InterestsSectionModel(
        interests: Array(
            (InterestsDataSource.domains.map { $0.title }
             + InterestsDataSource.companies.map { $0.title })
            .prefix(4)
        )
    )
    
    static let bookmarksSection = BookmarksSectionModel(
        totalBookmarks: Bookmarks.mockBookmarks.count,
        totalFolders: Bookmarks.mockBookmarks.count
    )
    
    static let sections: [ProfileSection] = [
        .progress(progressSection),
        .interests(interestsSection),
        .bookmarks(bookmarksSection),
        .about,
        .logout
    ]
}

struct InterestsDataSource {
    static let domains: [InterestModel] = [
        InterestModel(title: "Stocks", subtitle: nil, icon: "chart.line.uptrend.xyaxis"),
        InterestModel(title: "Crypto", subtitle: nil, icon: "bitcoinsign.circle"),
        InterestModel(title: "Macroeconomy", subtitle: nil, icon: "globe"),
        InterestModel(title: "Banking", subtitle: nil, icon: "creditcard"),
        InterestModel(title: "Commodities", subtitle: nil, icon: "shippingbox"),
        InterestModel(title: "Mutual Funds", subtitle: nil, icon: "building.columns")
    ]
    
    static let companies: [InterestModel] = [
        InterestModel(title: "Infosys", subtitle: "INFY", icon: nil),
        InterestModel(title: "Tata", subtitle: "TATA", icon: nil),
        InterestModel(title: "HDFC Bank", subtitle: "HDFC", icon: nil),
        InterestModel(title: "Reliance", subtitle: "RIL", icon: nil),
        InterestModel(title: "Suzlon", subtitle: "SUZ", icon: nil)
    ]
    
    static let preferences: [InterestModel] = [
        InterestModel(title: "Indian Economy", subtitle: "Consumption,inflation , growth", icon: "indianrupeesign.gauge.chart.lefthalf.righthalf"),
        InterestModel(title: "Personal Finance", subtitle: "Exports, Imports and Trade Balance", icon: "figure.wave"),
        InterestModel(title: "Government and Policy", subtitle: "Public Spending and Reforms", icon: "newspaper"),
        InterestModel(title: "Stock Markets", subtitle: "Shares ,Indices and Market Cycles", icon: "chart.line.uptrend.xyaxis"),
        InterestModel(title: "Real Estate Economics", subtitle: "Housing Interest rates, demand", icon: "building.2"),
        InterestModel(title: "Global Economy", subtitle: "Exports, Imports and Trade Balance", icon: "globe.central.south.asia.fill"),
        InterestModel(title: "Banking and credit", subtitle: "Loans , Interest rates and Moneyflow", icon: "banknote"),
        InterestModel(title: "Crypto", subtitle: "Bitcoin, Web3 and Digital Assets", icon: "bitcoinsign.circle"),
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

struct ProgressSectionMockData {
    static let mockProgress = ProgressSectionModel(
        progressPercentage: 0.775,
        progressLevel: 5,
        requirementNextLevel: ""
    )
}

struct Bookmarks {
    static let mockBookmarks: [BookmarkItem] = [
        BookmarkItem(
            icon: UIImage(systemName: "folder")!,
            id: "1",
            title: "Stocks"
        ),
        BookmarkItem(
            icon: UIImage(systemName: "folder")!,
            id: "2",
            title: "Crypto"
        ),
        BookmarkItem(
            icon: UIImage(systemName: "folder")!,
            id: "3",
            title: "Gold"
        )
    ]
}

struct ProgressMockData {
    static let overallProgress = OverallProgress(
        progressPercentage: 0.775,
        quizCompletionNumber: "2/3 Completed",
        levelNumber: 5
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
