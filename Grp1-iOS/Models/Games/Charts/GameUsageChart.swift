//
//  GameUsageChart.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 04/02/26.
//

import SwiftUI
import Charts

struct GameUsage: Identifiable {
    let id = UUID()
    let label: String
    let plays: Int
}

struct GameUsageChart: View {

    let data: [GameUsage]

    var body: some View {
        Chart(data) {
            BarMark(
                x: .value("Period", $0.label),
                y: .value("Plays", $0.plays)
            )
            .cornerRadius(6)
            .foregroundStyle(
                LinearGradient(
                    colors: [.blue, .teal],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .padding()
    }
}
