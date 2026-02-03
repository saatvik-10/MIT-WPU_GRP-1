import Foundation
import UIKit

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
    let overview: [String]
    let keyTakeaways: [String]
    let jargons: [String]
    var selectedJargon: String? = ""
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
    let options: [String]
    let correctIndex: Int
}

final class QuizContext {
    static let shared = QuizContext()
    private init() {}

    var selectedArticleId: Int?
}

struct QuizQuestion {
    let articleId: Int
    let question: String
    let options: [String]
    let correctIndex: Int
}


struct ScrapedArticle {
    let title: String
    let bodyText: String
    let imageName: String
    let source: String
    let publishedDate: String
}

struct articleSummary {
    let overview: [String]
    let keyTakeaways: [String]
    let jargons: [String]
}

struct NewsArticleAssembler {

    static func makeArticle(
        from scraped: ScrapedArticle,
        summary: ArticleSummary
    ) -> NewsArticle {

        return NewsArticle(
            id: Int.random(in: 1000...9999),
            title: scraped.title,
            description: String(scraped.bodyText.prefix(120)) + "...",
            imageName: scraped.imageName,
            category: "Auto",
            date: scraped.publishedDate,
            source: scraped.source,
            overview: summary.overview,
            keyTakeaways: summary.keyTakeaways,
            jargons: summary.jargons,
            selectedJargon: nil,
            qaHistory: []
        )
    }
}
struct DateUtils {

    static func formattedArticleDate(from isoString: String) -> String {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]

        guard let date = isoFormatter.date(from: isoString) else {
            return isoString
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy • h:mm a"
        formatter.locale = Locale.current

        return formatter.string(from: date)
    }
}

class AppTheme {
    static let shared = AppTheme()
    
    private init() {}
    
    var dominantColor: UIColor = .systemBackground
}




