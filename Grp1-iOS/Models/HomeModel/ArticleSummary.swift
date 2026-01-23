//
//  ArticleSummary.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 21/01/26.
//

import Foundation
import FoundationModels

@Generable
struct ArticleSummary: Equatable {

    @Guide(description: "A concise overview of the article in 8 to 9 sentences.")
    let overview: String

    @Guide(description: "Key takeaways from the article.")
    @Guide(.count(4...5))
    let keyTakeaways: [String]
    
    @Guide(
            description: """
            Strictly financial or economic technical terms.
            • Must be used in finance, markets, banking, economics, or policy
            • Avoid generic words, environmental terms, or common language
            • Examples: Repo Rate, Yield Curve, Fiscal Deficit, CPI Inflation
            """
        )
        @Guide(.count(3...4))
        let jargons: [String]
}

