import Foundation

struct CalculatorScenario: Codable {
    let id: String
    let type: String
    let meta: ScenarioMeta // Reusing ScenarioMeta from Model1
    let part1: CalculatorPart1
    let part2: CalculatorPart2
    let part3: CalculatorPart3
}

struct CalculatorPart1: Codable {
    let title: String
    let facts: [String]
    let allocationQuestion: String
    let buckets: [AllocationBucket]
}

struct AllocationBucket: Codable {
    let id: String
    let name: String
}

struct CalculatorPart2: Codable {
    let title: String
    let question: String
    let scenarios: [StartupScenario]
}

struct StartupScenario: Codable {
    let id: String
    let emoji: String
    let name: String
    let details: [String]
}

struct CalculatorPart3: Codable {
    let title: String
    let question: String
    let options: [NegotiationOption]
}

struct NegotiationOption: Codable {
    let id: String
    let text: String
    let response: String
}
