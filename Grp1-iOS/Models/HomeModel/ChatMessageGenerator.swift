//
//  ChatMessageGenerator.swift
//  Grp1-iOS
//

import Foundation
import FoundationModels
import Observation

@Observable
@MainActor
final class ChatMessageGenerator {

    private let session: LanguageModelSession

    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    init(overview: [String] = [], keyTakeaways: [String] = []) {
        let overviewText  = overview.joined(separator: " ")
        let takeawaysText = keyTakeaways.enumerated()
                              .map { "\($0.offset + 1). \($0.element)" }
                              .joined(separator: "\n")

        let instructions = Instructions {
            "You are a helpful financial learning assistant."
            "Answer user questions clearly and concisely about finance, economics, banking, and markets."
            "Use simple language when explaining complex concepts."
            "Keep answers focused and under 4 sentences unless more detail is needed."
            "Do not use bullet points — respond in plain conversational text."

            if !overviewText.isEmpty {
                "The user is reading an article with the following overview:"
                overviewText
            }

            if !takeawaysText.isEmpty {
                "Key takeaways from the article:"
                takeawaysText
            }

            "Use the above article context as your primary reference when answering."
        }

        self.session = LanguageModelSession(instructions: instructions)
    }

    func sendMessage(_ userText: String) async -> String {
        isLoading = true
        error = nil

        do {
            let prompt = Prompt { userText }
            let response = try await session.respond(to: prompt)
            isLoading = false
            return response.content

        } catch {
            self.error = error
            self.isLoading = false
            return "Sorry, I couldn't get a response. Please try again."
        }
    }

    func prewarmModel() {
        session.prewarm()
    }
}
