struct ProfileDataSource {
    static let items: [ProfileOption] = [
        ProfileOption(title: "Progress",      cellType: .progress, isDestructive: false),
        ProfileOption(title: "Interests",     cellType: .option,   isDestructive: false),
        ProfileOption(title: "Bookmarks",     cellType: .option,   isDestructive: false),
        ProfileOption(title: "Achievements",  cellType: .option,   isDestructive: false),
        ProfileOption(title: "About Us",      cellType: .option,   isDestructive: false),
        ProfileOption(title: "Logout",        cellType: .option,   isDestructive: true)
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
        image: "avatar",
        name: "Anandita Babar",
        level: .beginner
    )
}
