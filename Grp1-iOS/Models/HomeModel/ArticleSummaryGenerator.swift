//
//  ArticleSummaryGenerator.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 21/01/26.
//

import Foundation
import FoundationModels
import Observation

@Observable
@MainActor
final class ArticleSummaryGenerator {

    private let session: LanguageModelSession

    private(set) var summary: ArticleSummary.PartiallyGenerated?
    private(set) var error: Error?

    init() {
        let instructions = Instructions {
            "You are a financial news analyst."
            "Summarize the article accurately."
            "Avoid speculation or opinions."
            "Use clear, simple language."
        }

        self.session = LanguageModelSession(
            instructions: instructions
        )
    }

    func generateSummary(from articleText: String) async {

        do {
            let prompt = Prompt {
                "Summarize the following news article."
                articleText
            }

            let stream = session.streamResponse(
                to: prompt,
                generating: ArticleSummary.self,
                includeSchemaInPrompt: true
            )

            for try await partial in stream {
                self.summary = partial.content
            }

        } catch {
            self.error = error
        }
    }

    func prewarmModel() {
        session.prewarm()
    }
}
