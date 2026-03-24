import Foundation

struct DecodeAndRankScenario: Codable {
    let id: String
    let type: String
    let meta: ScenarioMeta
    let visualContext: VisualContext
    let step1: DecodeStep
    let step2: RankStep
}

struct ScenarioMeta: Codable {
    let title: String
    let description: String
}

struct VisualContext: Codable {
    let leftSide: VisualSide
    let rightSide: VisualSide
}

struct VisualSide: Codable {
    let title: String
    let visualStyle: String // Handle "faded", "crisp", etc., in your UI layer
}

struct DecodeStep: Codable {
    let instruction: String
    let decodableItems: [DecodableItem]
}

struct DecodableItem: Codable {
    let id: String
    let initialText: String
    let revealedText: String
}

struct RankStep: Codable {
    let question: String
    let instruction: String
    let rankingOptions: [RankingOption]
}

struct RankingOption: Codable {
    let id: String
    let text: String
}
