import Foundation
import NaturalLanguage

// MARK: - Configuration
struct MatchConfig {
    let singleWordThreshold: Double = 0.65
    let multiWordThreshold: Double = 0.50
    let minConfidence: Double = 0.4
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

let newsHeadline = "Stock market gains as RBI balances inflation control and growth"
let newsBody = """
Indian stock market indices closed higher after the RBI struck a cautious tone
on inflation while maintaining its current interest rate framework. The central
bank emphasized the need to support economic growth without compromising price stability.

Banking stocks, including HDFC Bank, benefited from expectations of stable lending
conditions and improved credit growth. Analysts noted that consistent monetary policy
and predictable regulation are positive signals for the broader economy.
"""

// MARK: - Text Processing
func cleanText(_ text: String) -> String {
    return text
        .lowercased()
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
    var currentPhrase: [String] = []
    
    tagger.enumerateTags(
        in: text.startIndex..<text.endIndex,
        unit: .word,
        scheme: .lexicalClass,
        options: [.omitWhitespace, .omitPunctuation]
    ) { tag, range in
        
        let word = String(text[range])
        
        // Include nouns and adjectives for better phrase extraction
        if tag == .noun || tag == .adjective {
            currentPhrase.append(word)
        } else {
            if !currentPhrase.isEmpty {
                phrases.append(currentPhrase.joined(separator: " "))
                currentPhrase.removeAll()
            }
        }
        return true
    }
    
    if !currentPhrase.isEmpty {
        phrases.append(currentPhrase.joined(separator: " "))
    }
    
    return phrases
}

// MARK: - Word Stemming (removes common suffixes)
func getWordRoot(_ word: String) -> String {
    let suffixes = ["ing", "ed", "s", "es", "er", "ly"]
    var root = word
    
    for suffix in suffixes {
        if word.hasSuffix(suffix) && word.count > suffix.count + 2 {
            root = String(word.dropLast(suffix.count))
            break
        }
    }
    
    return root
}

// MARK: - Matching Engine
func matchUserTagsWithArticle(
    userTags: [String],
    headline: String,
    body: String,
    config: MatchConfig = MatchConfig()
) -> (matchedTags: [String], matchCount: Int) {
    
    guard let embedding = NLEmbedding.wordEmbedding(for: .english) else {
        print(" Failed to load word embedding")
        return ([], 0)
    }
    
    let articleText = cleanText(headline + " " + body)
    let articlePhrases = extractPhrases(from: articleText)
    
    print(" Extracted Article Phrases:")
    articlePhrases.forEach { print("  • \($0)") }
    print("")
    
    var matchedTags: [String] = []
    
    for tag in userTags {
        let cleanedTag = cleanText(tag)
        let tagWords = cleanedTag.split(separator: " ").map(String.init)
        let distanceThreshold = tagWords.count > 1 ? config.multiWordThreshold : config.singleWordThreshold
        
        var matchedWordCount = 0
        var bestDistance: Double = 2.0
        
        for phrase in articlePhrases {
            let phraseWords = phrase.split(separator: " ").map(String.init)
            
            // Check for exact phrase match
            if phrase.contains(cleanedTag) || cleanedTag.contains(phrase) {
                matchedWordCount = tagWords.count
                bestDistance = 0.0
                break
            }
            
            // Word-by-word matching
            for tagWord in tagWords {
                let tagRoot = getWordRoot(tagWord)
                
                for phraseWord in phraseWords {
                    let phraseRoot = getWordRoot(phraseWord)
                    
                    // Exact match (including root word matching)
                    if tagWord == phraseWord || tagRoot == phraseRoot {
                        matchedWordCount += 1
                        bestDistance = min(bestDistance, 0.0)
                        continue
                    }
                    
                    // Semantic similarity
                    let distance = embedding.distance(between: tagWord, and: phraseWord)
                    
                    if distance <= distanceThreshold {
                        matchedWordCount += 1
                        bestDistance = min(bestDistance, distance)
                    }
                }
            }
        }
        
        let confidence = Double(matchedWordCount) / Double(tagWords.count)
        
        if confidence >= config.minConfidence {
            matchedTags.append(tag)
        }
        
        print(" Tag: '\(tag)' → distance: \(String(format: "%.2f", bestDistance))")
    }
    
    return (matchedTags, matchedTags.count)
}

// MARK: - Run Matching
let result = matchUserTagsWithArticle(
    userTags: userTags,
    headline: newsHeadline,
    body: newsBody
)

// MARK: - Output
print("\nMatched Tags:")
result.matchedTags.forEach { print("  • \($0)") }

print("\nTotal Matches: \(result.matchCount)")





//Extracted Article Phrases:
// • hdfc
// • shares climb
// • central bank policy
// • lender
// • central bank
// • policy rates unchanged
// • sentiment
// • equity market
//
//Tag: 'banking' → distance: 0.00, confidence: 2.00
//Tag: 'stock market' → distance: 0.00, confidence: 0.50
//Tag: 'hdfc bank' → distance: 0.00, confidence: 1.00
//Tag: 'interest rate' → distance: 0.00, confidence: 0.50
//Tag: 'rbi' → distance: 2.00, confidence: 0.00
//Tag: 'technology' → distance: 2.00, confidence: 0.00
//
//Matched Tags:
// • banking
// • stock market
// • hdfc bank
// • interest rate
//
//Total Matches: 4
