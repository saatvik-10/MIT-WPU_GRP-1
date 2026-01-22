import Foundation
import NaturalLanguage

struct MatchConfig {
    let minConfidence: Double = 0.45
    let exactMatchBoost: Double = 1.0
    let semanticFloor: Double = 0.0
}

let userTags = [
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

let tagWeights: [String: Double] = [
    "banking": 10,
    "stock market": 13,
    "hdfc bank": 8,
    "interest rate": 20,
    "rbi": 18,
    "technology": 7,
    "digital banking": 6,
    "fintech": 3,
    "inflation": 11,
    "economy": 4,
    "credit growth": 6,
    "regulation": 8,
    "monetary policy": 13,
    "financial sector": 9
]

let newsHeadline = "Retail inflation remains muted at 1.3% in December"

let newsBody = """
NEW DELHI: India’s benchmark inflation rate stayed on the lower side of RBI’s target band of 4% plus or minus 2% for the fourth consecutive month in December 2025. The 1.3% retail inflation value, as measured by the annual growth in Consumer Price Index (CPI), is mostly a result of easing but persisting deflation in food prices, which is more than compensating for inflationary tailwinds from sources such as precious metals.
The latest inflation reading also means that quarterly inflation in the period ending December 2025, was 0.76%, the lowest ever in the current series and the second consecutive quarter when it stayed below the lower end of RBI’s target band. To be sure, the December quarter inflation print is slightly higher than the 0.6% projected by RBI in its December Monetary Policy Committee (MPC) resolution. Headline inflation has stayed below RBI’s actual target of 4%  for four consecutive quarters now.
"""

func cleanText(_ text: String) -> String {
    text.lowercased()
        .replacingOccurrences(
            of: "[^a-z0-9\\s]",
            with: "",
            options: .regularExpression
        )
}

func extractPhrases(from text: String) -> [String] {
    let tagger = NLTagger(tagSchemes: [.lexicalClass])
    tagger.string = text

    var phrases: [String] = []
    var buffer: [String] = []

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

    if !buffer.isEmpty {
        phrases.append(buffer.joined(separator: " "))
    }

    return phrases
}

func root(_ word: String) -> String {
    let suffixes = ["ing", "ed", "s", "es", "ly"]
    for suffix in suffixes {
        if word.hasSuffix(suffix) && word.count > suffix.count + 2 {
            return String(word.dropLast(suffix.count))
        }
    }
    return word
}

func matchUserTagsWithArticle(
    userTags: [String],
    headline: String,
    body: String,
    config: MatchConfig = MatchConfig()
) -> (matchedTags: [String], matchCount: Int) {

    guard let embedding = NLEmbedding.wordEmbedding(for: .english) else {
        print("❌ Failed to load embeddings")
        return ([], 0)
    }

    let articleText = cleanText(headline + " " + body)
    let phrases = extractPhrases(from: articleText)

    print("\nExtracted Article Phrases:")
    phrases.forEach { print(" • \($0)") }
    print("")

    var matchedTags: [String] = []

    for tag in userTags {
        let cleanedTag = cleanText(tag)
        let tagWords = cleanedTag.split(separator: " ").map(String.init)

        var tagWordScores: [Double] = []

        for tagWord in tagWords {
            let tagRoot = root(tagWord)
            var bestScore = 0.0

            for phrase in phrases {
                let phraseWords = phrase.split(separator: " ").map(String.init)

                if phrase.contains(tagWord) {
                    bestScore = config.exactMatchBoost
                    break
                }

                for phraseWord in phraseWords {
                    let phraseRoot = root(phraseWord)

                    if tagWord == phraseWord || tagRoot == phraseRoot {
                        bestScore = config.exactMatchBoost
                        break
                    }

                    let distance = embedding.distance(
                        between: tagWord,
                        and: phraseWord
                    )

                    let similarity = max(config.semanticFloor, 1.0 - distance)
                    bestScore = max(bestScore, similarity)
                }
                if bestScore == 1.0 { break }
            }

            tagWordScores.append(bestScore)
        }

        let confidence =
            tagWordScores.reduce(0, +) / Double(tagWordScores.count)

        let bestDistance =
            tagWordScores.isEmpty ? 2.0 : (1.0 - tagWordScores.max()!)

        print(
            "Tag: '\(tag)' → distance: \(String(format: "%.2f", bestDistance)) " +
            "Confidence: \(String(format: "%.2f", confidence))"
        )

        if confidence >= config.minConfidence {
            matchedTags.append(tag)
        }
    }

    return (matchedTags, matchedTags.count)
}

func calculateArticleScore(
    matchedTags: [String],
    tagWeights: [String: Double]
) -> Double {

    matchedTags.reduce(0.0) { score, tag in
        score + (tagWeights[tag] ?? 0.0)
    }
}

let result = matchUserTagsWithArticle(
    userTags: userTags,
    headline: newsHeadline,
    body: newsBody
)

print("\nMatched Tags:")
result.matchedTags.forEach { print(" • \($0)") }

print("\nTotal Matches: \(result.matchCount)")

let articleScore = calculateArticleScore(
    matchedTags: result.matchedTags,
    tagWeights: tagWeights
)

print("\nArticle Score:", articleScore)
