import Foundation
import NaturalLanguage

// MARK: - Cosine Similarity
func cosineSimilarity(_ a: [Double], _ b: [Double]) -> Double {
    let dot = zip(a, b).map(*).reduce(0, +)
    let magA = sqrt(a.map { $0 * $0 }.reduce(0, +))
    let magB = sqrt(b.map { $0 * $0 }.reduce(0, +))
    return (magA > 0 && magB > 0) ? dot / (magA * magB) : 0
}

// MARK: - Article Boundary Detector
func extractCleanArticle(from text: String) -> String {
    guard let embedding = NLEmbedding.sentenceEmbedding(for: .english) else {
        print("❌ Failed to load embeddings")
        return text
    }

    let paragraphs = text
        .components(separatedBy: "\n\n")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }

    guard paragraphs.count > 3 else { return text }

    var cleaned: [String] = [paragraphs[0]]

    for i in 1..<paragraphs.count {
        guard
            let v1 = embedding.vector(for: paragraphs[i - 1]),
            let v2 = embedding.vector(for: paragraphs[i])
        else {
            cleaned.append(paragraphs[i])
            continue
        }

        let similarity = cosineSimilarity(v1, v2)

        // 🔑 Semantic continuity threshold
        if similarity < 0.15 || paragraphs[i].count < 10 {
            print("🛑 Article ended at paragraph \(i)")
            break
        }

        cleaned.append(paragraphs[i])
    }

    return cleaned.joined(separator: "\n\n")
}

// MARK: - INPUT: Full Raw Article (paste ANY scraped article here)
let rawArticleText = """
Stock market today: These are the top gainers and losers on NSE & BSE on January 22 - check list

Stock market today: These are the top gainers and losers on NSE & BSE on January 22 - check list

Indian equity benchmarks opened firmly in the green on Thursday, tracking positive global cues after US President Donald Trump rolled back tariff threats against European nations, easing fears of a fresh trade confrontation.

opened at 25,344.15, up 186.65 points or 0.74 per cent, while the

Broader markets outperformed, with the Nifty Midcap 100 rising over 1.2 per cent and the Nifty Smallcap 100 advancing 0.83 per cent. Sectorally, buying was broad-based, led by auto, IT, PSU banks and pharma stocks.

Ajay Bagga, banking and market expert, was quoted by news agency ANI as saying that apart from global relief, comments by Trump praising Prime Minister Narendra Modi and speaking of an imminent India–US trade deal acted as a key catalyst.

“Despite persistent FPI selling, the Trump detente on EU and hope for an Indian trade deal are positives driving Indian markets this morning,” he said.

The domestic currency gained 15 paise to trade at 91.50 against the US dollar after rebounding from its all-time low, helped by improved risk appetite and firm domestic equities.

On Wednesday, the rupee had closed at a record low of 91.65.

Forex traders said sentiment improved after Trump announced in Davos that he was scrapping planned tariffs on eight European nations.

However, they cautioned that the rupee remains vulnerable due to ongoing geopolitical uncertainties. Anil Kumar Bhansali of Finrex Treasury Advisors said Asian equities were up, giving some relief to the rupee after Trump avoided confrontation with Europe and spoke of a framework on Greenland, as per news agency PTI.

On the institutional front, domestic institutional investors remained net buyers, while foreign investors continued to sell, keeping markets alert to further global developments.

The TOI Business Desk is a vigilant and dedicated team of journalists committed to delivering the latest and most relevant business news from around the world to readers of The Times of India. The primary focus of the TOI Business Desk is to keep a watchful eye on the global business landscape, covering a wide spectrum of industries, markets, economic trends, in-depth analysis, exclusive reports and breaking stories that impact businesses and economies. With a mission to provide valuable insights and updates, the desk ensures that TOI readers are well-informed about the ever-changing and dynamic world of commerce and can navigate the complexities of the business world.

5 times your soul knows the truth long before your mind accepts it

From Disha Vakani’s reunion with Asit Kumar Modi to Shweta Tiwari’s transformation- when TV celebs shared rare unseen pictures

How to stay calm when someone tries to provoke you: Psychologist reveals 3 effective tips

Stock market: These are the top gainers & losers on NSE & BSE today- check list

Budget 2026 for real estate: What FM Scan do for affordable housing - wishlist

Why Rich Dad Poor Dad author thinks silver is superior to gold

Gold, silver price prediction: Will gold hit Rs 1.75 lakh/10 grams in coming sessions? Check outlook

Budget 2026 income tax expectations: What individual taxpayers are hoping for - top 4 points to know

Budget 2026 for real estate: What FM Scan do for affordable housing - wishlist

THE Subject Rankings 2026: IISc Bangalore stands alone for India in global top 100

All but two voted against Bangladesh: How ICC rejected BCB’s T20 World Cup venue shift plea, issued an ultimatum and what lies ahead

8th Pay Commission: How much will your salary, pension increase? Check for fitment factor of 2.15, 2.57 or 2.86

This place is the most isolated place on Earth, and NASA uses it as a spacecraft graveyard

Italy Says India-EU FTA Is About Trust, Talent And Technology, Not Just Tariffs For Global Growth

Russell Domingo press conference: on missed chances, learnings & Friday’s do-or-die clash | SA20

‘Putin Clear Winner’ Of Arctic Race As Trump’s Greenland Push Ignites Clash | Dominance Decoded

Dewald Brevis press conference: on match-winning knock & focus on final | SA20

At Davos, Pakistan Seeks More Funds, PM Sharif Calls For Reforms, While His FM Admit Misuse of Debt

James Vince press conference: on JSK’s comeback, confidence & challenges | SA20

Dan Lawrence press conference: on Paarl Royals’ playoff mindset & David Miller Injury | SA20

Protest Held Outside UK Parliament Demanding Labour Govt To Press Bangladesh Over Hindu Persecution

Protest Held Outside UK Parliament Demanding Labour Govt To Press Bangladesh Over Hindu Persecution

Prince Harry NEARLY Cries As He Defends Meghan & His Children In Explosive Trial

Arshdeep Singh press conference: on adapting to conditions, team roles & bowling plans | IND vs NZ 1st T20I

NATO Boss Rutte’s Huge Reveal On Emergency Greenland Huddle With Trump: ‘Denmark’s Ownership…’

Baba Vanga prediction 2026: From World war III and human-alien claims explained

‘Anupamaa’ January 21 written update: Anupama confronts Rajni over her actions as Rahi continues to blame her mother

Kabir Bedi on turning 80 in Goa: The energy here gives me a sense of centeredness

‘33’ gave it away? How Hardik Pandya’s jersey number first hinted at his romance with Mahieka Sharma

‘Border 2’: Ahan Shetty drops BTS pics with Varun Dhawan and Diljit Dosanjh - see post

Attendance alone cannot withhold exams: Delhi High Court orders DU to release law results

BMC mayoral race: Woman from general category to be chief of richest civic body

MP: SC allows Hindus, Muslims to offer prayers at Bhojshala on Basant Panchami — what was the dispute?

‘Wheel of Fortune’ Vanna White and John Donaldson married after 13 years: ‘We wanted to make it official in a private ceremony’

Copyright © 2026 Bennett, Coleman & Co. Ltd. All rights reserved. For reprint rights: Times Syndication Service
"""

// MARK: - RUN
let cleanArticle = extractCleanArticle(from: rawArticleText)

// MARK: - OUTPUT
print("\n📰 CLEANED ARTICLE:\n")
print(cleanArticle)
