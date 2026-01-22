//
//  model.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 28/11/25.
//

import Foundation

class ThreadsDataStore {
   
    private var followedUsers: Set<String> = [
        "Ishan Magarde"
    ]
    static let shared = ThreadsDataStore()
    private init() {}
    
    let currentUserName = "Anandita Babar"
    
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
JP Morgan Chase has told staff moving into its new headquarters in New York that they must share Inside your cell, find the label that shows description
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
Nifty and Sensex continue to touch new highs but analysts warn that valuation may become stretched
""",
            likes: 518,
            comments: 29,
            shares: 6,
            isLiked: false
        ),
        
        ThreadPost(
                   id: 3,
                   userName: "Tanmay Verma",
                   userProfileImage: "person.fill",
                   timeAgo: "1d ago",
                   title: "AI is eating software",
                   tags: ["AI", "Startups"],
                   imageName: "beach_7",
                   description: "Every company will eventually become an AI company",
                   likes: 332,
                   comments: 18,
                   shares: 4,
                   isLiked: false
               ),
       
        //
                ThreadPost(
                    id: 4,
                    userName: "Mitali Shah",
                    userProfileImage: "person.fill",
                    timeAgo: "3h ago",
                    title: "Design systems matter",
                    tags: ["UI", "UX"],
                    imageName: "beach_13",
                    description: "A good design system saves engineering time",
                    likes: 190,
                    comments: 12,
                    shares: 2,
                    isLiked: false
                ),

                ThreadPost(
                    id: 5,
                    userName: "Aditya Mehra",
                    userProfileImage: "person.fill",
                    timeAgo: "8h ago",
                    title: "iOS dev mistakes",
                    tags: ["Swift", "iOS"],
                    imageName: "beach_8",
                    description: "Things I wish I knew as a junior iOS dev",
                    likes: 411,
                    comments: 27,
                    shares: 9,
                    isLiked: false
                ),

                //
                ThreadPost(
                    id: 6,
                    userName: "Anandita Babar",
                    userProfileImage: "beach_1",
                    timeAgo: "2d ago",
                    title: "Building Threads UI",
                    tags: ["iOS", "UIKit"],
                    imageName: "beach_9",
                    description: "Lessons learnt while building Threads clone",
                    likes: 120,
                    comments: 14,
                    shares: 3,
                    isLiked: false
                ),

                ThreadPost(
                    id: 7,
                    userName: "Anandita Babar",
                    userProfileImage: "beach_1",
                    timeAgo: "3d ago",
                    title: "AutoLayout truths",
                    tags: ["AutoLayout"],
                    imageName: "urban_2",
                    description: "Why constraints break at 2am",
                    likes: 98,
                    comments: 9,
                    shares: 1,
                    isLiked: false
                ),

                ThreadPost(
                    id: 8,
                    userName: "Anandita Babar",
                    userProfileImage: "beach_1",
                    timeAgo: "5d ago",
                    title: "UIKit vs SwiftUI",
                    tags: ["UIKit", "SwiftUI"],
                    imageName: "images",
                    description: "Both are tools, stop fighting",
                    likes: 210,
                    comments: 22,
                    shares: 6,
                    isLiked: false
                ),

                ThreadPost(
                    id: 9,
                    userName: "Anandita Babar",
                    userProfileImage: "beach_1",
                    timeAgo: "1w ago",
                    title: "Debugging mindset",
                    tags: ["Debugging"],
                    imageName: "beach_15",
                    description: "Logs before panic",
                    likes: 305,
                    comments: 31,
                    shares: 10,
                    isLiked: false
                )
    ]
    
  
    func getForYouThreads() -> [ThreadPost] {
//        threadPosts.filter { $0.userName != currentUserName }
        threadPosts.filter {
              $0.userName != currentUserName &&
              !followedUsers.contains($0.userName)
          }
    }
    
 
    func getFollowingThreads() -> [ThreadPost]{
        threadPosts.filter {
                followedUsers.contains($0.userName)
            }
    }
   
    func getMyThreads() -> [ThreadPost] {
        threadPosts.filter { $0.userName == currentUserName }
    }
    
  
    func addNewThread(_ thread: ThreadPost) {
        threadPosts.insert(thread, at: 0)
    }
    
  
    func toggleLike(for threadID: Int) {
            guard let index = threadPosts.firstIndex(where: { $0.id == threadID }) else { return }

            threadPosts[index].isLiked.toggle()

        threadPosts[index].likes += threadPosts[index].isLiked ? 1 : -1
        }
    
    func follow(userName: String) {
        followedUsers.insert(userName)
    }

    func unfollow(userName: String) {
        followedUsers.remove(userName)
    }

    func isFollowing(userName: String) -> Bool {
        followedUsers.contains(userName)
    }
    
    func toggleFollow(userName: String) {
        if followedUsers.contains(userName) {
            followedUsers.remove(userName)
        } else {
            followedUsers.insert(userName)
        }
    }

}

