//
//  DailyPuzzleLoader.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 05/02/26.
//

import Foundation

final class DailyPuzzleLoader {

    static func loadDailyPuzzle() -> DailyPuzzle {
        guard
            let url = Bundle.main.url(forResource: "daily_puzzle", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let puzzle = try? JSONDecoder().decode(DailyPuzzle.self, from: data)
        else {
            fatalError("❌ Failed to load daily_puzzle.json")
        }

        return puzzle
    }
}
