//
//  comments.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 11/02/26.
//

import Foundation

struct Comment {
    let id: UUID
    let userName: String
    let userProfileImage: String
    var text: String
    var likes: Int
    var isLiked: Bool
    var replies: [Reply]
}

struct Reply {
    let id: UUID
    let userName: String
    let userProfileImage: String
    var text: String
    var likes: Int
    var isLiked: Bool
}
