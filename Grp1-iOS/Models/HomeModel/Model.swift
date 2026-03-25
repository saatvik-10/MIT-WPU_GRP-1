import Foundation
import UIKit

struct ArticleQA: Codable {
    let question: String
    let answer: String
    let createdAt: Date
}

struct NewsArticle: Codable {
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
    var relevanceScore: Double = 0.0   // ✅ NEW — scored at fetch time
    var bodyText: String   // ← add this

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
    var generatedQuestions: [QuizQuestion] = []   // ← store generated questions here
    var currentArticle: NewsArticle?          // ← add this

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
        summary: ArticleSummary,
        score: Double = 0.0          // ✅ NEW param
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
            qaHistory: [],
            relevanceScore: score,    // ✅ stored on the article
            bodyText: scraped.bodyText,        // ← add this

        )
    }
}
struct DateUtils {

    static func formattedArticleDate(from dateString: String) -> String {
        let output = DateFormatter()
        output.dateFormat = "MMM d, yyyy • h:mm a"
        output.locale = Locale.current

        // 1. ISO 8601 — used internally when assembling articles
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let date = isoFormatter.date(from: dateString) {
            return output.string(from: date)
        }

        // 2. RFC 2822 — used by TOI, ET, and Mint RSS feeds
        let rfc2822 = DateFormatter()
        rfc2822.locale = Locale(identifier: "en_US_POSIX")
        rfc2822.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        if let date = rfc2822.date(from: dateString) {
            return output.string(from: date)
        }

        // 3. RFC 2822 without seconds — some feeds omit them
        let rfc2822Short = DateFormatter()
        rfc2822Short.locale = Locale(identifier: "en_US_POSIX")
        rfc2822Short.dateFormat = "EEE, dd MMM yyyy HH:mm Z"
        if let date = rfc2822Short.date(from: dateString) {
            return output.string(from: date)
        }

        // Fallback — return raw string if nothing matched
        return dateString
    }
}

class AppTheme {
    static let shared = AppTheme()
    
    private init() {}
    
    var dominantColor: UIColor = .systemBackground
}





struct SavedArticle: Codable {
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
    var folderName: String
}

class SavedArticlesStore {
    static let shared = SavedArticlesStore()
    private init() { load() }

    private let cacheKey = "saved_articles"
    private(set) var savedArticles: [SavedArticle] = []

    func save(_ article: NewsArticle, to folderName: String) {
        guard !savedArticles.contains(where: { $0.id == article.id && $0.folderName == folderName }) else {
            print("⚠️ Already saved in \(folderName)")
            return
        }

        let saved = SavedArticle(
            id: article.id,
            title: article.title,
            description: article.description,
            imageName: article.imageName,
            category: article.category,
            date: article.date,
            source: article.source,
            overview: article.overview,
            keyTakeaways: article.keyTakeaways,
            jargons: article.jargons,
            selectedJargon: article.selectedJargon,
            folderName: folderName
        )

        savedArticles.append(saved)
        persist()
        print("💾 Saved '\(article.title)' to folder: \(folderName)")
    }

    func articles(in folderName: String) -> [SavedArticle] {
        savedArticles.filter { $0.folderName == folderName }
    }

    func remove(_ articleId: Int, from folderName: String) {
        savedArticles.removeAll { $0.id == articleId && $0.folderName == folderName }
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(savedArticles) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey)
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: cacheKey),
            let decoded = try? JSONDecoder().decode([SavedArticle].self, from: data)
        else { return }
        savedArticles = decoded
    }
}
