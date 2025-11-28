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
        InterestModel(title: "Stocks", subtitle: nil, icon: "stocks_icon"),
        InterestModel(title: "Crypto", subtitle: nil, icon: "crypto_icon"),
        InterestModel(title: "Macroeconomy", subtitle: nil, icon: "macro_icon"),
        InterestModel(title: "Banking", subtitle: nil, icon: "bank_icon"),
        InterestModel(title: "Commodities", subtitle: nil, icon: "commodities_icon")
    ]

    static let companies: [InterestModel] = [
        InterestModel(title: "Infosys", subtitle: "INFY", icon: nil),
        InterestModel(title: "Tata", subtitle: "TATA", icon: nil),
        InterestModel(title: "HDFC Bank", subtitle: "HDFC", icon: nil),
        InterestModel(title: "Reliance", subtitle: "RIL", icon: nil),
        InterestModel(title: "Suzlon", subtitle: "SUZ", icon: nil)
    ]
}


