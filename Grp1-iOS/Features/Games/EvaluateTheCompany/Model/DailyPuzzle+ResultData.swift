//
//  DailyPuzzle+ResultData.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 27/02/26.
//

import Foundation

// MARK: - Data shapes the Result screen consumes

struct ResultScreenData {
    let isCorrect: Bool

    // Your pick
    let selectedCompany: Company
    let selectedRank: Int          // 1-based, among all companies

    // Twist indicator
    let twistIndicatorName: String
    let twistDefinition: String
    let twistFormula: String

    // Correlated indicators (only the linked ones — same Pillar as twist)
    let correlatedIndicators: [String]   // indicator names

    // Best company
    let bestCompany: Company
    let bestResult: Result
    let bestReasons: [String]

    // Full ranking (sorted best → worst by returnPercent)
    let rankedResults: [RankedEntry]
}

struct RankedEntry {
    let rank: Int
    let company: Company
    let result: Result
    let twistValue: String          // displayValue from twistIndicators
    let isUserPick: Bool
    let isBest: Bool
}

// MARK: - Extension

extension DailyPuzzle {

    func buildResultScreenData(selectedCompanyId: String) -> ResultScreenData? {

        // 1. Best company by returnPercent
        guard
            let bestResult  = results.max(by: { $0.returnPercent < $1.returnPercent }),
            let bestCompany = companies.first(where: { $0.id == bestResult.companyId }),
            let selectedCompany = companies.first(where: { $0.id == selectedCompanyId })
        else { return nil }

        let isCorrect = selectedCompanyId == bestResult.companyId

        // 2. Twist indicator name (first twistIndicator's name — same name for all companies)
        let twistName = twistIndicators.first?.indicatorName ?? "Twist Indicator"
        let twistPillar = twistIndicators.first?.pillar ?? .growthConsistency

        // 3. Correlated indicators = visibleIndicators that share the same Pillar as the twist
        let correlatedNames: [String] = Array(
            Set(
                visibleIndicators
                    .filter { $0.pillar == twistPillar }
                    .map { $0.indicatorName }
            )
        ).sorted()

        // 4. Full ranking sorted by returnPercent descending
        let sortedResults = results.sorted { $0.returnPercent > $1.returnPercent }
        let rankedEntries: [RankedEntry] = sortedResults.enumerated().compactMap { idx, res in
            guard let company = companies.first(where: { $0.id == res.companyId }) else { return nil }
            let twistVal = twistIndicators.first(where: { $0.companyId == res.companyId })?.displayValue ?? "-"
            return RankedEntry(
                rank: idx + 1,
                company: company,
                result: res,
                twistValue: twistVal,
                isUserPick: res.companyId == selectedCompanyId,
                isBest: res.companyId == bestResult.companyId
            )
        }

        // 5. Selected company rank
        let selectedRank = rankedEntries.first(where: { $0.company.id == selectedCompanyId })?.rank ?? rankedEntries.count

        // 6. Definition & formula (keyed by indicatorName — extend this dict as you add more twist indicators)
        let definitions: [String: (definition: String, formula: String)] = [
            "5Y Sales CAGR": (
                definition: "Compound Annual Growth Rate over 5 years smooths out yearly noise to show the real growth trajectory of a company. A high CAGR means growth is sustained — not a one-year spike.",
                formula: "CAGR = ( End Value ÷ Start Value ) ^ (1 ÷ 5) − 1"
            ),
            "EPS Growth (YoY)": (
                definition: "Earnings Per Share growth year-over-year measures how fast a company's profit per share is growing. It directly reflects shareholder value creation.",
                formula: "EPS Growth = ( EPS This Year − EPS Last Year ) ÷ EPS Last Year × 100"
            ),
            "Net Profit Margin": (
                definition: "Net Profit Margin shows how much of every rupee of revenue becomes actual profit. Higher margins signal pricing power and cost efficiency.",
                formula: "Net Profit Margin = Net Profit ÷ Revenue × 100"
            )
        ]

        let def = definitions[twistName] ?? (
            definition: "\(twistName) is a key financial metric that reveals the underlying quality of a company's performance beyond surface-level numbers.",
            formula: "Refer to the financial glossary for the exact formula."
        )

        // 7. Best company reasons (driven by data)
        let bestTwistVal = twistIndicators.first(where: { $0.companyId == bestResult.companyId })?.displayValue ?? "-"
        let reasons: [String] = [
            "Highest return of \(bestResult.returnPercent)% among all companies in this sector.",
            "\(twistName) of \(bestTwistVal) — the twist indicator confirmed sustained performance, not a one-off.",
            bestResult.explanation,
            "Outperformed peers consistently across both visible and twist indicators."
        ]

        return ResultScreenData(
            isCorrect: isCorrect,
            selectedCompany: selectedCompany,
            selectedRank: selectedRank,
            twistIndicatorName: twistName,
            twistDefinition: def.definition,
            twistFormula: def.formula,
            correlatedIndicators: correlatedNames,
            bestCompany: bestCompany,
            bestResult: bestResult,
            bestReasons: reasons,
            rankedResults: rankedEntries
        )
    }
}
