//
//  MockEnvironment.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 18/03/26.
//

//  Single source of truth for all mock data across the Threads feature.
//  Import this file and use MockEnvironment.shared anywhere you need
//  users, posts, comments, or a pre-built DynamicUserProfile for engine testing.
 
import Foundation
 
// MARK: - User model
 
struct AppUser {
    let userName: String
    let profileImage: String        // SF Symbol or asset name
    let bio: String
    let followerNames: [String]     // userNames of followers
    let followingNames: [String]    // userNames this user follows
 
    var followerCount: Int { followerNames.count }
    var followingCount: Int { followingNames.count }
}
 
// MARK: - Mock environment
 
final class MockEnvironment {
 
    static let shared = MockEnvironment()
    private init() {}
 
    // MARK: - Users
 
    /// Anandita — the logged-in user
    let anandita = AppUser(
        userName: "Anandita Babar",
        profileImage: "beach_1",
        bio: "Personal finance enthusiast. Long-term investor. iOS dev on the side.",
        followerNames: [
            "Rishabh Kothari", "Ishan Magarde", "Tanmay Verma", "Mitali Shah",
            "Priya Nair", "Arjun Mehta", "Sneha Rao", "Vikram Desai",
            "Neha Joshi", "Rahul Gupta", "Pooja Sharma", "Karan Malhotra",
            "Divya Pillai", "Siddharth Bose", "Meera Iyer", "Aakash Tiwari",
            "Riya Kapoor", "Nikhil Saxena", "Swati Patil", "Harsh Agarwal"
        ],  // 20 followers
        followingNames: [
            "Rishabh Kothari", "Ishan Magarde", "Tanmay Verma", "Mitali Shah",
            "Priya Nair", "Arjun Mehta", "Sneha Rao", "Vikram Desai",
            "Neha Joshi", "Rahul Gupta", "Pooja Sharma", "Karan Malhotra",
            "Divya Pillai", "Siddharth Bose", "Meera Iyer", "Aakash Tiwari",
            "Riya Kapoor", "Nikhil Saxena", "Swati Patil", "Harsh Agarwal",
            "Zara Khan", "Rohan Verma"
        ]   // 22 following
    )
 
    /// Rishabh — a prominent economics writer Anandita follows and reads
    let rishabh = AppUser(
        userName: "Rishabh Kothari",
        profileImage: "person.fill",
        bio: "Macro economist. Writing about global markets and India's growth story.",
        followerNames: ["Anandita Babar", "Ishan Magarde", "Tanmay Verma", "Priya Nair", "Arjun Mehta"],
        followingNames: ["Anandita Babar", "Ishan Magarde"]
    )
 
    let ishan = AppUser(
        userName: "Ishan Magarde",
        profileImage: "person.fill",
        bio: "Nifty watcher. Markets, momentum and money.",
        followerNames: ["Anandita Babar", "Rishabh Kothari", "Mitali Shah"],
        followingNames: ["Anandita Babar", "Rishabh Kothari", "Tanmay Verma"]
    )
 
    let tanmay = AppUser(
        userName: "Tanmay Verma",
        profileImage: "person.fill",
        bio: "AI + investing. Tracking where capital meets technology.",
        followerNames: ["Anandita Babar", "Rishabh Kothari"],
        followingNames: ["Anandita Babar", "Ishan Magarde"]
    )
 
    let mitali = AppUser(
        userName: "Mitali Shah",
        profileImage: "person.fill",
        bio: "Fundamental analysis. Balance sheets don't lie.",
        followerNames: ["Anandita Babar", "Ishan Magarde"],
        followingNames: ["Anandita Babar", "Rishabh Kothari"]
    )
 
    // MARK: - Comments
 
    // Comments on Rishabh's economy post (id: 1)
    lazy var commentsOnPost1: [Comment] = [
        Comment(
            id: UUID(),
            userName: anandita.userName,
            userProfileImage: anandita.profileImage,
            text: "Really well put Rishabh. The Fed pivot timeline is what I'm watching most closely right now.",
            likes: 14,
            isLiked: true,
            replies: [
                Reply(
                    id: UUID(),
                    userName: rishabh.userName,
                    userProfileImage: rishabh.profileImage,
                    text: "Agreed — Q3 is the key window. Any delay and EM currencies take a hit.",
                    likes: 6,
                    isLiked: false
                )
            ]
        ),
        Comment(
            id: UUID(),
            userName: ishan.userName,
            userProfileImage: ishan.profileImage,
            text: "China's property sector drag is the wildcard nobody's pricing in properly.",
            likes: 9,
            isLiked: false,
            replies: []
        ),
        Comment(
            id: UUID(),
            userName: tanmay.userName,
            userProfileImage: tanmay.profileImage,
            text: "If the US tips into recession, AI capex is the first thing that gets cut. Markets haven't figured that out yet.",
            likes: 22,
            isLiked: false,
            replies: []
        )
    ]
 
    // Comments on Ishan's markets post (id: 2)
    lazy var commentsOnPost2: [Comment] = [
        Comment(
            id: UUID(),
            userName: anandita.userName,
            userProfileImage: anandita.profileImage,
            text: "SIP investors shouldn't panic — valuations correct over time. Stay the course.",
            likes: 31,
            isLiked: true,
            replies: [
                Reply(
                    id: UUID(),
                    userName: ishan.userName,
                    userProfileImage: ishan.profileImage,
                    text: "100% Anandita. Volatility is the price of admission for equity returns.",
                    likes: 11,
                    isLiked: false
                )
            ]
        ),
        Comment(
            id: UUID(),
            userName: mitali.userName,
            userProfileImage: mitali.profileImage,
            text: "Mid-caps look stretched. I'm rotating to large-cap quality names for now.",
            likes: 18,
            isLiked: false,
            replies: []
        )
    ]
 
    // Comments on Anandita's long-term investments post (id: 102)
    lazy var commentsOnPost102: [Comment] = [
        Comment(
            id: UUID(),
            userName: rishabh.userName,
            userProfileImage: rishabh.profileImage,
            text: "Asset allocation is so underrated. Most retail investors skip it entirely.",
            likes: 27,
            isLiked: false,
            replies: [
                Reply(
                    id: UUID(),
                    userName: anandita.userName,
                    userProfileImage: anandita.profileImage,
                    text: "Exactly why I start every year rebalancing before I do anything else.",
                    likes: 15,
                    isLiked: false
                )
            ]
        ),
        Comment(
            id: UUID(),
            userName: tanmay.userName,
            userProfileImage: tanmay.profileImage,
            text: "Time in the market > timing the market. Always.",
            likes: 44,
            isLiked: false,
            replies: []
        )
    ]
 
    // Comments on Anandita's volatility post (id: 103)
    lazy var commentsOnPost103: [Comment] = [
        Comment(
            id: UUID(),
            userName: ishan.userName,
            userProfileImage: ishan.profileImage,
            text: "Buffett has said this for decades and people still panic-sell every dip.",
            likes: 19,
            isLiked: false,
            replies: []
        )
    ]
 
    // MARK: - Thread posts
 
    lazy var allPosts: [ThreadPost] = [
 
        // ── Other users ──────────────────────────────────────────────
 
        ThreadPost(
            id: 1,
            userName: rishabh.userName,
            userProfileImage: rishabh.profileImage,
            timeAgo: "15h ago",
            title: "Is the global economy heading for a slowdown?",
            tags: ["Economy", "Global Markets"],
            imageName: "urban_5",
            description: "Rising interest rates, slowing trade, and a weakening yuan are converging in ways that make 2025 look increasingly fragile for global growth.",
            likes: 702,
            comments: commentsOnPost1,
            shares: 11,
            isLiked: true       // Anandita has liked this
        ),
 
        ThreadPost(
            id: 2,
            userName: ishan.userName,
            userProfileImage: ishan.profileImage,
            timeAgo: "19h ago",
            title: "Is the stock market rally sustainable?",
            tags: ["Markets", "Nifty"],
            imageName: "img(F5)",
            description: "Indian indices continue to hit record highs, but stretched valuations and global cues raise questions about how long this rally can last.",
            likes: 518,
            comments: commentsOnPost2,
            shares: 6,
            isLiked: false
        ),
 
        ThreadPost(
            id: 3,
            userName: tanmay.userName,
            userProfileImage: tanmay.profileImage,
            timeAgo: "1d ago",
            title: "Why AI stocks are attracting massive capital",
            tags: ["AI", "Investing"],
            imageName: "beach_7",
            description: "From chips to software platforms, investors are betting big on AI-led growth — but valuations are starting to price in perfection.",
            likes: 332,
            comments: [],
            shares: 4,
            isLiked: false
        ),
 
        ThreadPost(
            id: 4,
            userName: mitali.userName,
            userProfileImage: mitali.profileImage,
            timeAgo: "3h ago",
            title: "How strong balance sheets protect investors",
            tags: ["Fundamentals", "Stocks"],
            imageName: "beach_13",
            description: "Companies with low debt and healthy cash flows tend to survive market downturns better and reward long-term investors.",
            likes: 190,
            comments: [],
            shares: 2,
            isLiked: false
        ),
 
        ThreadPost(
            id: 5,
            userName: rishabh.userName,
            userProfileImage: rishabh.profileImage,
            timeAgo: "2d ago",
            title: "RBI's rate decision: what it means for borrowers",
            tags: ["RBI", "Interest Rates", "Banking"],
            imageName: "rbi-1722414243",
            description: "The MPC held rates steady for the third consecutive meeting. Here's what that means for home loan EMIs, corporate credit, and the rupee.",
            likes: 841,
            comments: [],
            shares: 34,
            isLiked: true       // Anandita bookmarked this too
        ),
 
        ThreadPost(
            id: 6,
            userName: rishabh.userName,
            userProfileImage: rishabh.profileImage,
            timeAgo: "4d ago",
            title: "India's inflation is finally under control — or is it?",
            tags: ["Inflation", "Economy", "RBI"],
            imageName: "urban_5",
            description: "CPI has dipped below 4% for two consecutive months, but food price volatility and a weak monsoon forecast could reverse gains quickly.",
            likes: 390,
            comments: [],
            shares: 9,
            isLiked: false
        ),
 
        // ── Anandita's 5 posts ───────────────────────────────────────
 
        ThreadPost(
            id: 101,
            userName: anandita.userName,
            userProfileImage: anandita.profileImage,
            timeAgo: "2d ago",
            title: "Building Threads UI in UIKit",
            tags: ["iOS", "UIKit"],
            imageName: "beach_9",
            description: "Lessons learnt while building a Threads-style feed — diffable data sources, custom cells, and why Auto Layout still trips me up.",
            likes: 120,
            comments: [],
            shares: 3,
            isLiked: false
        ),
 
        ThreadPost(
            id: 102,
            userName: anandita.userName,
            userProfileImage: anandita.profileImage,
            timeAgo: "3d ago",
            title: "How I plan my long-term investments",
            tags: ["Long Term", "Personal Finance"],
            imageName: "beach_9",
            description: "Consistency, asset allocation, and patience matter more than chasing short-term returns. Here's my actual framework.",
            likes: 210,
            comments: commentsOnPost102,
            shares: 6,
            isLiked: false
        ),
 
        ThreadPost(
            id: 103,
            userName: anandita.userName,
            userProfileImage: anandita.profileImage,
            timeAgo: "5d ago",
            title: "Why market volatility is not your enemy",
            tags: ["Markets", "Psychology"],
            imageName: "urban_2",
            description: "Volatility creates fear, but for disciplined investors it often presents the best opportunities to buy quality businesses at fair prices.",
            likes: 98,
            comments: commentsOnPost103,
            shares: 1,
            isLiked: false
        ),
 
        ThreadPost(
            id: 104,
            userName: anandita.userName,
            userProfileImage: anandita.profileImage,
            timeAgo: "1w ago",
            title: "Mutual funds vs direct stocks — what I chose",
            tags: ["Mutual Funds", "Stocks"],
            imageName: "images",
            description: "Both approaches have merits. The right choice depends on your risk appetite, time availability, and how much you enjoy reading annual reports.",
            likes: 305,
            comments: [],
            shares: 10,
            isLiked: false
        ),
 
        ThreadPost(
            id: 105,
            userName: anandita.userName,
            userProfileImage: anandita.profileImage,
            timeAgo: "2w ago",
            title: "The mindset needed to build wealth",
            tags: ["Mindset", "Wealth"],
            imageName: "beach_15",
            description: "Wealth creation is less about predicting markets and more about discipline, patience, and keeping your emotions out of your portfolio.",
            likes: 445,
            comments: [],
            shares: 18,
            isLiked: false
        )
    ]
 
    // MARK: - Pre-built profile for recommendation engine testing
 
    /// Anandita's onboarding profile — plug straight into BlogRecommendationEngine
    lazy var ananditaProfile = DynamicUserProfile(
        interests: [.stockMarkets, .personalFinance, .indianEconomy, .bankingCredit],
        level: .intermediate
    )
 
    /// Converts ThreadPosts into BlogArticles so the engine can score them
    func blogArticles(from posts: [ThreadPost]) -> [BlogArticle] {
        posts.map { post in
            BlogArticle(
                id: String(post.id),
                title: post.title,
                body: post.description,
                category: post.tags.first ?? "General",
                publishedAt: approximateDate(from: post.timeAgo),
                complexityTier: complexityTier(for: post.tags),
                inferredTags: []
            )
        }
    }
 
    // MARK: - Helpers
 
    private func approximateDate(from timeAgo: String) -> Date {
        let calendar = Calendar.current
        let now = Date()
        if timeAgo.contains("h ago") {
            let hours = Int(timeAgo.components(separatedBy: "h").first ?? "1") ?? 1
            return calendar.date(byAdding: .hour, value: -hours, to: now) ?? now
        } else if timeAgo.contains("d ago") {
            let days = Int(timeAgo.components(separatedBy: "d").first ?? "1") ?? 1
            return calendar.date(byAdding: .day, value: -days, to: now) ?? now
        } else if timeAgo.contains("w ago") {
            let weeks = Int(timeAgo.components(separatedBy: "w").first ?? "1") ?? 1
            return calendar.date(byAdding: .weekOfYear, value: -weeks, to: now) ?? now
        }
        return now
    }
 
    /// Simple heuristic — tags associated with deep-dive topics score higher
    private func complexityTier(for tags: [String]) -> Int {
        let advancedTags = Set(["Fundamentals", "Macro", "RBI", "Interest Rates", "Monetary Policy", "Inflation"])
        let beginnerTags = Set(["Mindset", "Wealth", "Psychology", "Long Term"])
        let lowered = Set(tags.map { $0.lowercased() })
        if lowered.intersection(advancedTags.map { $0.lowercased() }).isEmpty == false { return 2 }
        if lowered.intersection(beginnerTags.map { $0.lowercased() }).isEmpty == false { return 0 }
        return 1
    }
}
