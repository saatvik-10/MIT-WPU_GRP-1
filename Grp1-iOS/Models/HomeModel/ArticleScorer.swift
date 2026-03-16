//
//  ArticleScorer.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 06/03/26.
//

import Foundation
import NaturalLanguage

// MARK: - User Profile (edit tags + weights here)

struct UserProfile1 {

    static let tags: [String] = [
        "banking",
        "stock market",
        "hdfc bank",
        "interest rate",
        "rbi",
        "technology",
        "digital banking",
        "fintech",
        "inflation",
        "economy",
        "credit growth",
        "regulation",
        "monetary policy",
        "financial sector"
    ]

    static let weights: [String: Double] = [
        "banking":          10,
        "stock market":     13,
        "hdfc bank":         8,
        "interest rate":    20,
        "rbi":              18,
        "technology":        7,
        "digital banking":   6,
        "fintech":           3,
        "inflation":        11,
        "economy":           4,
        "credit growth":     6,
        "regulation":        8,
        "monetary policy":  13,
        "financial sector":  9
    ]
}

// MARK: - Scorer

final class ArticleScorer {

    static let shared = ArticleScorer()
    private init() {}

    private let minConfidence:  Double = 0.45
    private let exactMatchBoost: Double = 1.0
    private let semanticFloor:  Double = 0.0

    // Lazy-load embedding once — it's expensive to load repeatedly
    private lazy var embedding: NLEmbedding? = NLEmbedding.wordEmbedding(for: .english)

    /// Returns a relevance score for the article against the user's interest profile.
    /// Higher = more relevant. Returns 0.0 if embeddings unavailable.
    func score(title: String, body: String) -> Double {

        guard let embedding = embedding else {
            print("⚠️  ArticleScorer — embeddings unavailable, defaulting to 0")
            return 0.0
        }

        let articleText = cleanText(title + " " + body)
        let phrases     = extractPhrases(from: articleText)

        var matchedTags: [String] = []

        for tag in UserProfile1.tags {
            let cleanedTag = cleanText(tag)
            let tagWords   = cleanedTag.split(separator: " ").map(String.init)

            var tagWordScores: [Double] = []

            for tagWord in tagWords {
                let tagRoot  = stem(tagWord)
                var bestScore = 0.0

                outer: for phrase in phrases {
                    let phraseWords = phrase.split(separator: " ").map(String.init)

                    if phrase.contains(tagWord) {
                        bestScore = exactMatchBoost
                        break outer
                    }

                    for phraseWord in phraseWords {
                        let phraseRoot = stem(phraseWord)

                        if tagWord == phraseWord || tagRoot == phraseRoot {
                            bestScore = exactMatchBoost
                            break outer
                        }

                        let distance   = embedding.distance(between: tagWord, and: phraseWord)
                        let similarity = max(semanticFloor, 1.0 - distance)
                        bestScore      = max(bestScore, similarity)
                    }
                }

                tagWordScores.append(bestScore)
            }

            let confidence = tagWordScores.isEmpty
                ? 0.0
                : tagWordScores.reduce(0, +) / Double(tagWordScores.count)

            if confidence >= minConfidence {
                matchedTags.append(tag)
            }
        }

        let score = matchedTags.reduce(0.0) { acc, tag in
            acc + (UserProfile1.weights[tag] ?? 0.0)
        }

        print("📊 Score: \(score) | Matched: \(matchedTags.joined(separator: ", ")) | '\(title.prefix(50))'")
        return score
    }

    // MARK: - Helpers

    private func cleanText(_ text: String) -> String {
        text.lowercased()
            .replacingOccurrences(of: "[^a-z0-9\\s]", with: "", options: .regularExpression)
    }

    private func extractPhrases(from text: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text

        var phrases: [String] = []
        var buffer:  [String] = []

        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .lexicalClass,
            options: [.omitWhitespace, .omitPunctuation]
        ) { tag, range in
            let word = String(text[range])
            if tag == .noun || tag == .adjective {
                buffer.append(word)
            } else if !buffer.isEmpty {
                phrases.append(buffer.joined(separator: " "))
                buffer.removeAll()
            }
            return true
        }

        if !buffer.isEmpty { phrases.append(buffer.joined(separator: " ")) }
        return phrases
    }

    private func stem(_ word: String) -> String {
        let suffixes = ["ing", "ed", "s", "es", "ly"]
        for suffix in suffixes {
            if word.hasSuffix(suffix) && word.count > suffix.count + 2 {
                return String(word.dropLast(suffix.count))
            }
        }
        return word
    }
}
