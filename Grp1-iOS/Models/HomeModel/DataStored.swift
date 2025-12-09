import Foundation

class NewsDataStore {
    
    static let shared = NewsDataStore()
    
    private init() {}
    
    private var newsArticles: [NewsArticle] = [
        
        NewsArticle(
            id: 1,
            title: "RBI Maintains Status Quo on Interest Rates",
            description: "The RBI kept repo rate unchanged as inflation stabilizes. Markets reacted positively.",
            imageName: "urban_4",
            category: "Economy",
            date: "Today",
            source: "Economic Times",
            qaHistory: [
                ArticleQA(
                    question: "How will unchanged repo rates affect home loan EMIs?",
                    answer: "Since the repo rate remains unchanged, existing EMIs are expected to stay stable with no immediate change.",
                    createdAt: Date()
                ),
                ArticleQA(
                    question: "Is this policy expected to boost market confidence?",
                    answer: "Yes, stable monetary policy often supports positive investor sentiment and attracts fresh buying.",
                    createdAt: Date()
                )
            ]
        ),
        
        NewsArticle(
            id: 2,
            title: "Nifty Surges 103 Points Amid Bullish Momentum",
            description: "Markets closed near the highs backed by strong buying across sectors.",
            imageName: "urban_6",
            category: "Markets",
            date: "Today",
            source: "Moneycontrol",
            qaHistory: [
                ArticleQA(
                    question: "Will Nifty touch a new all-time high this month?",
                    answer: "If buying pressure continues and global cues remain supportive, a new peak is possible.",
                    createdAt: Date()
                )
            ]
        ),
        
        NewsArticle(
            id: 3,
            title: "Gold Prices Hit 3-Month High",
            description: "Weak dollar and geopolitical tensions push gold prices higher.",
            imageName: "urban_8",
            category: "Commodities",
            date: "Yesterday",
            source: "Business Standard",
            qaHistory: [
                ArticleQA(
                    question: "Should long-term investors buy gold now?",
                    answer: "Gold can act as a hedge during uncertainty, but short-term volatility is possible.",
                    createdAt: Date()
                )
            ]
        ),
        
        NewsArticle(
            id: 4,
            title: "Tech Giants Report Strong Quarterly Results it is very good news",
            description: "IT sector sees renewed interest as major players beat earnings estimates.",
            imageName: "urban_2",
            category: "Technology",
            date: "Yesterday",
            source: "Reuters",
            qaHistory: [
                ArticleQA(
                    question: "How will strong earnings impact tech stocks?",
                    answer: "Better-than-expected earnings usually attract institutional investors and support price growth.",
                    createdAt: Date()
                )
            ]
        )
    ]
    
    // Existing methods
    func getAllNews() -> [NewsArticle] {
        return newsArticles
    }

    func getTodaysPick() -> NewsArticle? {
        return newsArticles.first
    }

    // New Methods
    func getArticle(by id: Int) -> NewsArticle? {
        return newsArticles.first { $0.id == id }
    }

    func addQA(for articleID: Int, question: String, answer: String) {
        guard let index = newsArticles.firstIndex(where: { $0.id == articleID }) else { return }
        
        let newQA = ArticleQA(
            question: question,
            answer: answer,
            createdAt: Date()
        )
        
        newsArticles[index].qaHistory.append(newQA)
    }

    func getQAHistory(for articleID: Int) -> [ArticleQA] {
        return newsArticles.first(where: { $0.id == articleID })?.qaHistory ?? []
    }
   
}
