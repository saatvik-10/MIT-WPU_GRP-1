import Foundation
import FoundationModels

@MainActor
final class HeadlineShortener {

    private let session: LanguageModelSession

    init() {
        let instructions = Instructions {
            "You are a financial news editor."
            "Rewrite headlines to be concise and professional."
            "Do not add information."
            "Do not speculate."
            "Maximum 90 characters."
            "Return ONLY the headline text."
        }

        self.session = LanguageModelSession(instructions: instructions)
    }

    func shortenIfNeeded(_ title: String) async -> String {

        guard title.count > 40 else {
            return title
        }

        let prompt = Prompt {
            "Shorten the following financial news headline to under 90 characters."
            title
        }

        do {
            var finalText = ""

            let stream = session.streamResponse(
                to: prompt,
                generating: String.self,
                includeSchemaInPrompt: false
            )

            for try await partial in stream {
                finalText = partial.content
            }

            let cleaned = finalText.trimmingCharacters(
                in: CharacterSet.whitespacesAndNewlines
            )

            return cleaned.isEmpty
                ? String(title.prefix(90))
                : cleaned

        } catch {
            print("Headline shortening failed:", error)
            return String(title.prefix(90))
        }
    }
}
