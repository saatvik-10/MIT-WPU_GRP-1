//
//  PuzzleEngine.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 13/05/26.
//

import Foundation

struct PuzzleEngine {
    
    struct BaseVariables {
        var revenueGrowth: Double
        var opMargin: Double
        var debtToEquity: Double
        var assetTurnover: Double
        var capexIntensity: Double
        var peMultiple: Double
    }
    
    struct GeneratedCompanyData {
        let base: BaseVariables
        let indicators: [String: Double]
        var score: Double = 0.0
    }
    
    static func generatePuzzleData(for sector: String) -> [GeneratedCompanyData] {
        var attempts = 0
        while attempts < 3 {
            let companies = (0..<4).map { _ in generateBaseVariables(for: sector) }
            var dataList = companies.map {
                GeneratedCompanyData(base: $0, indicators: deriveIndicators(from: $0))
            }
            
            // Score them
            dataList = scoreCompanies(dataList, in: sector)
            
            let sorted = dataList.sorted { $0.score > $1.score }
            if let first = sorted.first, let last = sorted.last {
                if first.score - last.score >= 0.20 {
                    return sorted
                }
            }
            attempts += 1
        }
        
        // Return whatever we have if we fail 3 times
        var fallback = (0..<4).map { _ in generateBaseVariables(for: sector) }
        var dataList = fallback.map {
            GeneratedCompanyData(base: $0, indicators: deriveIndicators(from: $0))
        }
        dataList = scoreCompanies(dataList, in: sector)
        return dataList.sorted { $0.score > $1.score }
    }
    
    private static func generateBaseVariables(for sector: String) -> BaseVariables {
        let isTech = sector == "IT/Software"
        let isFmcg = sector == "FMCG"
        let isBank = sector == "Banking/NBFC"
        let isPharma = sector == "Pharma"
        let isInfra = sector == "Infrastructure/Capital Goods"
        
        let rg = isTech ? Double.random(in: 10...25) :
                 isFmcg ? Double.random(in: 8...15) :
                 isBank ? Double.random(in: 12...20) :
                 isPharma ? Double.random(in: 8...18) :
                 Double.random(in: 5...15)
        
        let om = isTech ? Double.random(in: 18...30) :
                 isFmcg ? Double.random(in: 15...25) :
                 isBank ? Double.random(in: 10...20) :
                 isPharma ? Double.random(in: 20...35) :
                 Double.random(in: 8...14)
        
        let de = isBank ? Double.random(in: 4.0...8.0) :
                 isTech ? Double.random(in: 0.0...0.3) :
                 isInfra ? Double.random(in: 1.0...2.5) :
                 Double.random(in: 0.1...1.0)
        
        let at = isFmcg ? Double.random(in: 1.5...3.0) :
                 isTech ? Double.random(in: 0.8...1.5) :
                 isBank ? Double.random(in: 0.05...0.15) :
                 Double.random(in: 0.5...1.2)
        
        let ci = isInfra ? Double.random(in: 8...15) :
                 isTech ? Double.random(in: 1...5) :
                 isPharma ? Double.random(in: 5...10) :
                 Double.random(in: 2...8)
        
        let pe = isTech ? Double.random(in: 25...45) :
                 isFmcg ? Double.random(in: 35...55) :
                 isBank ? Double.random(in: 10...20) :
                 isPharma ? Double.random(in: 20...40) :
                 Double.random(in: 15...30)
                 
        return BaseVariables(revenueGrowth: rg, opMargin: om, debtToEquity: de, assetTurnover: at, capexIntensity: ci, peMultiple: pe)
    }
    
    private static func deriveIndicators(from base: BaseVariables) -> [String: Double] {
        let opMargin = base.opMargin
        let revGrowth = base.revenueGrowth
        let ci = base.capexIntensity
        let de = base.debtToEquity
        let pe = base.peMultiple
        let at = base.assetTurnover
        
        let npm = opMargin * 0.72 * (1 - 0.25)
        let roe = npm * at * (1 + de)
        let roce = opMargin * at
        let intCov = opMargin / max(0.1, (de * 0.08 * 0.5 * 100)) // Scaled for realism
        let ebitda = opMargin + 2.0
        let debtToEbitda = de / max(0.01, (ebitda * at / 100.0))
        let currentRatio = max(0.6, 1.8 - de * 0.3)
        let fcfToDebt = de == 0 ? 999.0 : (opMargin - ci) / 100.0 / de
        
        let epsGrowth = revGrowth * (1 + (opMargin - 15) / 100.0)
        let salesCagr = revGrowth * 0.88
        let marginLift = 1 + (opMargin - 15) / 100.0
        let profitCagr = revGrowth * 0.88 * marginLift
        let opCfGrowth = max(0, revGrowth - ci * 0.5)
        
        let pb = pe * (npm / 100.0) * at
        let evEbitda = pe * 0.65
        let ps = pe * (npm / 100.0)
        let peg = pe / max(1.0, revGrowth)
        
        return [
            "Revenue Growth YoY": revGrowth,
            "EPS Growth (YoY)": epsGrowth,
            "5Y Sales CAGR": salesCagr,
            "5Y Profit CAGR": profitCagr,
            "Operating CF Growth": opCfGrowth,
            
            "Net Profit Margin": npm,
            "Return on Equity": roe,
            "Return on Capital Employed": roce,
            "Operating Margin": opMargin,
            "Asset Turnover": at,
            
            "Debt-to-Equity": de,
            "Interest Coverage": intCov,
            "Debt-to-EBITDA": debtToEbitda,
            "Current Ratio": currentRatio,
            "FCF-to-Debt": fcfToDebt,
            
            "P/E Ratio": pe,
            "Price-to-Book": pb,
            "EV/EBITDA": evEbitda,
            "Price-to-Sales": ps,
            "PEG Ratio": peg
        ]
    }
    
    private static func scoreCompanies(_ companies: [GeneratedCompanyData], in sector: String) -> [GeneratedCompanyData] {
        var wGrowth = 0.25, wFin = 0.25, wDebt = 0.25, wVal = 0.25
        
        switch sector {
        case "IT/Software":
            wGrowth = 0.35; wFin = 0.30; wDebt = 0.10; wVal = 0.25
        case "FMCG":
            wGrowth = 0.25; wFin = 0.35; wDebt = 0.15; wVal = 0.25
        case "Banking/NBFC":
            wGrowth = 0.20; wFin = 0.25; wDebt = 0.40; wVal = 0.15
        case "Pharma":
            wGrowth = 0.30; wFin = 0.35; wDebt = 0.15; wVal = 0.20
        case "Infrastructure/Capital Goods":
            wGrowth = 0.30; wFin = 0.20; wDebt = 0.35; wVal = 0.15
        default: break
        }
        
        let allIndicators = companies.first?.indicators.keys.map { String($0) } ?? []
        let lowerIsBetter = Set(["Debt-to-Equity", "Debt-to-EBITDA", "P/E Ratio", "Price-to-Book", "EV/EBITDA", "Price-to-Sales", "PEG Ratio"])
        
        let growthSet = Set(["Revenue Growth YoY", "EPS Growth (YoY)", "5Y Sales CAGR", "5Y Profit CAGR", "Operating CF Growth"])
        let finSet = Set(["Net Profit Margin", "Return on Equity", "Return on Capital Employed", "Operating Margin", "Asset Turnover"])
        let debtSet = Set(["Debt-to-Equity", "Interest Coverage", "Debt-to-EBITDA", "Current Ratio", "FCF-to-Debt"])
        let valSet = Set(["P/E Ratio", "Price-to-Book", "EV/EBITDA", "Price-to-Sales", "PEG Ratio"])
        
        var normalizedMatrix: [[String: Double]] = companies.map { _ in [:] }
        
        for key in allIndicators {
            let values = companies.map { $0.indicators[key] ?? 0.0 }
            let minVal = values.min() ?? 0.0
            let maxVal = values.max() ?? 1.0
            let range = max(0.0001, maxVal - minVal)
            
            for (i, val) in values.enumerated() {
                var norm = (val - minVal) / range
                if lowerIsBetter.contains(key) {
                    norm = 1.0 - norm
                }
                normalizedMatrix[i][key] = norm
            }
        }
        
        var scoredCompanies = companies
        
        for i in 0..<scoredCompanies.count {
            var gScore = 0.0, fScore = 0.0, dScore = 0.0, vScore = 0.0
            for k in growthSet { gScore += normalizedMatrix[i][k] ?? 0.0 }
            for k in finSet { fScore += normalizedMatrix[i][k] ?? 0.0 }
            for k in debtSet { dScore += normalizedMatrix[i][k] ?? 0.0 }
            for k in valSet { vScore += normalizedMatrix[i][k] ?? 0.0 }
            
            gScore /= 5.0
            fScore /= 5.0
            dScore /= 5.0
            vScore /= 5.0
            
            let composite = (gScore * wGrowth) + (fScore * wFin) + (dScore * wDebt) + (vScore * wVal)
            scoredCompanies[i].score = composite
        }
        
        return scoredCompanies
    }
    
    static func formatIndicatorValue(_ name: String, value: Double) -> String {
        let percentages = Set(["Revenue Growth YoY", "EPS Growth (YoY)", "5Y Sales CAGR", "5Y Profit CAGR", "Operating CF Growth", "Net Profit Margin", "Return on Equity", "Return on Capital Employed", "Operating Margin"])
        let ratios = Set(["Asset Turnover", "Debt-to-Equity", "Interest Coverage", "Debt-to-EBITDA", "Current Ratio", "Price-to-Book", "Price-to-Sales", "PEG Ratio", "FCF-to-Debt"])
        let multiples = Set(["P/E Ratio", "EV/EBITDA"])
        
        if percentages.contains(name) {
            return String(format: "%.1f%%", value)
        } else if multiples.contains(name) {
            return String(format: "%.1f", value)
        } else if ratios.contains(name) {
            return String(format: "%.2f", value)
        } else {
            return String(format: "%.1f", value)
        }
    }
    
    static func getReturnPercent(forRank rank: Int) -> Int {
        switch rank {
        case 1: return Int.random(in: 28...42)
        case 2: return Int.random(in: 14...24)
        case 3: return Int.random(in: 5...13)
        case 4: return Int.random(in: -3...4)
        default: return 0
        }
    }
}
