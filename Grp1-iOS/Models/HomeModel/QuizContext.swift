//
//  QuizContext.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 13/01/26.
//

final class QuizContext {
    static let shared = QuizContext()
    private init() {}

    var selectedArticleId: Int?
}
