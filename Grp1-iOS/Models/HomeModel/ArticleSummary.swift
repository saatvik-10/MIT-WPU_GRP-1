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

    @Guide(
        description: """
        A detailed overview of the article.
        Each item should be a long, explanatory point (2–3 sentences),
        written in full sentences, similar to professional news analysis.
        """
    )
    @Guide(.count(3...4))
    let overview: [String]

    @Guide(
        description: """
        Key takeaways from the article.
        Each takeaway should be detailed and explanatory,
        not short bullet points.
        """
    )
    @Guide(.count(3...4))
    let keyTakeaways: [String]

    @Guide(
        description: """
        Strictly financial or economic technical terms used in the article.
        Examples: Repo Rate, Monetary Policy, CPI Inflation.
        """
    )
    @Guide(.count(2...3))
    let jargons: [String]
}
