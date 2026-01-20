import Foundation
import UIKit

/// One question–answer pair asked about an article
struct ArticleQA {
    let question: String
    let answer: String
    let createdAt: Date
}

struct NewsArticle {
    let id: Int
    let title: String
    let description: String
    let imageName: String
    let category: String
    let date: String
    let source: String
    
    /// NEW FIELDS
    let overview: [String]                // summary
    let keyTakeaways: [String]          // main points
    let jargons: [String]               // technical words
    var selectedJargon: String? = ""

    /// All questions & answers asked for this article
    var qaHistory: [ArticleQA] = []
}

class selectedWord {
    static var word: String?
}

struct JargonPage {
    let jargonWord: String
    let title: String
    let content: String
}

struct JargonQuiz {
    let jargonWord: String
    let question: String
    let options: [String]      // exactly 4
    let correctIndex: Int      // 0–3
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

    // Commodity Inflation
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

    // Repo Rate
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




struct QuizQuestion {
    let articleId: Int   // 👈 Int link
    let question: String
    let options: [String]
    let correctIndex: Int
}



class QuizStore {

    static let shared = QuizStore()
    private init() {}

    private let quizzes: [QuizQuestion] = [

        // 🔹 Quiz for article ID = 101
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
        // 🔹 Quiz for article ID = 202
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
