//
//  Model.swift
//  SampleApp
//
//  Created by SDC-USER on 24/11/25.
//



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

    /// All questions & answers asked for this article
    var qaHistory: [ArticleQA] = []   // ✅ default value so old code still works
}
