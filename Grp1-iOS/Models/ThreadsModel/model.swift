//
//  model.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 28/11/25.
//

import Foundation

class ThreadsDataStore {
    
    static let shared = ThreadsDataStore()
    private init() {}
    
    private var threadPosts: [ThreadPost] = [
        
        ThreadPost(
            id: 1,
            userName: "Rishabh Kothari",
            userProfileImage: "beach_1",
            timeAgo: "15hrs ago",
            title: "Where is economy heading?",
            tags: ["Crypto", "JP Morgan"],
            imageName: "beach_1",
            description: """
JP Morgan Chase has told staff moving into its new headquarters in New York that they must share their biometric data to access the multibillion-dollar building...
""",
            likes: 702,
            comments: 41,
            shares: 11
        ),
        
        ThreadPost(
            id: 2,
            userName: "Ishan Magarde",
            userProfileImage: "beach_2",
            timeAgo: "15hrs ago",
            title: "Is stock market rally sustainable?",
            tags: ["Markets", "Nifty"],
            imageName: "beach_2",
            description: """
Nifty and Sensex continue to touch new highs but analysts warn that valuation may become stretched...
""",
            likes: 518,
            comments: 29,
            shares: 6
        )
    ]
    
    /// Fetch all thread posts
    func getAllThreads() -> [ThreadPost] {
        return threadPosts
    }
    
    /// Fetch current user’s threads (e.g. My Threads tab)
    func getThreads(forUser userName: String) -> [ThreadPost] {
        return threadPosts.filter { $0.userName == userName }
    }
    
    /// Add new thread
    func addNewThread(_ thread: ThreadPost) {
        threadPosts.insert(thread, at: 0) // newest at top
    }
}
