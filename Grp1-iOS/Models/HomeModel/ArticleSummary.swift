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

    @Guide(description: "A concise overview of the article in 3 to 4 sentences.")
    let overview: String

    @Guide(description: "Key takeaways from the article.")
    @Guide(.count(4...5))
    let keyTakeaways: [String]
}

