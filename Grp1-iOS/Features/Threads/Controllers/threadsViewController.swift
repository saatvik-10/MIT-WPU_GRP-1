// import UIKit

// enum ThreadsSegment {
//     case forYou
//     case following
//     case myThreads
// }

// class threadsViewController: UIViewController {
    
//     @IBOutlet weak var collectionView: UICollectionView!
    
//     @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
//     private let threadsStore = [APIThread]
        
//     private var forYouThreads: [APIThread] = []
//     private var followingThreads: [APIThread] = []
//     private var selectedSegment: ThreadsSegment = .forYou
        
//     private var currentUserId: String? {
//         UserDefaults.standard.string(forKey: "userId")
//     }
//     private var authToken: String? {
//         UserDefaults.standard.string(forKey: "authToken")
//     }
        
        
//         override func viewDidLoad() {
            
//             super.viewDidLoad()
            
//             segmentControl.selectedSegmentIndex = 0
//             setupCollectionView()
//             loadThreads()
//             testRecommendationEngine()  
            
//             let bg = UIColor(white: 250/255, alpha: 1)
//             view.backgroundColor = bg
//             collectionView.backgroundColor = bg
//             //crosscheck below 2 line
//            // collectionView.delegate = self
//            // collectionView.dataSource = self
//             threadsStore.addComment(to: 1, text: "This helped a lot, thanks!")
//             threadsStore.addComment(to: 1, text: "Can you cover risks next?")
//             NotificationCenter.default.addObserver(self, selector: #selector(refreshFeed), name: .commentAdded, object: nil)
            
            
//         }
//     private func testRecommendationEngine() {
//         var profile = MockEnvironment.shared.ananditaProfile
//         let articles = MockEnvironment.shared.blogArticles(
//             from: ThreadsDataStore.shared.getForYouThreads()
//         )
        
//         let results = BlogRecommendationEngine.shared.recommend(
//             articles: articles,
//             profile: &profile,
//             limit: 20
//         )
        
//         print("\n" + String(repeating: "=", count: 60))
//         print("🎯 RECOMMENDATION ENGINE RESULTS FOR ANANDITA")
//         print(String(repeating: "=", count: 60))
        
//         for (rank, item) in results.enumerated() {
//             print("""
            
//             #\(rank + 1) [\(String(format: "%.1f", item.finalScore))] \(item.article.title)
//                  base: \(String(format: "%.1f", item.baseScore)) | level: ×\(String(format: "%.2f", item.levelMultiplier)) | fresh: ×\(String(format: "%.2f", item.freshnessScore))
//                  tags: \(item.matchedTags.isEmpty ? "none matched" : item.matchedTags.joined(separator: ", "))
//             """)
//         }
//         print(String(repeating: "=", count: 60) + "\n")
//     }
//         override func viewDidLayoutSubviews() {
//             super.viewDidLayoutSubviews()
     
//             if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//                 layout.invalidateLayout()
//             }
//         }
      
       
//         @objc private func refreshFeed() {
//             reloadData()
//             collectionView.reloadData()
//         }
        
//         @IBAction func segmentChanged(_ sender: UISegmentedControl) {
//             switch sender.selectedSegmentIndex {
//             case 0: selectedSegment = .forYou
//             case 1: selectedSegment = .following
//             case 2: selectedSegment = .myThreads
//             default: break
//             }
            
//             reloadData()
//             collectionView.setContentOffset(.zero, animated: false)
//             collectionView.reloadData()
//         }
        
//         @IBAction func didTapSearchButton(_ sender: UIBarButtonItem) {
//             let searchVC = ThreadsSearchViewController()
//                navigationController?.pushViewController(searchVC, animated: true)
//         }
        
//         @IBAction func didTapPlusButton(_ sender: UIBarButtonItem) {
//             performSegue(withIdentifier: "showCreatePost", sender: nil)
//         }
        
        
//         private func setupCollectionView() {
//             collectionView.delegate = self
//             collectionView.dataSource = self
            
          
//             collectionView.register(
//                 UINib(nibName: "collectionViewCell", bundle: nil),
//                 forCellWithReuseIdentifier: "collectionViewCell"
//             )
            
            
          
//             collectionView.register(
//                 UINib(nibName: "MyThreadsProfileHeaderCollectionReusableView", bundle: nil),
//                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                 withReuseIdentifier: "MyThreadsProfileHeaderCollectionReusableView"
//             )
            
//     //        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//     //            layout.scrollDirection = .vertical
//     //            layout.minimumLineSpacing = 20
//     //            layout.minimumInteritemSpacing = 4
//     //            layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
//     //            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//     //        }
//             guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
//                 return
//             }
           
//             layout.scrollDirection = .vertical
//             layout.minimumLineSpacing = 16    //20
//             layout.minimumInteritemSpacing = 12
//             layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
//             layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        
     
//         }

//         // MARK: - Load Threads from API

//      private func loadForYouThreads() {
//         APIService.shared.fetchForYouThreads { [weak self] result in
//             DispatchQueue.main.async {
//                 if case .success(let threads) = result {
//                     self?.forYouThreads = threads
//                     if self?.selectedSegment == .forYou { self?.collectionView.reloadData() }
//                 }
//             }
//         }
//     }
    
//     private func loadFollowingThreads() {
//         guard let token = authToken else { return }
//         APIService.shared.fetchFollowingThreads(token: token) { [weak self] result in
//             DispatchQueue.main.async {
//                 if case .success(let threads) = result {
//                     self?.followingThreads = threads
//                     if self?.selectedSegment == .following { self?.collectionView.reloadData() }
//                 }
//             }
//         }
//     }

//     private func loadThreads() {
//         APIService.shared.fetchForYouThreads { [weak self] result in
//             guard let self = self else { return }
            
//             DispatchQueue.main.async {
//                 switch result {
//                 case .success(let apiThreads):
//                     self.threads = apiThreads
//                     self.collectionView.reloadData()  // or tableView.reloadData()
                    
//                 case .failure(let error):
//                     print("❌ Failed to load threads: \(error)")
//                 }
//             }
//         }
//     }

        
        
//         private func reloadData() {
//     //        forYouThreads = threadsStore.getAllThreads()
//     //        followingThreads = threadsStore.getFollowingThreads()
//              forYouThreads = threadsStore.getForYouThreads()
//                 followingThreads = threadsStore.getFollowingThreads()
//         }
       
//     //    private func calculateItemWidth() -> CGFloat {
//     //        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
//     //        else {
//     //            return 180
//     //        }
//     //        let totalHorizontalPadding = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing
//     //        let availableWidth = collectionView.bounds.width - totalHorizontalPadding
//     //        let itemWidth = floor(availableWidth / 2)
//     //
//     //        return itemWidth
//     //    }
//     }
        
     
     
//         extension threadsViewController: UICollectionViewDataSource {
     
//             func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//                 switch selectedSegment {
//                     case .forYou: return threadsStore.getForYouThreads().count
//                     case .following: return threadsStore.getFollowingThreads().count
//                     case .myThreads: return threadsStore.getMyThreads().count
//                     }
//                }
     
//                func collectionView(
//                    _ collectionView: UICollectionView,
//                    cellForItemAt indexPath: IndexPath
//                ) -> UICollectionViewCell {
                  
//                    let cell = collectionView.dequeueReusableCell(
//                     withReuseIdentifier: "collectionViewCell",
//                     for: indexPath        )
//                    as! collectionViewCell
                   
//                   // let itemWidth = calculateItemWidth()
//                  //  cell.updateWidth(itemWidth)
                   
     
//                    let post: ThreadPost
//                    switch selectedSegment {
//                    case .forYou: post = threadsStore.getForYouThreads()[indexPath.item]
//                    case .following: post = threadsStore.getFollowingThreads()[indexPath.item]
//                    case .myThreads: post = threadsStore.getMyThreads()[indexPath.item]
//                    }
     
//                    let isFollowing = threadsStore.isFollowing(post.userName)
//                    let isOwnPost = post.userName == threadsStore.currentUserName
//                    cell.configure(with: post, isFollowing: isFollowing, isOwnPost: isOwnPost)
//                    cell.applyStyle(isCard: selectedSegment != .myThreads)
                   
//                    cell.onLikeTapped = { [weak self] in
//                        guard let self else { return }
//                        self.threadsStore.toggleLike(for: post.id)
//                        self.reloadData()
//                        self.collectionView.reloadItems(at: [indexPath])
//                    }
                   
//                    cell.onFollowTapped = { [weak self] in
//                        guard let self else { return }
     
//                        self.threadsStore.toggleFollow(post.userName)
     
//                        self.reloadData()
//                        self.collectionView.reloadData()
                       
                       
//                    }
                   
//                    cell.onUsernameTapped = { [weak self] in
//                                           guard let self else { return }
//                                           guard post.userName != self.threadsStore.currentUserName else { return }
//                                           let profileVC = BloggerProfileViewController()
//                                           profileVC.bloggerUserName = post.userName
//                                           self.navigationController?.pushViewController(profileVC, animated: true)
//                                       }
                   
//                    cell.onCommentTapped = { [weak self] in
//                        guard let self else { return }
                       
//                        let vc = CommentsViewController()
//                        vc.postID = post.id
//                        vc.modalPresentationStyle = .pageSheet
//                        // vc.modalPresentationStyle = .overFullScreen
//                        // vc.modalTransitionStyle = .crossDissolve
//                        if let screen = self.view.window?.windowScene?.screen {
//                            vc.preferredContentSize = CGSize(width: screen.bounds.width, height: 0)
//                        }
//                        if let sheet = vc.sheetPresentationController {
//                            //     sheet.detents = [.medium(), .large()]      // 👈 native bottom sheet
//                            sheet.prefersGrabberVisible = true         // small drag indicator
//                            sheet.preferredCornerRadius = 40           // rounded top corners
//                            sheet.largestUndimmedDetentIdentifier = .medium
//                            sheet.selectedDetentIdentifier = .medium
                           
//                            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
//                            sheet.prefersEdgeAttachedInCompactHeight = true
                           
//                        }
//                        self.present(vc, animated: true)
//                    }
//                        cell.onDeleteTapped = { [weak self] in
//                            guard let self else { return }
                           
//                            let alert = UIAlertController(
//                                title: "Delete Post",
//                                message: "Are you sure you want to delete this post?",
//                                preferredStyle: .alert
//                            )
                           
//                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                           
//                            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
//                                self.threadsStore.deletePost(id: post.id)
//                                self.reloadData()
//                                self.collectionView.reloadData()
//                            })
                           
//                            self.present(alert, animated: true)
//                        }
                           
//                    return cell
//                }
     
               
//                func collectionView(
//                    _ collectionView: UICollectionView,
//                    viewForSupplementaryElementOfKind kind: String,
//                    at indexPath: IndexPath
//                ) -> UICollectionReusableView {
     
//                    let header = collectionView.dequeueReusableSupplementaryView(
//                        ofKind: kind,
//                        withReuseIdentifier: "MyThreadsProfileHeaderCollectionReusableView",
//                        for: indexPath
//                    ) as! MyThreadsProfileHeaderCollectionReusableView
     
//                    let user = MockEnvironment.shared.anandita
//                    header.configure(
//                        userName: user.userName,
//                        profileImage: user.profileImage,
//                        posts: threadsStore.getMyThreads().count,
//                        followers: user.followerCount,    // → 20
//                        following: user.followingCount    // → 22
//                    )
     
//                    header.onFollowersTapped = { [weak self] in
//                        guard let self else { return }
//                        let vc = FollowersFollowingViewController()
//                        vc.initialSegment = 0
//                        vc.followerNames = ["Rishabh Kothari", "Tanmay Verma", "Mitali Shah"]
//                        vc.followingNames = Array(Set(self.threadsStore.getFollowingThreads().map { $0.userName }))
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
     
//                    header.onFollowingTapped = { [weak self] in
//                        guard let self else { return }
//                        let vc = FollowersFollowingViewController()
//                        vc.initialSegment = 1
//                        vc.followerNames = ["Rishabh Kothari", "Tanmay Verma", "Mitali Shah"]
//                        vc.followingNames = Array(Set(self.threadsStore.getFollowingThreads().map { $0.userName }))
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
     
//                    return header
//                }
//             }
     
        
     
        
//         extension threadsViewController: UICollectionViewDelegateFlowLayout {
            
//     //        func collectionView(
//     //            _ collectionView: UICollectionView,
//     //            layout collectionViewLayout: UICollectionViewLayout,
//     //            sizeForItemAt indexPath: IndexPath
//     //        ) -> CGSize {
//     //           let itemWidth = calculateItemWidth()
//     //
//     //            return CGSize(width: itemWidth, height: 10)
//     //        }
     
//             func collectionView(
//                 _ collectionView: UICollectionView,
//                 layout collectionViewLayout: UICollectionViewLayout,
//                 referenceSizeForHeaderInSection section: Int
//             ) -> CGSize {
     
//                 guard selectedSegment == .myThreads else { return .zero }
     
//                 return CGSize(
//                     width: collectionView.bounds.width,
//                     height: 120
//                 )
//             }
//        }
     
         
//     extension threadsViewController: UICollectionViewDelegate {
//         func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
//                 let post: ThreadPost
//                 switch selectedSegment {
//                 case .forYou:
//                     post = forYouThreads[indexPath.item]
//                 case .following:
//                     post = followingThreads[indexPath.item]
//                 case .myThreads:
//                     post =  threadsStore.getMyThreads()[indexPath.item]
//                 }
     
//                 let detailVC = ThreadDetailViewController()
//                 detailVC.thread = post
//                 navigationController?.pushViewController(detailVC, animated: true)
//             }
//     }
import UIKit

enum ThreadsSegment {
    case forYou
    case following
    case myThreads
}

class threadsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    // MARK: - Data (now backed by API)
    private var forYouThreads: [APIThread] = []
    private var followingThreads: [APIThread] = []
    private var myThreads: [APIThread] = []
    private var selectedSegment: ThreadsSegment = .forYou
    
    private var currentUserId: String? {
        UserDefaults.standard.string(forKey: "userId")
    }
    private var authToken: String? {
        UserDefaults.standard.string(forKey: "authToken")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.selectedSegmentIndex = 0
        setupCollectionView()
        
        let bg = UIColor(white: 250/255, alpha: 1)
        view.backgroundColor = bg
        collectionView.backgroundColor = bg
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshFeed),
            name: .threadCreated,
            object: nil
        )
        
        loadThreads()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadThreads()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }
    
    // MARK: - Actions
    
    @objc private func refreshFeed() {
        loadThreads()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: selectedSegment = .forYou
        case 1: selectedSegment = .following
        case 2: selectedSegment = .myThreads
        default: break
        }
        collectionView.setContentOffset(.zero, animated: false)
        collectionView.reloadData()
    }
    
    @IBAction func didTapSearchButton(_ sender: UIBarButtonItem) {
        let searchVC = ThreadsSearchViewController()
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @IBAction func didTapPlusButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showCreatePost", sender: nil)
    }
    
    // MARK: - CollectionView Setup
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(
            UINib(nibName: "collectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "collectionViewCell"
        )
        collectionView.register(
            UINib(nibName: "MyThreadsProfileHeaderCollectionReusableView", bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "MyThreadsProfileHeaderCollectionReusableView"
        )
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
    
    // MARK: - API Fetching
    
    private func loadThreads() {
        loadForYouThreads()
        loadFollowingThreads()
        loadMyThreads()
    }
    
    private func loadForYouThreads() {
        APIService.shared.fetchForYouThreads(token: authToken) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let threads) = result {
                    self?.forYouThreads = threads
                    if self?.selectedSegment == .forYou { self?.collectionView.reloadData() }
                }
            }
        }
    }
    
    private func loadFollowingThreads() {
        guard let token = authToken else { return }
        APIService.shared.fetchFollowingThreads(token: token) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let threads) = result {
                    self?.followingThreads = threads
                    if self?.selectedSegment == .following { self?.collectionView.reloadData() }
                }
            }
        }
    }
    
    private func loadMyThreads() {
        // Filter forYou by currentUserId. If your backend has a
        // dedicated "my threads" endpoint, replace this.
        APIService.shared.fetchForYouThreads(token: authToken) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let threads) = result {
                    self?.myThreads = threads.filter { $0.userId == self?.currentUserId }
                    if self?.selectedSegment == .myThreads { self?.collectionView.reloadData() }
                }
            }
        }
    }
    
    private func currentThreads() -> [APIThread] {
        switch selectedSegment {
        case .forYou:    return forYouThreads
        case .following: return followingThreads
        case .myThreads: return myThreads
        }
    }

    private func updateThreadLikeState(threadId: String, isLiked: Bool, count: Int) {
        if let idx = forYouThreads.firstIndex(where: { $0.id == threadId }) {
            forYouThreads[idx].isLiked = isLiked
            forYouThreads[idx].likesCount = count
        }
        if let idx = followingThreads.firstIndex(where: { $0.id == threadId }) {
            followingThreads[idx].isLiked = isLiked
            followingThreads[idx].likesCount = count
        }
        if let idx = myThreads.firstIndex(where: { $0.id == threadId }) {
            myThreads[idx].isLiked = isLiked
            myThreads[idx].likesCount = count
        }
    }
}

// MARK: - DataSource
extension threadsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        currentThreads().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "collectionViewCell", for: indexPath
        ) as! collectionViewCell
        
        let thread = currentThreads()[indexPath.item]
        let isOwnPost = thread.userId == currentUserId
        
        cell.configure(with: thread, isFollowing: false, isOwnPost: isOwnPost)
        cell.applyStyle(isCard: selectedSegment != .myThreads)
        
        // ── Like ──
        cell.onLikeTapped = { [weak self, weak cell] in
            guard let self, let token = self.authToken else { return }
            
            // ⬇️ Fetch the LATEST thread state directly from the array!
            let currentThreadList = self.currentThreads()
            guard indexPath.item < currentThreadList.count else { return }
            let latestThread = currentThreadList[indexPath.item]
            guard latestThread.id == thread.id else { return } // Safety check in case elements shifted
            
            // 1. Calculate optimistic state using `latestThread`
            let wasLiked = latestThread.isLiked ?? false
            let newLiked = !wasLiked
            let newCount = latestThread.likesCount + (newLiked ? 1 : -1) // +1 if newly liked, else -1
            
            // 2. Instantly update UI on the cell without reloading it
            let image = newLiked ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
            cell?.likesButton.setImage(image, for: .normal)
            cell?.likesButton.tintColor = newLiked ? .systemRed : .systemBlue
            cell?.likesButton.setTitle("\(max(0, newCount))", for: .normal)
            
            // 3. Save state to local arrays so it won't revert when scrolling
            self.updateThreadLikeState(threadId: latestThread.id, isLiked: newLiked, count: newCount)
            
            // 4. Fire API call invisibly in the background
            APIService.shared.toggleLike(threadId: latestThread.id, token: token) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let response):
                        // Completely Sync server's latest count (just in case)
                        self.updateThreadLikeState(
                            threadId: latestThread.id,
                            isLiked: response.liked,
                            count: response.likesCount
                        )
                    case .failure:
                        // Revert everything logically and visually if cell failed
                        self.updateThreadLikeState(threadId: latestThread.id, isLiked: wasLiked, count: latestThread.likesCount)
                        self.collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
        
        // ── Follow ──
        cell.onFollowTapped = { [weak self] in
            guard let self, let token = self.authToken,
                  let userId = thread.user?.id else { return }
            APIService.shared.updateFollow(followingId: userId, token: token) { result in
                DispatchQueue.main.async {
                    if case .success = result { self.loadThreads() }
                }
            }
        }
        
        // ── Username tap ──
        cell.onUsernameTapped = { [weak self] in
            guard let self else { return }
            guard thread.userId != self.currentUserId else { return }
            let profileVC = BloggerProfileViewController()
            profileVC.bloggerUserId = thread.userId
            profileVC.bloggerUserName = thread.user?.username ?? thread.userId
            self.navigationController?.pushViewController(profileVC, animated: true)
        }
        
        // ── Comment ──
        cell.onCommentTapped = { [weak self] in
            guard let self else { return }
            let vc = CommentsViewController()
            vc.threadId = thread.id   // pass the String ID for API
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 40
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.selectedDetentIdentifier = .medium
            }
            self.present(vc, animated: true)
        }
        
        // ── Delete ──
        cell.onDeleteTapped = { [weak self] in
            guard let self, let token = self.authToken else { return }
            let alert = UIAlertController(title: "Delete Post", message: "Are you sure?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                APIService.shared.deleteThread(threadId: thread.id, token: token) { result in
                    DispatchQueue.main.async {
                        if case .success = result { self.loadThreads() }
                    }
                }
            })
            self.present(alert, animated: true)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "MyThreadsProfileHeaderCollectionReusableView",
            for: indexPath
        ) as! MyThreadsProfileHeaderCollectionReusableView
        
        let user = MockEnvironment.shared.anandita
        header.configure(
            userName: user.userName,
            profileImage: user.profileImage,
            posts: myThreads.count,
            followers: user.followerCount,
            following: user.followingCount
        )
        return header
    }
}

// MARK: - FlowLayout
extension threadsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard selectedSegment == .myThreads else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: 120)
    }
}

// MARK: - Delegate
extension threadsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let thread = currentThreads()[indexPath.item]
        let detailVC = ThreadDetailViewController()
        detailVC.thread = thread   // already takes APIThread
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

// MARK: - Notification
extension Notification.Name {
    static let threadCreated = Notification.Name("threadCreated")
}
