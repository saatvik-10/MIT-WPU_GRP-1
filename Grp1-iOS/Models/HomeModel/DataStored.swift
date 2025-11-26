import Foundation

class NewsDataStore {
    
    static let shared = NewsDataStore()
    
    private init() {}
    
    private var newsArticles: [NewsArticle] = [
        
        NewsArticle(
            id: 1,
            title: "RBI Maintains Status Quo on Interest Rates",
            description: "The RBI kept repo rate unchanged as inflation stabilizes. Markets reacted positively.",
            imageName: "beach_1",
            category: "Economy",
            date: "Today"
        ),
        
        NewsArticle(
            id: 2,
            title: "Nifty Surges 103 Points Amid Bullish Momentum",
            description: "Markets closed near the highs backed by strong buying across sectors.",
            imageName: "beach_2",
            category: "Markets",
            date: "Today"
        ),
        
        NewsArticle(
            id: 3,
            title: "Gold Prices Hit 3-Month High",
            description: "Weak dollar and geopolitical tensions push gold prices higher.",
            imageName: "beach_3",
            category: "Commodities",
            date: "Yesterday"
        ),
        
        NewsArticle(
            id: 4,
            title: "Tech Giants Report Strong Quarterly Results",
            description: "IT sector sees renewed interest as major players beat earnings estimates.",
            imageName: "beach_4",
            category: "Technology",
            date: "Yesterday"
        )
    ]
    
    /// Fetch all articles
    func getAllNews() -> [NewsArticle] {
        return newsArticles
    }
    
    /// For “Today's Pick” – return the top 1
    func getTodaysPick() -> NewsArticle? {
        return newsArticles.first
    }
}
