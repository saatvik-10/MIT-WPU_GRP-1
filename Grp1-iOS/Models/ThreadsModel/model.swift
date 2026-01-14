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
            userProfileImage: "person.fill",
            timeAgo: "15hrs ago",
            title: "Where is economy heading?",
            tags: ["Crypto", "JP Morgan"],
            imageName: "img(f1",
            description: """
JP Morgan Chase has told staff moving into its new headquarters in New York that they must share 
""",
            likes: 702,
            comments: 41,
            shares: 11,
            isLiked: false
        ),
        
        ThreadPost(
            id: 2,
            userName: "Ishan Magarde",
            userProfileImage: "person.fill",
            timeAgo: "19hrs ago",
            title: "Is stock market rally sustainable?",
            tags: ["Markets", "Nifty"],
            imageName: "img(F5)",
            description: """
Nifty and Sensex continue to touch new highs but analysts warn that valuation may become stretched...
""",
            likes: 518,
            comments: 29,
            shares: 6,
            isLiked: false
        )
    ]
    
    /// Fetch all thread posts
    func getAllThreads() -> [ThreadPost] {
        return threadPosts
    }
    
    // Fetch Following threads
    func getFollowingThreads() -> [ThreadPost]{
        let follwedUsers = ["Ishan Magarde"]
        return threadPosts.filter { follwedUsers.contains($0.userName)}
    }
    /// Fetch current user’s threads (e.g. My Threads tab)
    func getThreads(forUser userName: String) -> [ThreadPost] {
        return threadPosts.filter { $0.userName == userName }
    }
    
    /// Add new thread
    func addNewThread(_ thread: ThreadPost) {
        threadPosts.insert(thread, at: 0) // newest at top
    }
    
    //FOR LIKE N UNLIKE
    func toggleLike(for threadID: Int) {
            guard let index = threadPosts.firstIndex(where: { $0.id == threadID }) else { return }

            threadPosts[index].isLiked.toggle()

            if threadPosts[index].isLiked {
                threadPosts[index].likes += 1
            } else {
                threadPosts[index].likes -= 1
            }
        }
}

