//
//  ArticleScorer.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 06/03/26.
//
//  RESEARCH BASIS:
//  [1] Salton & Buckley (1987) — Term Weighting in Automatic Text Retrieval
//  [2] Lops, de Gemmis & Semeraro (2011) — Content-based Recommender Systems
//  [3] Claypool et al. (2001) — Implicit Interest Indicators
//  [4] Kelly & Teevan (2003) — Implicit Feedback for Inferring User Preference

import Foundation
import NaturalLanguage

// MARK: - Feedback Signal
// Claypool et al. (2001) — experimentally validated implicit signals
// Kelly & Teevan (2003) — signal ordering: explicit > retain > examine
// Lops et al. (2011) Section 3.2 — explicit feedback more reliable than implicit

enum FeedbackSignal {

    // EXPLICIT — user directly stated preference
    // Lops et al. Section 3.2: explicit feedback is well-understood and fairly precise
    case recommendMore
    case recommendLess

    // IMPLICIT — inferred from behaviour
    // Claypool et al.: time on page and scrolling have strong correlation with interest
    // Kelly & Teevan: retain behaviours (save) > examine behaviours (click)
    case readFull         // Claypool: time on page = strongest implicit signal
    case scrolledToBottom // Claypool: scrolling = strong implicit signal
    case bookmarked       // Kelly & Teevan: saving = stronger than selection
    case clicked          // Kelly & Teevan: selection = weaker evidence
    case scrolledPast     // Weak negative — user may have been busy
    case dismissed        // Strong negative — deliberate rejection

    // NOTE: mouse clicks alone are explicitly found unreliable by Claypool et al.
    // "the number of mouse clicks is not a good indicator of interest"
    // This is why clicked has the lowest positive value

    var value: Double {
        switch self {
        // Explicit signals — maximum magnitude
        // Lops et al.: explicit > implicit in reliability
        case .recommendMore:    return +1.0
        case .recommendLess:    return -1.0

        // Implicit signals — ordered by Claypool & Kelly & Teevan reliability ranking
        case .readFull:         return +0.7   // strongest implicit (Claypool)
        case .bookmarked:       return +0.6   // retain > examine (Kelly & Teevan)
        case .scrolledToBottom: return +0.5   // strong implicit (Claypool)
        case .clicked:          return +0.3   // weakest positive (Kelly & Teevan)
        case .scrolledPast:     return -0.1   // weak negative — unreliable
        case .dismissed:        return -0.4   // strong negative — deliberate

        // IMPORTANT: exact values are hyperparameters
        // The ordering above is backed by literature
        // Exact magnitudes require empirical tuning in deployment
        }
    }
}

// MARK: - User Profile
// Lops et al. (2011) Section 3.2:
// "Users can explicitly define their areas of interest
//  as an initial profile without providing any feedback"
// Equal initialisation (1.0) is correct when no prior feedback exists

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

    // All start at 1.0 — Lops et al.: equal initialisation with no prior feedback
    // These are NOT hardcoded importance values
    // They will adapt over time via Rocchio updates
    static var weights: [String: Double] = {
        var w: [String: Double] = [:]
        for tag in UserProfile1.tags {
            w[tag] = 1.0
        }
        return w
    }()

    // Rocchio parameters — Lops et al. Section 3.3.2.2
    // β > γ because negative feedback is rarer and less reliable
    // Lops et al.: "users do not perceive having immediate benefits
    //               from giving negative feedback"
    static let beta:  Double = 0.8   // positive learning rate
    static let gamma: Double = 0.2   // negative learning rate

    // Weight bounds — prevent runaway values
    static let minWeight: Double = 0.1
    static let maxWeight: Double = 5.0
}

// MARK: - Article Scorer
// Salton & Buckley (1987) — scoring formula:
// score = Σ confidence(tag) × weight(tag)
//              ↑                    ↑
//         how present          how important
//         in article           to this user

final class ArticleScorer {

    static let shared = ArticleScorer()
    private init() {}

    // Minimum confidence threshold to consider a tag matched
    private let minConfidence: Double = 0.45
    private let semanticFloor: Double = 0.0

    // NLEmbedding loaded once — expensive to reload
    private lazy var embedding: NLEmbedding? = NLEmbedding.wordEmbedding(for: .english)

    // MARK: - Score Article
    // Salton & Buckley (1987):
    // score = Σ confidence(tag) × weight(tag)
    // confidence used as MULTIPLIER not binary gate
    // An article scoring 0.95 confidence on a tag scores higher
    // than one scoring 0.46 — both pass the threshold but contribute differently

    func score(title: String, body: String) -> Double {

        guard let embedding = embedding else {
            print("⚠️  ArticleScorer — embeddings unavailable, defaulting to 0")
            return 0.0
        }

        let articleText = cleanText(title + " " + body)
        let phrases     = extractPhrases(from: articleText)

        var totalScore: Double = 0.0

        for tag in UserProfile1.tags {

            let confidence = computeConfidence(
                tag: tag,
                phrases: phrases,
                embedding: embedding
            )

            // Confidence used as multiplier — Salton & Buckley
            // Previously: binary (matched = full weight, not matched = 0)
            // Now: confidence × weight (proportional contribution)
            if confidence >= minConfidence {
                let userWeight = UserProfile1.weights[tag] ?? 1.0
                totalScore += confidence * userWeight

                print("✅ Tag: '\(tag)' | Confidence: \(String(format: "%.2f", confidence)) | Weight: \(String(format: "%.2f", userWeight)) | Contribution: \(String(format: "%.2f", confidence * userWeight))")
            }
        }

        print("📊 Final Score: \(String(format: "%.2f", totalScore)) | '\(title.prefix(50))'")
        return totalScore
    }

    // MARK: - Update Weights
    // Lops et al. (2011) Section 3.3.2.2 — Rocchio's Algorithm
    // new_weight = old_weight + β × signal  (positive)
    // new_weight = old_weight + γ × signal  (negative)
    // β > γ asymmetry justified by unreliability of negative feedback

    func updateWeights(for title: String, body: String, signal: FeedbackSignal) {

        guard let embedding = embedding else { return }

        let articleText = cleanText(title + " " + body)
        let phrases     = extractPhrases(from: articleText)

        for tag in UserProfile1.tags {

            let confidence = computeConfidence(
                tag: tag,
                phrases: phrases,
                embedding: embedding
            )

            // Only update weights for tags that were actually present
            // in this article — otherwise unrelated interests get updated
            guard confidence >= minConfidence else { continue }

            let oldWeight    = UserProfile1.weights[tag] ?? 1.0
            let signalValue  = signal.value

            let newWeight: Double

            if signalValue > 0 {
                // Positive interaction — Rocchio positive update with β
                // β = 0.8: system learns eagerly from positive signals
                newWeight = oldWeight + UserProfile1.beta * signalValue

            } else {
                // Negative interaction — Rocchio negative update with γ
                // γ = 0.2: system is cautious with negative signals
                // Lops et al.: negative feedback is rarer and less reliable
                newWeight = oldWeight + UserProfile1.gamma * signalValue
            }

            // Clamp to bounds — prevent weights going to zero or infinity
            UserProfile1.weights[tag] = max(
                UserProfile1.minWeight,
                min(newWeight, UserProfile1.maxWeight)
            )

            print("🔄 Updated '\(tag)': \(String(format: "%.2f", oldWeight)) → \(String(format: "%.2f", UserProfile1.weights[tag]!)) | Signal: \(signal)")
        }
    }

    // MARK: - Compute Confidence
    // Core semantic matching logic
    // Returns a value between 0.0 and 1.0
    // 1.0 = exact match, lower = semantic similarity via NLEmbedding

    private func computeConfidence(
        tag: String,
        phrases: [String],
        embedding: NLEmbedding
    ) -> Double {

        let cleanedTag = cleanText(tag)
        let tagWords   = cleanedTag.split(separator: " ").map(String.init)

        var tagWordScores: [Double] = []

        for tagWord in tagWords {
            let tagRoot   = stem(tagWord)
            var bestScore = 0.0

            outer: for phrase in phrases {
                let phraseWords = phrase.split(separator: " ").map(String.init)

                // Exact phrase match — highest confidence
                if phrase.contains(tagWord) {
                    bestScore = 1.0
                    break outer
                }

                for phraseWord in phraseWords {
                    let phraseRoot = stem(phraseWord)

                    // Stem match — high confidence
                    if tagWord == phraseWord || tagRoot == phraseRoot {
                        bestScore = 1.0
                        break outer
                    }

                    // Semantic similarity via NLEmbedding
                    // distance 0 = identical, distance 1 = completely different
                    // similarity = 1 - distance
                    let distance   = embedding.distance(between: tagWord, and: phraseWord)
                    let similarity = max(semanticFloor, 1.0 - distance)
                    bestScore      = max(bestScore, similarity)
                }
            }

            tagWordScores.append(bestScore)
        }

        // Average score across all words in a multi-word tag
        // e.g. "interest rate" = average of score("interest") and score("rate")
        return tagWordScores.isEmpty
            ? 0.0
            : tagWordScores.reduce(0, +) / Double(tagWordScores.count)
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

















////
////  ArticleScorer.swift
////  Grp1-iOS
////
////  Created by SDC-USER on 06/03/26.
////
//
//import Foundation
//import NaturalLanguage
//
//// MARK: - User Profile (edit tags + weights here)
//
//struct UserProfile1 {
//
//    static let tags: [String] = [
//        "banking",
//        "stock market",
//        "hdfc bank",
//        "interest rate",
//        "rbi",
//        "technology",
//        "digital banking",
//        "fintech",
//        "inflation",
//        "economy",
//        "credit growth",
//        "regulation",
//        "monetary policy",
//        "financial sector"
//    ]
//
//    static let weights: [String: Double] = [
//        "banking":          10,
//        "stock market":     13,
//        "hdfc bank":         8,
//        "interest rate":    20,
//        "rbi":              18,
//        "technology":        7,
//        "digital banking":   6,
//        "fintech":           3,
//        "inflation":        11,
//        "economy":           4,
//        "credit growth":     6,
//        "regulation":        8,
//        "monetary policy":  13,
//        "financial sector":  9
//    ]
//}
//
//// MARK: - Scorer
//
//final class ArticleScorer {
//
//    static let shared = ArticleScorer()
//    private init() {}
//
//    private let minConfidence:  Double = 0.45
//    private let exactMatchBoost: Double = 1.0
//    private let semanticFloor:  Double = 0.0
//
//    // Lazy-load embedding once — it's expensive to load repeatedly
//    private lazy var embedding: NLEmbedding? = NLEmbedding.wordEmbedding(for: .english)
//
//    /// Returns a relevance score for the article against the user's interest profile.
//    /// Higher = more relevant. Returns 0.0 if embeddings unavailable.
//    func score(title: String, body: String) -> Double {
//
//        guard let embedding = embedding else {
//            print("⚠️  ArticleScorer — embeddings unavailable, defaulting to 0")
//            return 0.0
//        }
//
//        let articleText = cleanText(title + " " + body)
//        let phrases     = extractPhrases(from: articleText)
//
//        var matchedTags: [String] = []
//
//        for tag in UserProfile1.tags {
//            let cleanedTag = cleanText(tag)
//            let tagWords   = cleanedTag.split(separator: " ").map(String.init)
//
//            var tagWordScores: [Double] = []
//
//            for tagWord in tagWords {
//                let tagRoot  = stem(tagWord)
//                var bestScore = 0.0
//
//                outer: for phrase in phrases {
//                    let phraseWords = phrase.split(separator: " ").map(String.init)
//
//                    if phrase.contains(tagWord) {
//                        bestScore = exactMatchBoost
//                        break outer
//                    }
//
//                    for phraseWord in phraseWords {
//                        let phraseRoot = stem(phraseWord)
//
//                        if tagWord == phraseWord || tagRoot == phraseRoot {
//                            bestScore = exactMatchBoost
//                            break outer
//                        }
//
//                        let distance   = embedding.distance(between: tagWord, and: phraseWord)
//                        let similarity = max(semanticFloor, 1.0 - distance)
//                        bestScore      = max(bestScore, similarity)
//                    }
//                }
//
//                tagWordScores.append(bestScore)
//            }
//
//            let confidence = tagWordScores.isEmpty
//                ? 0.0
//                : tagWordScores.reduce(0, +) / Double(tagWordScores.count)
//
//            if confidence >= minConfidence {
//                matchedTags.append(tag)
//            }
//        }
//
//        let score = matchedTags.reduce(0.0) { acc, tag in
//            acc + (UserProfile1.weights[tag] ?? 0.0)
//        }
//
//        print("📊 Score: \(score) | Matched: \(matchedTags.joined(separator: ", ")) | '\(title.prefix(50))'")
//        return score
//    }
//
//    // MARK: - Helpers
//
//    private func cleanText(_ text: String) -> String {
//        text.lowercased()
//            .replacingOccurrences(of: "[^a-z0-9\\s]", with: "", options: .regularExpression)
//    }
//
//    private func extractPhrases(from text: String) -> [String] {
//        let tagger = NLTagger(tagSchemes: [.lexicalClass])
//        tagger.string = text
//
//        var phrases: [String] = []
//        var buffer:  [String] = []
//
//        tagger.enumerateTags(
//            in: text.startIndex..<text.endIndex,
//            unit: .word,
//            scheme: .lexicalClass,
//            options: [.omitWhitespace, .omitPunctuation]
//        ) { tag, range in
//            let word = String(text[range])
//            if tag == .noun || tag == .adjective {
//                buffer.append(word)
//            } else if !buffer.isEmpty {
//                phrases.append(buffer.joined(separator: " "))
//                buffer.removeAll()
//            }
//            return true
//        }
//
//        if !buffer.isEmpty { phrases.append(buffer.joined(separator: " ")) }
//        return phrases
//    }
//
//    private func stem(_ word: String) -> String {
//        let suffixes = ["ing", "ed", "s", "es", "ly"]
//        for suffix in suffixes {
//            if word.hasSuffix(suffix) && word.count > suffix.count + 2 {
//                return String(word.dropLast(suffix.count))
//            }
//        }
//        return word
//    }
//}
