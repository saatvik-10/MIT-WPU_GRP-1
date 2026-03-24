import Foundation
import FoundationModels
import Observation

@Generable
struct GeneratedQuiz {
    @Generable
    struct Question {
        let question: String
        let options: [String]
        let correctIndex: Int
    }
    let questions: [Question]
}

@Observable
@MainActor
final class QuizGenerator {

    private let session: LanguageModelSession
    private(set) var result: GeneratedQuiz?
    private(set) var error: Error?
    private(set) var isLoading = false

    init() {
        let instructions = Instructions {
            "You are a financial news quiz creator."
            "Generate exactly 4 multiple choice questions based on the article provided."
            "Each question must have exactly 4 options. Options should be very short in length."
            "correctIndex is 0-based index of the correct option."
            "Questions must be factual and based only on the article content."
        }
        self.session = LanguageModelSession(instructions: instructions)
    }

    func generateQuiz(from articleText: String) async {
        isLoading = true
        error = nil
        result = nil

        do {
            let prompt = Prompt {
                "Generate 4 quiz questions from this financial news article:"
                articleText
            }

            let response = try await session.respond(
                to: prompt,
                generating: GeneratedQuiz.self
            )
            self.result = response.content
        } catch {
            self.error = error
        }

        isLoading = false
    }
}
