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
            date: "16 Hours Ago",
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
            date: "2 Hours Ago",
            source: "Economic Times",
            
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
            imageName: "Screenshot 2025-12-17 at 10.44.49 AM",
            category: "Markets",
            date: "5 Hours Ago",
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
            date: "18 Hours Ago",
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
    
    func getAllNews() -> [NewsArticle] {
        return newsArticles
    }

    func getTodaysPick() -> NewsArticle? {
        return newsArticles.first
    }

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


struct JargonQuizStore {

    static let quizzes: [JargonQuiz] = [

        JargonQuiz(
            jargonWord: "Commodity Inflation",
            question: "Q) What best describes commodity inflation?",
            options: [
                "Increase in prices of raw materials",
                "Fall in stock market prices",
                "Rise in wages",
                "Increase in taxes"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Repo Rate",
            question: "Q) Repo rate is the rate at which:",
            options: [
                "Banks lend to customers",
                "RBI lends to commercial banks",
                "Government borrows money",
                "Banks lend to RBI"
            ],
            correctIndex: 1
        ),

        JargonQuiz(
            jargonWord: "Dollar Index",
            question: "Q) Dollar Index measures:",
            options: [
                "Value of the US dollar against major currencies",
                "US inflation rate",
                "Gold price movement",
                "US stock market performance"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Safe-Haven Asset",
            question: "Q) A safe-haven asset is one that:",
            options: [
                "Performs well during market uncertainty",
                "Always gives high returns",
                "Is issued only by governments",
                "Is used for short-term trading"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Strategic Consulting",
            question: "Q) Strategic consulting mainly focuses on:",
            options: [
                "Long-term business strategy and growth",
                "Daily operational tasks",
                "Employee payroll management",
                "IT infrastructure maintenance"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Market Diversification",
            question: "Q) Market diversification helps investors by:",
            options: [
                "Reducing overall risk",
                "Guaranteeing profits",
                "Avoiding taxes",
                "Increasing short-term volatility"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Operational Risk",
            question: "Q) Operational risk arises due to:",
            options: [
                "Failures in processes, people, or systems",
                "Changes in interest rates",
                "Stock market fluctuations",
                "Foreign exchange movements"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Monetary Policy",
            question: "Q) Monetary policy is controlled by:",
            options: [
                "Central bank",
                "Commercial banks",
                "Stock exchanges",
                "Private investors"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Inflation Targeting",
            question: "Q) Inflation targeting means:",
            options: [
                "Keeping inflation within a predefined range",
                "Eliminating inflation completely",
                "Controlling stock prices",
                "Fixing currency exchange rates"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Quarterly Earnings",
            question: "Q) Quarterly earnings represent:",
            options: [
                "Company’s financial performance every three months",
                "Annual revenue of a company",
                "Stock price movement",
                "Dividend payout frequency"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Tech Valuation",
            question: "Q) Tech valuation refers to:",
            options: [
                "Estimating the worth of technology companies",
                "Measuring internet speed",
                "Evaluating software bugs",
                "Calculating employee productivity"
            ],
            correctIndex: 0
        ),

        JargonQuiz(
            jargonWord: "Market Sentiment",
            question: "Q) Market sentiment reflects:",
            options: [
                "Overall investor attitude toward the market",
                "Company balance sheets",
                "Government fiscal policy",
                "Foreign trade balance"
            ],
            correctIndex: 0
        )
    ]

    static func quiz(for jargon: String) -> JargonQuiz? {
        quizzes.first { $0.jargonWord == jargon }
    }
}

var allPages: [JargonPage] = [

    JargonPage(
        jargonWord: "Commodity Inflation",
        title: "Definition",
        content: "Commodity inflation refers to a sustained rise in the prices of basic raw materials such as food grains, crude oil, natural gas, and industrial metals. These commodities are essential inputs for producing goods and services, so when their prices increase, the cost of manufacturing, transportation, and energy also rises. As a result, businesses often pass these higher costs on to consumers in the form of increased prices, contributing to overall inflation in the economy. Commodity inflation can occur due to factors such as higher global demand, supply shortages caused by natural disasters or geopolitical tensions, increased transportation and energy costs, currency depreciation, or disruptions in production. It reduces purchasing power, increases the cost of living, and plays a significant role in influencing economic growth, government policies, and central bank decisions on interest rates."
    ),
    JargonPage(
        jargonWord: "Commodity Inflation",
        title: "Real World Example",
        content: "Market sentiment can be observed during major economic announcements or global events. For example, if inflation data comes in lower than expected, investors may feel optimistic about economic stability and future growth. This positive sentiment can lead to increased buying of stocks, pushing market indices higher. On the other hand, news of a recession, geopolitical conflict, or banking crisis can create fear among investors. As a result, many may sell stocks and move their money into safer assets such as gold or government bonds. These reactions show how market sentiment, driven by perception and emotion, can significantly influence market behavior."
    ),

    JargonPage(
        jargonWord: "Repo Rate",
        title: "Definition",
        content: "Repo rate refers to the interest rate at which a country’s central bank lends money to commercial banks for short-term needs. It is one of the most important tools of monetary policy used by central banks, such as the RBI, to control liquidity and inflation in the economy. When banks face a shortage of funds, they borrow money from the central bank by pledging government securities as collateral. A lower repo rate makes borrowing cheaper for banks, encouraging them to lend more to businesses and consumers, thereby stimulating economic growth. Conversely, a higher repo rate makes borrowing expensive, discouraging excessive lending and helping to control inflation. Changes in the repo rate directly impact interest rates on loans, EMIs, and overall economic activity."
    ),
    JargonPage(
        jargonWord: "Repo Rate",
        title: "Real World Example",
        content: "When inflation rises sharply, the central bank may increase the repo rate. As a result, banks borrow at higher costs and pass this on to customers through higher loan interest rates. Home loans, car loans, and business loans become more expensive, reducing consumer spending and investment. This slowdown in demand helps bring inflation under control. On the other hand, during an economic slowdown, the central bank may cut the repo rate to make borrowing cheaper, encouraging businesses to invest and consumers to spend more."
    ),
    JargonPage(
        jargonWord: "Dollar Index",
        title: "Definition",
        content: "The Dollar Index is a measure of the value of the United States dollar relative to a basket of major global currencies, such as the euro, yen, pound, and others. It reflects the overall strength or weakness of the dollar in international markets. A rising Dollar Index indicates a strengthening dollar, meaning it can buy more foreign currency, while a falling index suggests a weakening dollar. The Dollar Index is closely watched by investors, traders, and policymakers because it influences global trade, capital flows, commodity prices, and emerging market economies. Since many commodities like oil and gold are priced in dollars, changes in the Dollar Index can have widespread economic implications."
    ),
    JargonPage(
        jargonWord: "Dollar Index",
        title: "Real World Example",
        content: "If the Dollar Index rises sharply, imported goods become cheaper for U.S. consumers, but exports become more expensive for foreign buyers. This can reduce export demand from other countries. At the same time, commodities priced in dollars, such as oil and gold, often fall in price globally. Emerging market currencies may weaken as investors move money into the stronger dollar, affecting their economies and increasing the cost of servicing dollar-denominated debt."
    ),
    JargonPage(
        jargonWord: "Safe-Haven Asset",
        title: "Definition",
        content: "A safe-haven asset is an investment that is expected to retain or increase its value during periods of economic uncertainty, financial instability, or market volatility. Investors turn to safe-haven assets when confidence in riskier investments such as stocks declines. These assets are considered reliable stores of value due to their stability, liquidity, and global acceptance. Common examples include gold, government bonds, and certain currencies like the US dollar or Swiss franc. The demand for safe-haven assets increases during geopolitical tensions, recessions, or financial crises, making them an important component of risk management and portfolio diversification."
    ),
    JargonPage(
        jargonWord: "Safe-Haven Asset",
        title: "Real World Example",
        content: "During a global financial crisis or a major geopolitical conflict, stock markets may experience sharp declines due to uncertainty. In such situations, investors often move their money into gold or government bonds, which are perceived as safer investments. For example, during economic downturns, gold prices often rise as investors seek protection against market volatility, while demand for government bonds increases due to their lower risk."
    ),
    JargonPage(
        jargonWord: "Strategic Consulting",
        title: "Definition",
        content: "Strategic consulting is a professional advisory service that helps organizations develop long-term strategies to achieve competitive advantage, improve performance, and drive sustainable growth. Consultants analyze a company’s internal capabilities, market position, industry trends, and competitive landscape to provide insights and recommendations. Strategic consulting focuses on high-level decisions such as market entry, business expansion, mergers and acquisitions, cost optimization, and organizational restructuring. It plays a crucial role in helping businesses adapt to changing market conditions and make informed decisions that align with their long-term goals."
    ),
    JargonPage(
        jargonWord: "Strategic Consulting",
        title: "Real World Example",
        content: "A company facing declining market share may hire a strategic consulting firm to identify growth opportunities. Consultants might analyze consumer behavior, assess competitor strategies, and recommend entering new markets or launching innovative products. Based on these insights, the company can restructure its operations, reallocate resources, and adopt a new strategy to regain competitiveness and profitability."
    ),
    JargonPage(
        jargonWord: "Market Diversification",
        title: "Definition",
        content: "Market diversification is a strategy used by businesses and investors to reduce risk by expanding into different markets, products, industries, or asset classes. Instead of relying on a single source of revenue or investment, diversification spreads exposure across multiple areas. This helps minimize the impact of poor performance in any one segment. In investing, diversification involves holding a mix of assets such as stocks, bonds, and commodities. For businesses, it may involve entering new geographical markets or offering new products. Diversification improves stability and long-term resilience."
    ),
    JargonPage(
        jargonWord: "Market Diversification",
        title: "Real World Example",
        content: "An investor who puts all their money into one stock faces high risk if that company performs poorly. By diversifying investments across multiple industries and asset types, losses in one area may be offset by gains in another. Similarly, a company that expands into international markets reduces its dependence on a single economy, helping it withstand regional downturns."
    ),
    JargonPage(
        jargonWord: "Operational Risk",
        title: "Definition",
        content: "Operational risk refers to the potential for losses resulting from failures in internal processes, systems, human error, or external events. Unlike financial risks that arise from market movements, operational risks stem from day-to-day business operations. These risks include system breakdowns, fraud, cybersecurity breaches, compliance failures, and natural disasters. Managing operational risk is critical for organizations to ensure continuity, protect assets, and maintain customer trust. Strong internal controls, risk assessments, and contingency planning are essential components of operational risk management."
    ),
    JargonPage(
        jargonWord: "Operational Risk",
        title: "Real World Example",
        content: "A bank experiencing a system outage may be unable to process transactions, leading to customer dissatisfaction and financial losses. Similarly, a manufacturing company facing supply chain disruptions due to natural disasters may experience delays and increased costs. These events highlight how operational risks can significantly impact business performance if not properly managed."
    ),
    JargonPage(
        jargonWord: "Monetary Policy",
        title: "Definition",
        content: "Monetary policy refers to the actions taken by a country’s central bank to regulate money supply and credit conditions in the economy. Its primary objectives are controlling inflation, maintaining price stability, and supporting economic growth. Central banks use tools such as interest rates, reserve requirements, and open market operations to influence borrowing and spending. An expansionary monetary policy increases money supply to stimulate growth, while a contractionary policy reduces money supply to control inflation. Monetary policy plays a crucial role in shaping economic conditions."
    ),
    JargonPage(
        jargonWord: "Monetary Policy",
        title: "Real World Example",
        content: "During an economic recession, a central bank may lower interest rates to encourage borrowing and investment. This makes loans cheaper for businesses and consumers, boosting spending and economic activity. Conversely, when inflation rises too high, the central bank may increase interest rates to reduce excess demand and stabilize prices."
    ),
    JargonPage(
        jargonWord: "Inflation Targeting",
        title: "Definition",
        content: "Inflation targeting is a monetary policy framework in which a central bank sets a specific inflation rate as its primary goal. The central bank uses interest rates and other policy tools to keep inflation within a predetermined range. This approach enhances transparency and accountability, helping manage public expectations about future inflation. By maintaining stable inflation, inflation targeting supports economic growth, protects purchasing power, and promotes financial stability. Many countries adopt inflation targeting to provide a clear policy direction."
    ),
    JargonPage(
        jargonWord: "Inflation Targeting",
        title: "Real World Example",
        content: "If inflation exceeds the target range, the central bank may raise interest rates to slow down spending and borrowing. Conversely, if inflation falls below the target, interest rates may be reduced to stimulate demand. This systematic approach helps businesses and consumers make long-term financial decisions with greater confidence."
    ),
    JargonPage(
        jargonWord: "Quarterly Earnings",
        title: "Definition",
        content: "Quarterly earnings refer to a company’s financial results reported every three months. These reports include key metrics such as revenue, profit, expenses, and earnings per share. Quarterly earnings provide insights into a company’s performance, growth prospects, and financial health. Investors and analysts closely monitor earnings reports to assess whether a company is meeting expectations. Positive or negative earnings surprises can significantly impact stock prices and investor sentiment."
    ),
    JargonPage(
        jargonWord: "Quarterly Earnings",
        title: "Real World Example",
        content: "If a company reports higher-than-expected quarterly earnings, its stock price may rise as investors gain confidence in its performance. On the other hand, disappointing earnings can lead to a decline in stock prices. Quarterly earnings reports also help management evaluate business strategies and make adjustments when necessary."
    ),
    JargonPage(
        jargonWord: "Tech Valuation",
        title: "Definition",
        content: "Tech valuation refers to the process of determining the economic value of technology companies. It considers factors such as revenue growth, profitability, innovation potential, user base, and market dominance. Unlike traditional industries, tech companies often rely on future growth prospects rather than current profits. As a result, valuations may appear high relative to earnings. Tech valuation plays a key role in investment decisions, mergers, acquisitions, and stock market analysis."
    ),
    JargonPage(
        jargonWord: "Tech Valuation",
        title: "Real World Example",
        content: "A technology startup with rapid user growth but low current profits may still receive a high valuation based on its future potential. Investors may value the company based on its ability to scale, innovate, and capture market share. Changes in interest rates or market sentiment can significantly impact tech valuations."
    ),
    JargonPage(
        jargonWord: "Market Sentiment",
        title: "Definition",
        content: "Market sentiment refers to the overall attitude or mood of investors toward financial markets or specific assets. It reflects whether investors feel optimistic or pessimistic about future market performance. Market sentiment is influenced by economic data, corporate earnings, geopolitical events, and news. Positive sentiment often leads to rising asset prices, while negative sentiment can result in market sell-offs. Understanding market sentiment helps investors anticipate short-term market movements."
    ),
    JargonPage(
        jargonWord: "Market Sentiment",
        title: "Real World Example",
        content: "Positive economic data and strong corporate earnings may boost investor confidence, leading to increased buying in stock markets. Conversely, negative news such as economic slowdowns or geopolitical tensions can cause fear, prompting investors to sell assets and move into safer investments. These shifts highlight the role of market sentiment in driving market behavior."
    )
    
]

class QuizStore {

    static let shared = QuizStore()
    private init() {}

    private let quizzes: [QuizQuestion] = [

      
        QuizQuestion(
            articleId: 1,
            question: "What was the main reason for the market rally?",
            options: [
                "Strong domestic investor participation",
                "Heavy foreign capital inflow",
                "Sudden fall in crude oil prices",
                "Major tax reforms announced"
            ],
            correctIndex: 0
        ),

        QuizQuestion(
            articleId: 1,
            question: "Which sector performed the best?",
            options: [
                "IT",
                "Banking and Financial Services",
                "Pharma",
                "Real Estate"
            ],
            correctIndex: 1
        ),

        QuizQuestion(
            articleId: 1,
            question: "Why were global markets uncertain?",
            options: [
                "Rising inflation",
                "Geopolitical tensions",
                "Natural disasters",
                "Trade surplus concerns"
            ],
            correctIndex: 1
        ),

        QuizQuestion(
            articleId: 1,
            question: "What did experts advise investors?",
            options: [
                "Exit equities",
                "Invest only in small caps",
                "Avoid long-term investments",
                "Stay invested long-term"
            ],
            correctIndex: 3
        ),
        
        QuizQuestion(
            articleId: 2,
            question: "Which technology is driving recent AI growth?",
            options: [
                "Blockchain",
                "Quantum Computing",
                "Generative AI",
                "5G Networks"
            ],
            correctIndex: 2
        ),
        QuizQuestion(
            articleId: 2,
            question: "Which technology is driving recent AI growth?",
            options: [
                "Blockchain",
                "Quantum Computing",
                "Generative AI",
                "5G Networks"
            ],
            correctIndex: 2
        ),
        QuizQuestion(
            articleId: 3,
            question: "Which technology is driving recent AI growth?",
            options: [
                "Blockchain",
                "Quantum Computing",
                "Generative AI",
                "5G Networks"
            ],
            correctIndex: 2
        ),
        QuizQuestion(
            articleId: 3,
            question: "Which technology is driving recent AI growth?",
            options: [
                "Blockchain",
                "Quantum Computing",
                "Generative AI",
                "5G Networks"
            ],
            correctIndex: 2
        ),
        QuizQuestion(
            articleId: 4,
            question: "Which technology is driving recent AI growth?",
            options: [
                "Blockchain",
                "Quantum Computing",
                "Generative AI",
                "5G Networks"
            ],
            correctIndex: 2
        ),
        QuizQuestion(
            articleId: 4,
            question: "Which technology is driving recent AI growth?",
            options: [
                "Blockchain",
                "Quantum Computing",
                "Generative AI",
                "5G Networks"
            ],
            correctIndex: 2
        ),
        QuizQuestion(
            articleId: 5,
            question: "Which technology is driving recent AI growth?",
            options: [
                "Blockchain",
                "Quantum Computing",
                "Generative AI",
                "5G Networks"
            ],
            correctIndex: 2
        ),
        QuizQuestion(
            articleId: 5,
            question: "Which technology is driving recent AI growth?",
            options: [
                "Blockchain",
                "Quantum Computing",
                "Generative AI",
                "5G Networks"
            ],
            correctIndex: 2
        )
    ]

    func quizForArticle(articleId: Int) -> [QuizQuestion] {
        return quizzes.filter { $0.articleId == articleId }
    }
}
