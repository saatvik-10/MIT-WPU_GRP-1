import Foundation

struct ClassroomScenario: Codable {
    let id: String
    let type: String
    let meta: ScenarioMeta  // Reusing from previous screen
    let envelopes: [Envelope]
    let finalAssessment: FinalAssessment
}

struct Envelope: Codable {
    let id: String
    let title: String
    let revealedTexts: [String]
    let reactionOptions: [String]
}

struct FinalAssessment: Codable {
    let slider: SliderQuestion
    let multipleChoice: MultipleChoiceQuestion
}

struct SliderQuestion: Codable {
    let question: String
    let minLabel: String
    let maxLabel: String
}

struct MultipleChoiceQuestion: Codable {
    let question: String
    let options: [RankingOption] // Reusing RankingOption from previous screen
}
