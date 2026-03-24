//
//  result.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 05/02/26.
//

import Foundation
struct Result: Codable {
    let companyId: String
    let returnPercent: Int
    let explanation: String
}

//struct CompanyScore {
//    let companyId: String
//    let totalScore: Double
//    let breakdown: [Pillar: Double]   // pillar -> score
//}
