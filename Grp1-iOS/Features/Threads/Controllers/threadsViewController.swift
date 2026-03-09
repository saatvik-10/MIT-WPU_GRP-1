import UIKit

enum ThreadsSegment {
    case forYou
    case following
    case myThreads
}

class threadsViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    private let threadsStore = ThreadsDataStore.shared
    
    private var forYouThreads: [ThreadPost] = []
    private var followingThreads: [ThreadPost] = []
    private var selectedSegment: ThreadsSegment = .forYou
    
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        segmentControl.selectedSegmentIndex = 0
        setupCollectionView()
        reloadData()
        
        let bg = UIColor(white: 250/255, alpha: 1)
        view.backgroundColor = bg
        collectionView.backgroundColor = bg
        //crosscheck below 2 line
       // collectionView.delegate = self
       // collectionView.dataSource = self
        threadsStore.addComment(to: 1, text: "This helped a lot, thanks!")
        threadsStore.addComment(to: 1, text: "Can you cover risks next?")
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFeed), name: .commentAdded, object: nil)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.invalidateLayout()
        }
    }
  
   
    @objc private func refreshFeed() {
        reloadData()
        collectionView.reloadData()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: selectedSegment = .forYou
        case 1: selectedSegment = .following
        case 2: selectedSegment = .myThreads
        default: break
        }
        
        reloadData()
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
        
//        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            layout.scrollDirection = .vertical
//            layout.minimumLineSpacing = 20
//            layout.minimumInteritemSpacing = 4
//            layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
//            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//        }
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
       
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16    //20
        layout.minimumInteritemSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    

    }
    
    
    private func reloadData() {
//        forYouThreads = threadsStore.getAllThreads()
//        followingThreads = threadsStore.getFollowingThreads()
         forYouThreads = threadsStore.getForYouThreads()
            followingThreads = threadsStore.getFollowingThreads()
    }
   
//    private func calculateItemWidth() -> CGFloat {
//        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
//        else {
//            return 180
//        }
//        let totalHorizontalPadding = layout.sectionInset.left + layout.sectionInset.right + layout.minimumInteritemSpacing
//        let availableWidth = collectionView.bounds.width - totalHorizontalPadding
//        let itemWidth = floor(availableWidth / 2)
//        
//        return itemWidth
//    }
}
    


    extension threadsViewController: UICollectionViewDataSource {

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            switch selectedSegment {
                case .forYou: return threadsStore.getForYouThreads().count
                case .following: return threadsStore.getFollowingThreads().count
                case .myThreads: return threadsStore.getMyThreads().count
                }
           }

           func collectionView(
               _ collectionView: UICollectionView,
               cellForItemAt indexPath: IndexPath
           ) -> UICollectionViewCell {
              
               let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "collectionViewCell",
                for: indexPath        )
               as! collectionViewCell
               
              // let itemWidth = calculateItemWidth()
             //  cell.updateWidth(itemWidth)
               

               let post: ThreadPost
               switch selectedSegment {
               case .forYou: post = threadsStore.getForYouThreads()[indexPath.item]
               case .following: post = threadsStore.getFollowingThreads()[indexPath.item]
               case .myThreads: post = threadsStore.getMyThreads()[indexPath.item]
               }

               let isFollowing = threadsStore.isFollowing(userName: post.userName)
               let isOwnPost = post.userName == threadsStore.currentUserName
               cell.configure(with: post, isFollowing: isFollowing, isOwnPost: isOwnPost)
               cell.applyStyle(isCard: selectedSegment != .myThreads)
               
               cell.onLikeTapped = { [weak self] in
                   guard let self else { return }
                   self.threadsStore.toggleLike(for: post.id)
                   self.reloadData()
                   self.collectionView.reloadItems(at: [indexPath])
               }
               
               cell.onFollowTapped = { [weak self] in
                   guard let self else { return }

                   self.threadsStore.toggleFollow(userName: post.userName)

                   self.reloadData()
                   self.collectionView.reloadData()
                   
                   
               }
               
               cell.onCommentTapped = { [weak self] in
                   guard let self else { return }
                   
                   let vc = CommentsViewController()
                   vc.postID = post.id
                   vc.modalPresentationStyle = .pageSheet
                   // vc.modalPresentationStyle = .overFullScreen
                   // vc.modalTransitionStyle = .crossDissolve
                   if let screen = self.view.window?.windowScene?.screen {
                       vc.preferredContentSize = CGSize(width: screen.bounds.width, height: 0)
                   }
                   if let sheet = vc.sheetPresentationController {
                       //     sheet.detents = [.medium(), .large()]      // 👈 native bottom sheet
                       sheet.prefersGrabberVisible = true         // small drag indicator
                       sheet.preferredCornerRadius = 40           // rounded top corners
                       sheet.largestUndimmedDetentIdentifier = .medium
                       sheet.selectedDetentIdentifier = .medium
                       
                       sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                       sheet.prefersEdgeAttachedInCompactHeight = true
                       
                   }
                   self.present(vc, animated: true)
               }
                   cell.onDeleteTapped = { [weak self] in
                       guard let self else { return }
                       
                       let alert = UIAlertController(
                           title: "Delete Post",
                           message: "Are you sure you want to delete this post?",
                           preferredStyle: .alert
                       )
                       
                       alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                       
                       alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
                           self.threadsStore.deletePost(id: post.id)
                           self.reloadData()
                           self.collectionView.reloadData()
                       })
                       
                       self.present(alert, animated: true)
                   }
                       
               return cell
           }

           
           func collectionView(
               _ collectionView: UICollectionView,
               viewForSupplementaryElementOfKind kind: String,
               at indexPath: IndexPath
           ) -> UICollectionReusableView {

               let header = collectionView.dequeueReusableSupplementaryView(
                   ofKind: kind,
                   withReuseIdentifier: "MyThreadsProfileHeaderCollectionReusableView",
                   for: indexPath
               ) as! MyThreadsProfileHeaderCollectionReusableView

               header.configure(
                   userName: "Anandita Babar",
                   profileImage: "beach_1",
                   posts: 5,
                   followers: 345,
                   following: 45
               )

               return header
           }
        }

    

    
    extension threadsViewController: UICollectionViewDelegateFlowLayout {
        
//        func collectionView(
//            _ collectionView: UICollectionView,
//            layout collectionViewLayout: UICollectionViewLayout,
//            sizeForItemAt indexPath: IndexPath
//        ) -> CGSize {
//           let itemWidth = calculateItemWidth()
//            
//            return CGSize(width: itemWidth, height: 10)
//        }

        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            referenceSizeForHeaderInSection section: Int
        ) -> CGSize {

            guard selectedSegment == .myThreads else { return .zero }

            return CGSize(
                width: collectionView.bounds.width,
                height: 120
            )
        }
   }

     
extension threadsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

            let post: ThreadPost
            switch selectedSegment {
            case .forYou:
                post = forYouThreads[indexPath.item]
            case .following:
                post = followingThreads[indexPath.item]
            case .myThreads:
                post =  threadsStore.getMyThreads()[indexPath.item]
            }

            let detailVC = ThreadDetailViewController()
            detailVC.thread = post
            navigationController?.pushViewController(detailVC, animated: true)
        }
}
