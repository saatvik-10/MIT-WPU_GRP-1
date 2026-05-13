//
//  DailyPuzzle+ResultData.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 27/02/26.
//

import Foundation
import UIKit

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
    let bestResult: Result1
    let bestReasons: [String]

    // Full ranking (sorted best → worst by returnPercent)
    let rankedResults: [RankedEntry]
}

struct RankedEntry {
    let rank: Int
    let company: Company
    let result: Result1
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

        let definitions = DailyPuzzle.getAllIndicatorDefinitions()

        let def = definitions[twistName] ?? (
            definition: "\(twistName) is a key financial metric that reveals the underlying quality of a company's performance beyond surface-level numbers.",
            formula: "Refer to the financial glossary for the exact formula.",
            icon: "chart.bar",
            iconBg: .systemGray5
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

    static func getAllIndicatorDefinitions() -> [String: (definition: String, formula: String, icon: String, iconBg: UIColor)] {
        let greenBg = UIColor(red: 0.91, green: 0.96, blue: 0.87, alpha: 1)
        let blueBg = UIColor(red: 0.90, green: 0.95, blue: 0.98, alpha: 1)
        let orangeBg = UIColor(red: 0.98, green: 0.93, blue: 0.85, alpha: 1)
        let pinkBg = UIColor(red: 0.98, green: 0.91, blue: 0.94, alpha: 1)
        
        return [
            // Growth
            "Revenue Growth YoY": (
                definition: "Measures the year-over-year percentage increase in total sales.",
                formula: "Revenue Growth = (Revenue This Year - Revenue Last Year) / Revenue Last Year",
                icon: "chart.line.uptrend.xyaxis", iconBg: blueBg
            ),
            "EPS Growth (YoY)": (
                definition: "Earnings Per Share growth year-over-year measures how fast a company's profit per share is growing.",
                formula: "EPS Growth = ( EPS This Year − EPS Last Year ) ÷ EPS Last Year × 100",
                icon: "arrow.up.right.circle", iconBg: blueBg
            ),
            "5Y Sales CAGR": (
                definition: "Compound Annual Growth Rate over 5 years smooths out yearly noise to show the real growth trajectory of a company.",
                formula: "CAGR = ( End Value ÷ Start Value ) ^ (1 ÷ 5) − 1",
                icon: "chart.line.uptrend.xyaxis", iconBg: blueBg
            ),
            "5Y Profit CAGR": (
                definition: "Compound Annual Growth Rate of profit over 5 years. Shows long term profitability trend.",
                formula: "CAGR = ( End Profit ÷ Start Profit ) ^ (1 ÷ 5) − 1",
                icon: "chart.line.uptrend.xyaxis", iconBg: blueBg
            ),
            "Operating CF Growth": (
                definition: "Growth in cash generated from normal business operations.",
                formula: "OCF Growth = (OCF This Year - OCF Last Year) / OCF Last Year",
                icon: "dollarsign.circle", iconBg: blueBg
            ),
            
            // Financial Strength
            "Net Profit Margin": (
                definition: "How much profit a company keeps from every ₹100 of revenue. Higher is generally better.",
                formula: "Net Profit Margin = Net Profit ÷ Revenue × 100",
                icon: "percent", iconBg: greenBg
            ),
            "Return on Equity": (
                definition: "Measures how effectively management is using a company’s assets to create profits.",
                formula: "ROE = Net Income / Shareholders' Equity",
                icon: "arrow.uturn.up", iconBg: greenBg
            ),
            "Return on Capital Employed": (
                definition: "Measures a company's profitability and the efficiency with which its capital is used.",
                formula: "ROCE = EBIT / Capital Employed",
                icon: "arrow.uturn.up", iconBg: greenBg
            ),
            "Operating Margin": (
                definition: "Measures how much profit a company makes on a dollar of sales after paying for variable costs.",
                formula: "Operating Margin = Operating Income / Revenue",
                icon: "percent", iconBg: greenBg
            ),
            "Asset Turnover": (
                definition: "Measures the value of a company's sales or revenues relative to the value of its assets.",
                formula: "Asset Turnover = Total Sales / Average Assets",
                icon: "arrow.triangle.2.circlepath", iconBg: greenBg
            ),
            
            // Debt Levels
            "Debt-to-Equity": (
                definition: "How much the company relies on debt vs its own funds. A lower ratio means less financial risk.",
                formula: "Debt-to-Equity = Total Debt / Total Equity",
                icon: "scalemass", iconBg: orangeBg
            ),
            "Interest Coverage": (
                definition: "Measures how easily a company can pay interest on its outstanding debt.",
                formula: "Interest Coverage = EBIT / Interest Expense",
                icon: "shield", iconBg: orangeBg
            ),
            "Debt-to-EBITDA": (
                definition: "Measures a company's ability to pay off its incurred debt.",
                formula: "Debt-to-EBITDA = Total Debt / EBITDA",
                icon: "banknote", iconBg: orangeBg
            ),
            "Current Ratio": (
                definition: "Measures a company's ability to pay short-term obligations or those due within one year.",
                formula: "Current Ratio = Current Assets / Current Liabilities",
                icon: "clock.arrow.circlepath", iconBg: orangeBg
            ),
            "FCF-to-Debt": (
                definition: "Measures how much free cash flow is available to cover debt.",
                formula: "FCF-to-Debt = Free Cash Flow / Total Debt",
                icon: "banknote.fill", iconBg: orangeBg
            ),
            
            // Valuation
            "P/E Ratio": (
                definition: "Price investors pay for every ₹1 of earnings. High P/E can mean growth expectations are already priced in.",
                formula: "P/E Ratio = Share Price / Earnings Per Share",
                icon: "tag", iconBg: pinkBg
            ),
            "Price-to-Book": (
                definition: "Compares a company's market value to its book value.",
                formula: "P/B Ratio = Market Price per Share / Book Value per Share",
                icon: "book.closed", iconBg: pinkBg
            ),
            "EV/EBITDA": (
                definition: "Compares a company's Enterprise Value to its Earnings Before Interest, Taxes, Depreciation, and Amortization.",
                formula: "EV/EBITDA = Enterprise Value / EBITDA",
                icon: "building.columns", iconBg: pinkBg
            ),
            "Price-to-Sales": (
                definition: "Compares a company's stock price to its revenues.",
                formula: "P/S Ratio = Market Capitalization / Total Sales",
                icon: "cart", iconBg: pinkBg
            ),
            "PEG Ratio": (
                definition: "A stock's price-to-earnings ratio divided by the growth rate of its earnings.",
                formula: "PEG Ratio = (P/E Ratio) / Earnings Growth Rate",
                icon: "chart.bar.xaxis", iconBg: pinkBg
            )
        ]
    }
}
