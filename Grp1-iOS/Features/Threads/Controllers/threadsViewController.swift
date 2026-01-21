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
        print("Search tapped")
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
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 4
            layout.sectionInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
            layout.estimatedItemSize = .zero
        }
    }
    
    
    private func reloadData() {
//        forYouThreads = threadsStore.getAllThreads()
//        followingThreads = threadsStore.getFollowingThreads()
         forYouThreads = threadsStore.getForYouThreads()
            followingThreads = threadsStore.getFollowingThreads()
    }
   
    
}
    

    extension threadsViewController: UICollectionViewDataSource {

        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
               switch selectedSegment {
               case .forYou:
                   return forYouThreads.count
               case .following:
                   return followingThreads.count
               case .myThreads:
                   return threadsStore.getMyThreads().count
               }
           }

           func collectionView(
               _ collectionView: UICollectionView,
               cellForItemAt indexPath: IndexPath
           ) -> UICollectionViewCell {

               let cell = collectionView.dequeueReusableCell(
                   withReuseIdentifier: "collectionViewCell",
                   for: indexPath
               ) as! collectionViewCell

               let post: ThreadPost
               switch selectedSegment {
               case .forYou:
                   post = forYouThreads[indexPath.item]
               case .following:
                   post = followingThreads[indexPath.item]
               case .myThreads:
                   post = threadsStore.getMyThreads()[indexPath.item]
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

        func collectionView(
               _ collectionView: UICollectionView,
               layout collectionViewLayout: UICollectionViewLayout,
               referenceSizeForHeaderInSection section: Int
           ) -> CGSize {

               if selectedSegment == .myThreads {
                   return CGSize(width: collectionView.frame.width, height: 120)
               }

               return .zero
           }

           func collectionView(
               _ collectionView: UICollectionView,
               layout collectionViewLayout: UICollectionViewLayout,
               sizeForItemAt indexPath: IndexPath
           ) -> CGSize {

               return CGSize(width: collectionView.frame.width - 32,
                             height: 520)           }
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
                post = forYouThreads[indexPath.item]
            }

            let detailVC = ThreadDetailViewController()
            detailVC.thread = post
            navigationController?.pushViewController(detailVC, animated: true)
        }
}
