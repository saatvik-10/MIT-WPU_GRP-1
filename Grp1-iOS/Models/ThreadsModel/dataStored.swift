//
//  model.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 28/11/25.
//

import Foundation

class ThreadsDataStore {
    
    
    static let shared = ThreadsDataStore()
    private init() {
        drafts = [
               Draft(
                   id: UUID(),
                   title: "Saved draft",
                   topic: "iOS",
                   body: "This is a preloaded draft",
                   imageName: "rbi-1722414243",
                   lastUpdated: Date(),
               )
           ]
    }
    
    let currentUserName = "Anandita Babar"
    
    
    private var followedUsers: Set<String> = [
        "Ishan Magarde"
    ]
    
    private var threadPosts: [ThreadPost] = [

        ThreadPost(
            id: 1,
            userName: "Rishabh Kothari",
            userProfileImage: "person.fill",
            timeAgo: "15h ago",
            title: "Is the global economy heading for a slowdown?",
            tags: ["Economy", "Global Markets"],
            imageName: "urban_5",
            description: """
    Rising interest rates, slowing consumer demand, and geopolitical tensions are forcing economists to rethink growth projections for the next year.
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
            timeAgo: "19h ago",
            title: "Is the stock market rally sustainable?",
            tags: ["Markets", "Nifty"],
            imageName: "img(F5)",
            description: """
    Indian indices continue to hit record highs, but stretched valuations and global cues raise questions about how long this rally can last.
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
            title: "Why AI stocks are attracting massive capital",
            tags: ["AI", "Investing"],
            imageName: "beach_7",
            description: """
    From chips to software platforms, investors are betting big on AI-led growth, but valuations are starting to price in perfection.
    """,
            likes: 332,
            comments: 18,
            shares: 4,
            isLiked: false
        ),

        ThreadPost(
            id: 4,
            userName: "Mitali Shah",
            userProfileImage: "person.fill",
            timeAgo: "3h ago",
            title: "How strong balance sheets protect investors",
            tags: ["Fundamentals", "Stocks"],
            imageName: "beach_13",
            description: """
    Companies with low debt and healthy cash flows tend to survive market downturns better and reward long-term investors.
    """,
            likes: 190,
            comments: 12,
            shares: 2,
            isLiked: false
        ),

                //
                ThreadPost(
                    id: 6,
                    userName: "Anandita Babar",
                    userProfileImage: "beach_1",
                    timeAgo: "2d ago",
                    title: "Building Threads UI",
                    tags: ["iOS", "UIKit","Anandita"],
                    imageName: "beach_9",
                    description: "Lessons learnt while building Threads clone",
                    likes: 120,
                    comments: 14,
                    shares: 3,
                    isLiked: false
                ),

        ThreadPost(
            id: 6,
            userName: "Anandita Babar",
            userProfileImage: "beach_1",
            timeAgo: "2d ago",
            title: "How I plan my long-term investments",
            tags: ["Long Term", "Finance"],
            imageName: "beach_9",
            description: """
    Consistency, asset allocation, and patience matter more than chasing short-term returns in wealth creation.
    """,
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
            title: "Why market volatility is not your enemy",
            tags: ["Markets", "Psychology"],
            imageName: "urban_2",
            description: """
    Volatility creates fear, but for disciplined investors it often presents the best opportunities to buy quality businesses.
    """,
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
            title: "Mutual funds vs direct stocks",
            tags: ["Mutual Funds", "Stocks"],
            imageName: "images",
            description: """
    Both approaches have their merits — the right choice depends on risk appetite, time commitment, and investment knowledge.
    """,
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
            title: "The mindset needed to build wealth",
            tags: ["Mindset", "Wealth"],
            imageName: "beach_15",
            description: """
    Wealth creation is less about predicting markets and more about discipline, patience, and emotional control.
    """,
            likes: 305,
            comments: 31,
            shares: 10,
            isLiked: false
        )
    ]
    
    private var drafts: [Draft] = []
    
    
    func getDrafts() -> [Draft] {
        drafts
    }
    
    func saveDraft(
            title: String?,
            topic: String?,
            body: String?,
            imageName: String?
        ) {
            let draft = Draft(
                id: UUID(),
                title: title,
                topic: topic,
                body: body,
                imageName: imageName,
                lastUpdated: Date()
            )

            drafts.insert(draft, at: 0)
            print("DRAFT COUNT:", drafts.count)
        }
    
    func updateDraft(
        id: UUID,
        title: String?,
        topic: String?,
        body: String?,
        imageName: String?
    ) {
        guard let index = drafts.firstIndex(where: { $0.id == id }) else { return }

        drafts[index].title = title
        drafts[index].topic = topic
        drafts[index].body = body
        drafts[index].imageName = imageName
        drafts[index].lastUpdated = Date()
    }

    func deleteDraft(id: UUID) {
            drafts.removeAll { $0.id == id }
        }
    
    
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
    

    func postThreadFromCreate(
        title: String,
        body: String,
        imageName: String?
    ) {
        let newThread = ThreadPost(
            id: Int(Date().timeIntervalSince1970),
            userName: currentUserName,
            userProfileImage: "beach_1",
            timeAgo: "Just now",
            title: title,
            tags: ["iOS"],
            imageName: imageName,
            description: body,
            likes: 0,
            comments: 0,
            shares: 0,
            isLiked: false
        )

        addNewThread(newThread)
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

