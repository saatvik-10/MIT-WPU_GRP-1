//
//  indicator.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 05/02/26.
//

import Foundation

enum Pillar: String, Codable {
    case financialStrength
    case growthConsistency
    case debtLevels
    case valuation
}

struct IndicatorValue: Codable {
    let indicatorName: String
    let pillar: Pillar
    let companyId: String
    let displayValue: String
}
