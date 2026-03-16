import Foundation
import FoundationModels

@Generable
struct ShortHeadline {
    @Guide(description: "A concise headline under 90 characters")
    let text: String
}

final class HeadlineShortener {

    func shortenIfNeeded(_ title: String) async -> String {

        guard title.count > 40 else {
            return title
        }

        let instructions = Instructions {
            "You are a financial news editor."
            "Rewrite headlines to be concise and professional."
            "Do not add information."
            "Do not speculate."
            "Maximum 90 characters."
            "Return ONLY the headline text."
        }

        let session = LanguageModelSession(instructions: instructions)

        let prompt = Prompt {
            "Shorten the following financial news headline to under 90 characters."
            title
        }
        do {
            var finalText = ""
            let stream = session.streamResponse(
                to: prompt,
                generating: ShortHeadline.self,
                includeSchemaInPrompt: true
            )
            for try await partial in stream {
                if let text = partial.content.text {
                    finalText = text
                }
            }
            let cleaned = finalText.trimmingCharacters(in: .whitespacesAndNewlines)
            return cleaned.isEmpty ? String(title.prefix(90)) : cleaned
        } catch {
            print("Headline shortening failed:", error)
            return String(title.prefix(90))
        }
    }
}
