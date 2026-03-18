//
//  BlogRecommendationEngine.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 18/03/26.
//

//  Personalised blog recommendation engine.
//  Builds on the ArticleScorer NLP approach and adds:
//    • Interest → tag mapping from onboarding categories
//    • User level (beginner / intermediate / advanced) content multiplier
//    • Engagement-based dynamic weight reinforcement
//    • Freshness decay so stale articles are down-ranked
//    • Diversity injection to avoid tag clustering in the feed
//    • Seen-article deduplication
 
import Foundation
import NaturalLanguage
 
// MARK: - Onboarding models
 
/// Mirrors OnboardingInterestModel from your app
enum OnboardingInterest: String, CaseIterable, Codable {
    case indianEconomy      = "Indian Economy"
    case personalFinance    = "Personal Finance"
    case governmentPolicy   = "Government and Policy"
    case stockMarkets       = "Stock Markets"
    case realEstate         = "Real Estate Economics"
    case globalEconomy      = "Global Economy"
    case bankingCredit      = "Banking and credit"
    case crypto             = "Crypto"
}
 
enum BlogUserLevel: String, Codable {
    case beginner       = "Beginner"
    case intermediate   = "Intermediate"
    case advanced       = "Advanced"
 
    /// Multiplier applied to the complexity sub-score of an article
    var complexityMultiplier: Double {
        switch self {
        case .beginner:     return 1.4   // boost simple explainers
        case .intermediate: return 1.0
        case .advanced:     return 1.3   // boost deep-dives
        }
    }
 
    /// Preferred complexity tier (0 = basic, 1 = medium, 2 = deep)
    var preferredComplexityTier: Int {
        switch self {
        case .beginner:     return 0
        case .intermediate: return 1
        case .advanced:     return 2
        }
    }
}
 
// MARK: - Tag taxonomy
 
/// Maps each onboarding interest to a set of weighted NLP tags.
/// Grow this table to tune relevance without touching scoring logic.
struct InterestTagMap {
 
    static let map: [OnboardingInterest: [String: Double]] = [
 
        .indianEconomy: [
            "inflation":            15,
            "gdp":                  14,
            "rbi":                  13,
            "economy":              12,
            "monetary policy":      13,
            "interest rate":        11,
            "consumption":          10,
            "cpi":                   9,
            "fiscal deficit":        9,
            "economic growth":      10,
            "india":                 6,
            "budget":                8
        ],
 
        .personalFinance: [
            "personal finance":     16,
            "savings":              14,
            "investment":           13,
            "mutual fund":          12,
            "tax":                  11,
            "insurance":            10,
            "retirement":           10,
            "sip":                   9,
            "portfolio":             9,
            "wealth":                8,
            "loan":                  7,
            "credit score":          8
        ],
 
        .governmentPolicy: [
            "government":           14,
            "policy":               14,
            "regulation":           13,
            "reform":               12,
            "budget":               11,
            "public spending":      11,
            "subsidy":              10,
            "tax policy":           10,
            "rbi":                   9,
            "sebi":                  9,
            "compliance":            8
        ],
 
        .stockMarkets: [
            "stock market":         16,
            "nifty":                14,
            "sensex":               14,
            "equity":               13,
            "ipo":                  12,
            "shares":               12,
            "market cap":           11,
            "earnings":             11,
            "dividend":             10,
            "bull market":          10,
            "bear market":          10,
            "technical analysis":    9
        ],
 
        .realEstate: [
            "real estate":          16,
            "housing":              14,
            "property":             13,
            "mortgage":             12,
            "home loan":            12,
            "interest rate":        10,
            "construction":          9,
            "rent":                  8,
            "realty":                9,
            "demand":                7,
            "supply":                7
        ],
 
        .globalEconomy: [
            "global economy":       15,
            "trade":                13,
            "exports":              12,
            "imports":              12,
            "tariff":               11,
            "fed":                  11,
            "dollar":               10,
            "recession":            10,
            "geopolitics":           9,
            "oil price":            10,
            "currency":              9,
            "world bank":            8
        ],
 
        .bankingCredit: [
            "banking":              15,
            "credit":               14,
            "loan":                 13,
            "npa":                  12,
            "credit growth":        12,
            "hdfc bank":            10,
            "sbi":                  10,
            "rbi":                  11,
            "digital banking":      10,
            "fintech":               9,
            "financial sector":      9,
            "liquidity":             8
        ],
 
        .crypto: [
            "crypto":               16,
            "bitcoin":              15,
            "blockchain":           14,
            "web3":                 13,
            "defi":                 12,
            "nft":                  11,
            "ethereum":             12,
            "digital assets":       11,
            "token":                10,
            "stablecoin":           10,
            "regulation":            8
        ]
    ]
 
    /// Merges tag weights from all selected interests.
    /// Overlapping tags are summed so cross-interest articles score higher.
    static func mergedWeights(for interests: [OnboardingInterest]) -> [String: Double] {
        var merged: [String: Double] = [:]
        for interest in interests {
            for (tag, weight) in map[interest] ?? [:] {
                merged[tag, default: 0] += weight
            }
        }
        return merged
    }
 
    static func allTags(for interests: [OnboardingInterest]) -> [String] {
        Array(mergedWeights(for: interests).keys)
    }
}
 
// MARK: - User profile (persisted)
 
struct DynamicUserProfile: Codable {
 
    var interests: [OnboardingInterest]
    var level: BlogUserLevel
 
    /// Tag weights — seeded from interests, updated via engagement feedback
    var tagWeights: [String: Double]
 
    /// Articles the user has already seen (by article ID)
    var seenArticleIDs: Set<String>
 
    /// IDs of bookmarked / liked articles
    var likedArticleIDs: Set<String>
 
    init(interests: [OnboardingInterest], level: BlogUserLevel) {
        self.interests = interests
        self.level = level
        self.tagWeights = InterestTagMap.mergedWeights(for: interests)
        self.seenArticleIDs = []
        self.likedArticleIDs = []
    }
 
    // MARK: Engagement feedback
 
    mutating func recordLike(article: BlogArticle) {
        likedArticleIDs.insert(article.id)
        reinforceWeights(from: article, multiplier: 1.2)
    }
 
    mutating func recordBookmark(article: BlogArticle) {
        likedArticleIDs.insert(article.id)
        reinforceWeights(from: article, multiplier: 1.5)
    }
 
    mutating func recordShare(article: BlogArticle) {
        reinforceWeights(from: article, multiplier: 1.3)
    }
 
    /// Penalise tags if user skips / dismisses article early
    mutating func recordSkip(article: BlogArticle) {
        reinforceWeights(from: article, multiplier: 0.85)
    }
 
    mutating func markSeen(articleID: String) {
        seenArticleIDs.insert(articleID)
    }
 
    // MARK: Weight decay (call periodically, e.g. daily)
 
    /// Gently decay all weights toward their onboarding baseline so old
    /// engagement signals don't permanently crowd out fresh interests.
    mutating func applyWeeklyDecay(decayFactor: Double = 0.97) {
        let baseline = InterestTagMap.mergedWeights(for: interests)
        for key in tagWeights.keys {
            let base = baseline[key] ?? 0
            tagWeights[key] = base + (tagWeights[key]! - base) * decayFactor
        }
    }
 
    private mutating func reinforceWeights(from article: BlogArticle, multiplier: Double) {
        for tag in article.inferredTags {
            guard tagWeights[tag] != nil else { continue }
            tagWeights[tag]! *= multiplier
        }
    }
}
 
// MARK: - Blog article model
 
struct BlogArticle {
    let id: String
    let title: String
    let body: String
    let category: String          // maps loosely to OnboardingInterest raw value
    let publishedAt: Date
    let complexityTier: Int       // 0 = beginner, 1 = intermediate, 2 = advanced
    var inferredTags: [String]    // populated by scorer after first run
}
 
// MARK: - Scoring config
 
struct ScoringConfig {
    let minConfidence: Double = 0.45
    let exactMatchBoost: Double = 1.0
    let semanticFloor: Double = 0.0
    /// Half-life for freshness decay in days. Score halves every N days.
    let freshnessHalfLifeDays: Double = 7.0
    /// Diversity: penalise if a category already has N articles in the ranked list
    let diversityPenaltyAfter: Int = 2
    let diversityPenaltyFactor: Double = 0.6
}
 
// MARK: - Recommendation engine
 
final class BlogRecommendationEngine {
 
    static let shared = BlogRecommendationEngine()
    private init() {}
 
    private let config = ScoringConfig()
    private lazy var embedding: NLEmbedding? = NLEmbedding.wordEmbedding(for: .english)
 
    // MARK: - Main API
 
    /// Returns articles sorted by personalised relevance.
    func recommend(
        articles: [BlogArticle],
        profile: inout DynamicUserProfile,
        limit: Int = 20,
        excludeSeen: Bool = true
    ) -> [ScoredArticle] {
 
        let pool = excludeSeen
            ? articles.filter { !profile.seenArticleIDs.contains($0.id) }
            : articles
 
        var scored: [ScoredArticle] = pool.map { article in
            let (baseScore, matchedTags) = computeBaseScore(article: article, profile: profile)
            let levelMult   = levelMultiplier(article: article, level: profile.level)
            let freshness   = freshnessScore(publishedAt: article.publishedAt)
            let final       = baseScore * levelMult * freshness
 
            var mutable = article
            mutable.inferredTags = matchedTags
            return ScoredArticle(
                article: mutable,
                baseScore: baseScore,
                levelMultiplier: levelMult,
                freshnessScore: freshness,
                finalScore: final,
                matchedTags: matchedTags
            )
        }
 
        scored.sort { $0.finalScore > $1.finalScore }
        let diversified = applyDiversityFilter(scored: scored)
        return Array(diversified.prefix(limit))
    }
 
    // MARK: - Base NLP score
 
    private func computeBaseScore(
        article: BlogArticle,
        profile: DynamicUserProfile
    ) -> (score: Double, matchedTags: [String]) {
 
        guard let embedding = embedding else { return (0.0, []) }
 
        let text    = cleanText(article.title + " " + article.body)
        let phrases = extractPhrases(from: text)
        var matchedTags: [String] = []
 
        for tag in profile.tagWeights.keys {
            let cleanedTag         = cleanText(tag)
            let lemmatizedTag      = lemmatizePhrase(cleanedTag)
            let tagWords           = cleanedTag.split(separator: " ").map(String.init)
            let lemmatizedTagWords = lemmatizedTag.split(separator: " ").map(String.init)
 
            if phrases.contains(cleanedTag) || phrases.contains(lemmatizedTag) {
                matchedTags.append(tag); continue
            }
 
            var foundPartial = false
            for phrase in phrases {
                if phrase.contains(cleanedTag) || phrase.contains(lemmatizedTag) {
                    matchedTags.append(tag); foundPartial = true; break
                }
            }
            if foundPartial { continue }
 
            var tagWordScores: [Double] = []
            for (index, tagWord) in tagWords.enumerated() {
                let tagLemma  = index < lemmatizedTagWords.count ? lemmatizedTagWords[index] : tagWord
                var bestScore = 0.0
                outer: for phrase in phrases {
                    for phraseWord in phrase.split(separator: " ").map(String.init) {
                        if tagWord == phraseWord || tagLemma == phraseWord {
                            bestScore = config.exactMatchBoost; break outer
                        }
                        let sim = max(config.semanticFloor, 1.0 - embedding.distance(between: tagWord, and: phraseWord))
                        bestScore = max(bestScore, sim)
                    }
                }
                tagWordScores.append(bestScore)
            }
 
            let confidence = tagWordScores.isEmpty ? 0.0 : tagWordScores.reduce(0, +) / Double(tagWordScores.count)
            if confidence >= config.minConfidence { matchedTags.append(tag) }
        }
 
        let score = matchedTags.reduce(0.0) { $0 + (profile.tagWeights[$1] ?? 0.0) }
        return (score, matchedTags)
    }
 
    // MARK: - Level multiplier
 
    private func levelMultiplier(article: BlogArticle, level: BlogUserLevel) -> Double {
        let diff = abs(article.complexityTier - level.preferredComplexityTier)
        switch diff {
        case 0:  return level.complexityMultiplier
        case 1:  return 1.0
        default: return 0.75
        }
    }
 
    // MARK: - Freshness decay
 
    private func freshnessScore(publishedAt: Date) -> Double {
        let ageInDays = max(0, Date().timeIntervalSince(publishedAt) / 86_400)
        return pow(0.5, ageInDays / config.freshnessHalfLifeDays)
    }
 
    // MARK: - Diversity filter
 
    private func applyDiversityFilter(scored: [ScoredArticle]) -> [ScoredArticle] {
        var categoryCount: [String: Int] = [:]
        var result:   [ScoredArticle] = []
        var deferred: [ScoredArticle] = []
 
        for item in scored {
            let cat   = item.article.category
            let count = categoryCount[cat, default: 0]
            if count < config.diversityPenaltyAfter {
                categoryCount[cat] = count + 1
                result.append(item)
            } else {
                deferred.append(ScoredArticle(
                    article:         item.article,
                    baseScore:       item.baseScore,
                    levelMultiplier: item.levelMultiplier,
                    freshnessScore:  item.freshnessScore,
                    finalScore:      item.finalScore * config.diversityPenaltyFactor,
                    matchedTags:     item.matchedTags
                ))
            }
        }
        return (result + deferred).sorted { $0.finalScore > $1.finalScore }
    }
 
    // MARK: - NLP helpers
 
    private func cleanText(_ text: String) -> String {
        let stopWords = Set(["the","a","an","and","or","but","in","on","at","to","for","of","with","as","by","from","is","are","was","were","be","been","being"])
        let cleaned = text.lowercased()
            .replacingOccurrences(of: "'s", with: "")
            .replacingOccurrences(of: "[^a-z0-9\\s]", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespaces)
        return cleaned.split(separator: " ").map(String.init)
            .filter { !stopWords.contains($0) && $0.count > 1 }
            .joined(separator: " ")
    }
 
    private func lemmatize(_ word: String) -> String {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = word
        var lemma = word
        tagger.enumerateTags(in: word.startIndex..<word.endIndex, unit: .word, scheme: .lemma) { tag, _ in
            if let tag = tag { lemma = tag.rawValue }
            return true
        }
        return lemma.lowercased()
    }
 
    private func lemmatizePhrase(_ phrase: String) -> String {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = phrase
        var words: [String] = []
        tagger.enumerateTags(in: phrase.startIndex..<phrase.endIndex, unit: .word, scheme: .lemma, options: [.omitWhitespace, .omitPunctuation]) { tag, range in
            words.append(tag?.rawValue.lowercased() ?? String(phrase[range]).lowercased())
            return true
        }
        return words.joined(separator: " ")
    }
 
    private func extractPhrases(from text: String, maxPhraseLength: Int = 4) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass, .nameType, .lemma])
        tagger.string = text
        var phrases: Set<String> = []
        var nounBuffer: [String] = []
        var lemmaBuffer: [String] = []
 
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .nameType, options: [.omitWhitespace, .omitPunctuation, .joinNames]) { tag, range in
            if tag != nil { phrases.insert(String(text[range]).lowercased()) }
            return true
        }
 
        func flush() {
            guard !nounBuffer.isEmpty else { return }
            for length in 1...nounBuffer.count {
                for start in 0...(nounBuffer.count - length) {
                    phrases.insert(nounBuffer[start..<(start+length)].joined(separator: " "))
                    phrases.insert(lemmaBuffer[start..<(start+length)].joined(separator: " "))
                }
            }
            nounBuffer.removeAll(); lemmaBuffer.removeAll()
        }
 
        tagger.enumerateTags(in: text.startIndex..<text.endIndex, unit: .word, scheme: .lexicalClass, options: [.omitWhitespace, .omitPunctuation]) { tag, range in
            let word = String(text[range]).lowercased()
            let wt = NLTagger(tagSchemes: [.lemma]); wt.string = word
            var lemma = word
            wt.enumerateTags(in: word.startIndex..<word.endIndex, unit: .word, scheme: .lemma) { t, _ in
                if let t = t { lemma = t.rawValue.lowercased() }; return true
            }
            if tag == .noun || tag == .adjective || tag == .verb {
                nounBuffer.append(word); lemmaBuffer.append(lemma)
                if nounBuffer.count > maxPhraseLength { nounBuffer.removeFirst(); lemmaBuffer.removeFirst() }
            } else { flush() }
            return true
        }
        flush()
 
        for word in text.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted).filter({ $0.count > 1 }) {
            phrases.insert(word); phrases.insert(lemmatize(word))
        }
        return Array(phrases)
    }
}
 
// MARK: - Output model
 
struct ScoredArticle {
    let article: BlogArticle
    let baseScore: Double
    let levelMultiplier: Double
    let freshnessScore: Double
    let finalScore: Double
    let matchedTags: [String]
 
    func debugDescription() -> String {
        """
        [\(String(format: "%.1f", finalScore))] \(article.title.prefix(60))
          base=\(String(format: "%.1f", baseScore))  level×\(String(format: "%.2f", levelMultiplier))  fresh×\(String(format: "%.2f", freshnessScore))
          tags: \(matchedTags.joined(separator: ", "))
        """
    }
}
 
// MARK: - Usage example
 
/*
 
// 1. Build profile from onboarding answers
var profile = DynamicUserProfile(
    interests: [.indianEconomy, .bankingCredit, .stockMarkets],
    level: .intermediate
)
 
// 2. Get ranked feed
let feed = BlogRecommendationEngine.shared.recommend(
    articles: incomingArticles,
    profile: &profile,
    limit: 20
)
feed.forEach { print($0.debugDescription()) }
 
// 3. Record engagement — drives dynamic weight evolution
if let top = feed.first {
    profile.recordBookmark(article: top.article)
}
 
// 4. Mark articles seen so they don't reappear
feed.prefix(10).forEach { profile.markSeen(articleID: $0.article.id) }
 
// 5. Scheduled background task (daily / weekly)
profile.applyWeeklyDecay()
 
*/
