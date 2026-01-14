import Foundation
import NaturalLanguage

// MARK: - Configuration
struct MatchConfig {
    let minConfidence: Double = 0.45
    let exactMatchBoost: Double = 1.0
    let semanticFloor: Double = 0.0
}

// MARK: - Sample Data
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

let newsHeadline = "Tech Giants Report Strong Quarterly Results it is very good news"

let newsBody = """
Major technology firms posted significantly better-than-expected quarterly earnings, signaling renewed industry strength after months of global macroeconomic uncertainty.Robust demand for cloud services, AI infrastructure, and enterprise computing contributed heavily to revenue growth, exceeding analyst projections across multiple business segmentsMarket analysts believe these results may trigger increased investor confidence, potentially fueling further rallies in tech stocks that have already seen notable upward momentum.Executives across the sector emphasized continued investment in artificial intelligence, automation, and next-generation hardware as long-term drivers of sustained profitability.
"""




//Indian stock market indices closed higher after the RBI struck a cautious tone
//on inflation while maintaining its current interest rate framework. The central
//bank emphasized the need to support economic growth without compromising price stability.
//
//Banking stocks, including HDFC Bank, benefited from expectations of stable lending
//conditions and improved credit growth. Analysts noted that consistent monetary policy
//and predictable regulation are positive signals for the broader economy.

// MARK: - Text Cleaning
func cleanText(_ text: String) -> String {
    text.lowercased()
        .replacingOccurrences(
            of: "[^a-z0-9\\s]",
            with: "",
            options: .regularExpression
        )
}

// MARK: - Phrase Extraction
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

// MARK: - Simple Stemmer
func root(_ word: String) -> String {
    let suffixes = ["ing", "ed", "s", "es", "ly"]
    for suffix in suffixes {
        if word.hasSuffix(suffix) && word.count > suffix.count + 2 {
            return String(word.dropLast(suffix.count))
        }
    }
    return word
}


// MARK: - Matching Engine
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

                // Exact phrase shortcut
                if phrase.contains(tagWord) {
                    bestScore = config.exactMatchBoost
                    break
                }

                for phraseWord in phraseWords {
                    let phraseRoot = root(phraseWord)

                    // Root or exact match
                    if tagWord == phraseWord || tagRoot == phraseRoot {
                        bestScore = config.exactMatchBoost
                        break
                    }

                    // Semantic similarity
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

// MARK: - Run
let result = matchUserTagsWithArticle(
    userTags: userTags,
    headline: newsHeadline,
    body: newsBody
)

// MARK: - Output
print("\nMatched Tags:")
result.matchedTags.forEach { print(" • \($0)") }

print("\nTotal Matches: \(result.matchCount)")
