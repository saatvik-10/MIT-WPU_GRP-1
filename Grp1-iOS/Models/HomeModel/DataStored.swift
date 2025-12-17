import Foundation

class NewsDataStore {
    
    static let shared = NewsDataStore()
    private init() {}
    
    private var newsArticles: [NewsArticle] = [
        
        
        NewsArticle(
            id: 1,
            title: "Tech Giants Report Strong Quarterly Results it is very good news",
            description: "IT sector sees renewed interest as major players beat earnings estimates.",
            imageName: "India-Brefing-Investing-in-India’s-IT-Sector",
            category: "Technology",
            date: "Yesterday",
            source: "Reuters",
            
            overview: [
                "Major technology firms posted significantly better-than-expected quarterly earnings, signaling renewed industry strength after months of global macroeconomic uncertainty.",
                "Robust demand for cloud services, AI infrastructure, and enterprise computing contributed heavily to revenue growth, exceeding analyst projections across multiple business segments.",
                "Market analysts believe these results may trigger increased investor confidence, potentially fueling further rallies in tech stocks that have already seen notable upward momentum.",
                "Executives across the sector emphasized continued investment in artificial intelligence, automation, and next-generation hardware as long-term drivers of sustained profitability."
            ],
            
            keyTakeaways: [
                "Top technology companies exceeded revenue and profit expectations, signaling strong recovery momentum in the global tech sector.",
                "Improved cloud adoption and enterprise demand contributed significantly to the positive earnings performance.",
                "Market sentiment around IT stocks strengthened as investors reacted to the better-than-expected financial results.",
                "Analysts predict sustained growth as digital transformation accelerates across industries."
            ],
            
            jargons: [
                "Quarterly Earnings",
                "Tech Valuation",
                "Market Sentiment"
            ],
            
            qaHistory: [
                ArticleQA(
                    question: "How will strong earnings impact tech stocks?",
                    answer: "Better-than-expected earnings usually attract institutional investors and support price growth.",
                    createdAt: Date()
                )
            ]
        ),
        
        NewsArticle(
            id: 4,
            title: "RBI Maintains Status Quo on Interest Rates",
            description: "The RBI kept repo rate unchanged as inflation stabilizes. Markets reacted positively.",
            imageName: "rbi-1722414243",
            category: "Economy",
            date: "Today",
            source: "Economic Times",
            
            // NEW FIELDS
            overview: [
                "The RBI has opted to keep the repo rate unchanged for yet another policy cycle, emphasizing stability amid fluctuating inflation trends and uneven global economic cues.",
                "Central bank officials noted that inflation, while moderating, still requires careful monitoring, prompting them to prioritize monetary caution over aggressive rate adjustments.",
                "The decision is expected to support market sentiment, offering borrowers relief from immediate EMI hikes while giving policymakers room to steer the economy through global uncertainties.",
                "Economists believe that maintaining the current stance will help preserve liquidity conditions, especially as India prepares for increased capital expenditure and evolving fiscal demands."
            ],
            
            keyTakeaways: [
                "RBI continues its pause on repo rate hikes to support economic stability as inflation gradually moves within comfort levels.",
                "Home loan EMIs are likely to remain unchanged for now, offering relief to borrowers amid uncertain economic conditions.",
                "Market experts anticipate that a sustained decline in inflation could pave the way for future policy easing."
            ],
            
            jargons: [
                "Repo Rate",
                "Monetary Policy",
                "Inflation Targeting"
            ],
            
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
            title: "To de-Indianise US companies, top pollster Mark Mitchell plans to start consultancy",
            description: "Markets closed near the highs backed by strong buying across sectors.",
            imageName: "news_1",
            category: "Markets",
            date: "Today",
            source: "Moneycontrol",
            
            overview: [
                "Top pollster Mark Mitchell is launching a strategic consultancy aimed at reducing American corporate dependence on Indian outsourcing models, citing rising geopolitical and regulatory shifts.",
                "The initiative intends to help US firms restructure operational workflows, diversify vendor networks, and build more domestic talent pipelines to reduce vulnerability to international disruptions.",
                "Industry observers note that this shift could significantly alter global hiring patterns, potentially reshaping long-standing outsourcing relationships that have benefited both countries.",
                "Mitchell’s consultancy will focus on long-term structural changes rather than quick fixes, emphasizing sustainability, workforce resilience, and national economic interests."
            ],
            
            keyTakeaways: [
                "The new consultancy aims to help major US corporations diversify operations and reduce dependency on Indian service providers.",
                "Mitchell's strategy is expected to reshape outsourcing patterns and influence cross-border business dynamics.",
                "Industry analysts believe the move could create short-term disruption but also open opportunities for emerging global markets.",
                "The long-term impact on India–US economic relations remains uncertain as companies evaluate cost and talent availability."
            ],
            
            jargons: [
                "Strategic Consulting",
                "Market Diversification",
                "Operational Risk"
            ],
            
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
            imageName: "Screenshot 2025-12-17 at 10.09.02 AM",
            category: "Commodities",
            date: "Yesterday",
            source: "Business Standard",
            
            overview: [
                "Gold prices surged to a three-month high as geopolitical tensions and global market uncertainty pushed investors toward safe-haven assets, reversing earlier bearish sentiment.",
                "A weakening US dollar further strengthened gold's momentum, making the metal more attractive for international buyers and increasing demand across key markets.",
                "Analysts suggest that continued macroeconomic stress, including recession fears and volatile bond yields, could drive additional upward pressure on bullion prices in the near term.",
                "Experts caution that while long-term prospects remain strong, short-term fluctuations may persist as global central banks navigate inflation and adjust their monetary policy paths."
            ],
            
            keyTakeaways: [
                "Gold prices jumped sharply following increased geopolitical tensions, prompting investors to seek safe-haven assets.",
                "A weaker US dollar further boosted global gold demand, making the metal more attractive for international buyers.",
                "Long-term investors may view current trends as a signal to diversify portfolios with higher gold exposure."
            ],
            
            jargons: [
                "Safe-Haven Asset",
                "Dollar Index",
                "Commodity Inflation"
            ],
            
            qaHistory: [
                ArticleQA(
                    question: "Should long-term investors buy gold now?",
                    answer: "Gold can act as a hedge during uncertainty, but short-term volatility is possible.",
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
