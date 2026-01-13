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
            question: "Q)What best describes commodity inflation?",
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
            question: "Q)Repo rate is the rate at which:",
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
            question: "Q)What best describes commodity inflation?",
            options: [
                "Increase in prices of raw materials",
                "Fall in stock market prices",
                "Rise in wages",
                "Increase in taxes"
            ],
            correctIndex: 0
        ),
        JargonQuiz(
            jargonWord: "Safe-Haven Asset",
            question: "Q)What best describes commodity inflation?",
            options: [
                "Increase in prices of raw materials",
                "Fall in stock market prices",
                "Rise in wages",
                "Increase in taxes"
            ],
            correctIndex: 0
        ),
        JargonQuiz(
            jargonWord: "Strategic Consulting",
            question: "Q)What best describes commodity inflation?",
            options: [
                "Increase in prices of raw materials",
                "Fall in stock market prices",
                "Rise in wages",
                "Increase in taxes"
            ],
            correctIndex: 0
        ),
        JargonQuiz(
            jargonWord: "Market Diversification",
            question: "Q)What best describes commodity inflation?",
            options: [
                "Increase in prices of raw materials",
                "Fall in stock market prices",
                "Rise in wages",
                "Increase in taxes"
            ],
            correctIndex: 0
        ),
        JargonQuiz(
            jargonWord: "Operational Risk",
            question: "Q)What best describes commodity inflation?",
            options: [
                "Increase in prices of raw materials",
                "Fall in stock market prices",
                "Rise in wages",
                "Increase in taxes"
            ],
            correctIndex: 0
        ),
        JargonQuiz(
            jargonWord: "Monetary Policy",
            question: "Q)What best describes commodity inflation?",
            options: [
                "Increase in prices of raw materials",
                "Fall in stock market prices",
                "Rise in wages",
                "Increase in taxes"
            ],
            correctIndex: 0
        ),
        JargonQuiz(
            jargonWord: "Inflation Targeting",
            question: "Q)What best describes commodity inflation?",
            options: [
                "Increase in prices of raw materials",
                "Fall in stock market prices",
                "Rise in wages",
                "Increase in taxes"
            ],
            correctIndex: 0
        ),
        JargonQuiz(
            jargonWord: "Quarterly Earnings",
            question: "Q)What best describes commodity inflation?",
            options: [
                "Increase in prices of raw materials",
                "Fall in stock market prices",
                "Rise in wages",
                "Increase in taxes"
            ],
            correctIndex: 0
        ),
        JargonQuiz(
            jargonWord: "Tech Valuation",
            question: "Q)What best describes commodity inflation?",
            options: [
                "Increase in prices of raw materials",
                "Fall in stock market prices",
                "Rise in wages",
                "Increase in taxes"
            ],
            correctIndex: 0
        ),
        JargonQuiz(
            jargonWord: "Market Sentiment",
            question: "Q)What best describes commodity inflation?",
            options: [
                "Increase in prices of raw materials",
                "Fall in stock market prices",
                "Rise in wages",
                "Increase in taxes"
            ],
            correctIndex: 0
        ),
    ]

    static func quiz(for jargon: String) -> JargonQuiz? {
        quizzes.first { $0.jargonWord == jargon }
    }
}


var pages: [JargonPage] = [
    JargonPage(
        title: "Definition",
        content: "Commodity inflation refers to a sustained rise in the prices of basic raw materials such as food grains, crude oil, natural gas, and industrial metals. These commodities are essential inputs for producing goods and services, so when their prices increase, the cost of manufacturing, transportation, and energy also rises. As a result, businesses often pass these higher costs on to consumers in the form of increased prices, contributing to overall inflation in the economy. Commodity inflation can occur due to factors such as higher global demand, supply shortages caused by natural disasters or geopolitical tensions, increased transportation and energy costs, currency depreciation, or disruptions in production. It reduces purchasing power, increases the cost of living, and plays a significant role in influencing economic growth, government policies, and central bank decisions on interest rates."
    ),
    JargonPage(
        title: "Real World Example",
        content: "Commodity inflation refers to a sustained rise in the prices of basic raw materials such as food grains, crude oil, natural gas, and industrial metals. These commodities are essential inputs for producing goods and services, so when their prices increase, the cost of manufacturing, transportation, and energy also rises. As a result, businesses often pass these higher costs on to consumers in the form of increased prices, contributing to overall inflation in the economy. Commodity inflation can occur due to factors such as higher global demand, supply shortages caused by natural disasters or geopolitical tensions, increased transportation and energy costs, currency depreciation, or disruptions in production. It reduces purchasing power, increases the cost of living, and plays a significant role in influencing economic growth, government policies, and central bank decisions on interest rates."
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
        )
    ]

    func quizForArticle(articleId: Int) -> [QuizQuestion] {
        return quizzes.filter { $0.articleId == articleId }
    }
}
