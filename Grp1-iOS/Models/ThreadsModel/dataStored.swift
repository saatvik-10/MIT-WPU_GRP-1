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
    Rising interest rates, 
    """,
            likes: 702,
            comments: [],
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
    Indian indices continue to hit record highs, but stretched valuations and global cues raise questions about how long this rally can last.Indian indices continue to hit record highs, but stretched valuations and global cues raise questions about how long this rally can last.
    """,
            likes: 518,
            comments: [],
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
            comments: [],
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
            comments: [],
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
                    comments: [],
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
            comments: [],
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
            comments: [],
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
            comments: [],
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
            comments: [],
            shares: 10,
            isLiked: false
        )
    ]
    
    private var drafts: [Draft] = []
    
    
    func getDrafts() -> [Draft] {
        drafts
    }
    
    private func indexOfPost(with id: Int) -> Int? {
        threadPosts.firstIndex { $0.id == id }
    }
    
    func getComments(for postID: Int) -> [Comment] {
        guard let index = indexOfPost(with: postID) else { return [] }
        return threadPosts[index].comments
    }
    
    func addComment(to postID: Int, text: String) {
        guard let index = indexOfPost(with: postID) else { return }

        let newComment = Comment(
            id: UUID(),
            userName: currentUserName,
            userProfileImage: "beach_1",
            text: text,
            likes: 0,
            isLiked: false,
            replies: []
        )

        threadPosts[index].comments.insert(newComment, at: 0)
    }
    
    func toggleLikeOnComment(postID: Int, commentID: UUID) {
        guard let postIndex = indexOfPost(with: postID) else { return }

        guard let commentIndex = threadPosts[postIndex]
            .comments
            .firstIndex(where: { $0.id == commentID }) else { return }

        threadPosts[postIndex].comments[commentIndex].isLiked.toggle()
        threadPosts[postIndex].comments[commentIndex].likes +=
            threadPosts[postIndex].comments[commentIndex].isLiked ? 1 : -1
    }

    func addReply(
        to postID: Int,
        commentID: UUID,
        text: String
    ) {
        guard let postIndex = indexOfPost(with: postID) else { return }

        guard let commentIndex = threadPosts[postIndex]
            .comments
            .firstIndex(where: { $0.id == commentID }) else { return }

        let reply = Reply(
            id: UUID(),
            userName: currentUserName,
            userProfileImage: "beach_1",
            text: text,
            likes: 0,
            isLiked: false
        )

        threadPosts[postIndex].comments[commentIndex].replies.append(reply)
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
              $0.userName != currentUserName ||
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
        imageName: String?,
        tags: [String]
    ) {
        let newThread = ThreadPost(
            id: Int(Date().timeIntervalSince1970),
            userName: currentUserName,
            userProfileImage: "beach_1",
            timeAgo: "Just now",
            title: title,
            tags: tags,
            imageName: imageName,
            description: body,
            likes: 0,
            comments: [],
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
    
    func getAllPostsForSearch() -> [ThreadPost] {
        threadPosts
    }
   
    func deletePost(id: Int) {
           threadPosts.removeAll { $0.id == id }
       }
      
   
}

