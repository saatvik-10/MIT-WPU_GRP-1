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

struct QuizQuestion {
    let articleId: Int
    let question: String
    let options: [String]
    let correctIndex: Int
}




