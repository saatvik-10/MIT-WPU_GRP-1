import UIKit

enum ThreadsSegment {
    case forYou
    case following
    case myThreads
}

class threadsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        didChangeSegment(index: sender.selectedSegmentIndex)
    }
    
    
    @IBAction func didTapSearchButton(_ sender: UIBarButtonItem) {
        print("Search tapped")
    }
    
    @IBAction func didTapPlusButton(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showCreatePost", sender: nil)
    }
    
    private let threadsStore = ThreadsDataStore.shared

        private var forYouThreads: [ThreadPost] = []
        private var followingThreads: [ThreadPost] = []

        private var selectedSegment: ThreadsSegment = .forYou

        override func viewDidLoad() {
            
            super.viewDidLoad()
            
            collectionView.delegate = self
            collectionView.dataSource = self
            segmentControl.selectedSegmentIndex = 0
//            forYouThreads = threadsStore.getAllThreads()
//            followingThreads = threadsStore.getFollowingThreads()
            //navigationItem.title = "Threads"
            setupCollectionView()
            reloadData()
            

            let bg = UIColor(white: 250/255, alpha: 1)
            view.backgroundColor = bg
            collectionView.backgroundColor = bg
        }
     
    private func reloadData() {
           forYouThreads = threadsStore.getAllThreads()
           followingThreads = threadsStore.getFollowingThreads()
       }
    
        private func setupCollectionView() {
            collectionView.delegate = self
            collectionView.dataSource = self

            // Feed cell
            collectionView.register(
                UINib(nibName: "collectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "collectionViewCell"
            )

            // Grid cell
            collectionView.register(
                UINib(nibName: "MyThreadsGridCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "MyThreadsGridCollectionViewCell"
            )

//            // Threads header
//            collectionView.register(
//                UINib(nibName: "ThreadsHeaderCollectionReusableView", bundle: nil),
//                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                withReuseIdentifier: "ThreadsHeaderCollectionReusableView"
//            )

            // Profile header
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

        // MARK: - Segment Change
        func didChangeSegment(index: Int) {
            switch index {
            case 0: selectedSegment = .forYou
            case 1: selectedSegment = .following
            case 2: selectedSegment = .myThreads
            default: break
            }

            reloadData()
            collectionView.setContentOffset(.zero, animated: false)
            collectionView.reloadData()
        }

//        // MARK: - Popover (RESTORED)
//        private func presentThreadOptions(from sourceView: UIView) {
//            let optionsVC = ThreadsOptionViewController()
//            optionsVC.modalPresentationStyle = .popover
//            optionsVC.preferredContentSize = CGSize(width: 260, height: 220)
//
//            guard let popover = optionsVC.popoverPresentationController else { return }
//            popover.sourceView = sourceView
//            popover.sourceRect = sourceView.bounds
//            popover.permittedArrowDirections = [.up, .down]
//            popover.backgroundColor = .clear
//            popover.delegate = self
//
//            present(optionsVC, animated: true)
//        }
    }

    // MARK: - DataSource
    extension threadsViewController: UICollectionViewDataSource {

        func numberOfSections(in collectionView: UICollectionView) -> Int {
            return selectedSegment == .myThreads ? 2 : 1
        }

        func collectionView(
            _ collectionView: UICollectionView,
            numberOfItemsInSection section: Int
        ) -> Int {

            if selectedSegment == .myThreads {
                return section == 1 ? forYouThreads.count : 0
            }

            switch selectedSegment {
            case .forYou:
                return forYouThreads.count
            case .following:
                return followingThreads.count
            case .myThreads:
                return 0
            }
        }

        func collectionView(
            _ collectionView: UICollectionView,
            cellForItemAt indexPath: IndexPath
        ) -> UICollectionViewCell {

            // GRID (My Threads)
            if selectedSegment == .myThreads && indexPath.section == 1 {
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: "MyThreadsGridCollectionViewCell",
                    for: indexPath
                ) as! MyThreadsGridCollectionViewCell

                let post = forYouThreads[indexPath.item]
                cell.configure(imageName: post.imageName)
                return cell
            }

            // FEED (For You / Following)
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "collectionViewCell",
                for: indexPath
            ) as! collectionViewCell

            let post = selectedSegment == .forYou
                ? forYouThreads[indexPath.item]
                : followingThreads[indexPath.item]

            cell.configure(with: post)
            
            //LIKE
            cell.onLikeTapped = { [weak self] in
                        guard let self else { return }

                        threadsStore.toggleLike(for: post.id)
                        self.reloadData()
                        self.collectionView.reloadItems(at: [indexPath])
                    }
            // POPOVER
//            cell.onMoreTapped = { [weak self, weak cell] in
//                guard let button = cell?.moreButton else { return }
//                self?.presentThreadOptions(from: button)
//            }

            return cell
        }

        // MARK: - Headers
        func collectionView(
            _ collectionView: UICollectionView,
            viewForSupplementaryElementOfKind kind: String,
            at indexPath: IndexPath
        ) -> UICollectionReusableView {

            // Main Threads header (always section 0)
//            if indexPath.section == 0 {
//                let header = collectionView.dequeueReusableSupplementaryView(
//                    ofKind: kind,
//                    withReuseIdentifier: "ThreadsHeaderCollectionReusableView",
//                    for: indexPath
//                ) as! ThreadsHeaderCollectionReusableView
//
//                header.onSegmentChanged = { [weak self] index in
//                    self?.didChangeSegment(index: index)
//                }
//
//                return header
//            }

            // Profile header (My Threads only)
            let profileHeader = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: "MyThreadsProfileHeaderCollectionReusableView",
                for: indexPath
            ) as! MyThreadsProfileHeaderCollectionReusableView

            profileHeader.configure(
                userName: "Anandita Babar",
                profileImage: "beach_1",
                posts: 5,
                followers: 345,
                following: 45
            )

            return profileHeader
        }
    }

    // MARK: - Layout
    extension threadsViewController: UICollectionViewDelegateFlowLayout {

        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            referenceSizeForHeaderInSection section: Int
        ) -> CGSize {
            if section == 0 {
                return .zero
            }
            if selectedSegment == .myThreads && section == 1 {
                return CGSize(width: collectionView.frame.width, height: 120)
            }

            return CGSize(width: collectionView.frame.width, height: 100)
        }

        func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            sizeForItemAt indexPath: IndexPath
        ) -> CGSize {

            // Grid — 3 columns
            if selectedSegment == .myThreads {
                let spacing: CGFloat = 4
                let width = (collectionView.frame.width - 16*2 - spacing*2) / 3
                return CGSize(width: width, height: width * 1.4)
            }

            // Feed — unchanged
            return CGSize(width: collectionView.frame.width, height: 520)
        }
    

//    // MARK: - Popover Delegate
//    extension threadsViewController: UIPopoverPresentationControllerDelegate {
//        func adaptivePresentationStyle(
//            for controller: UIPresentationController
//        ) -> UIModalPresentationStyle {
//            return .none
//        }
    }

extension threadsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                            didSelectItemAt indexPath: IndexPath) {

            let selectedThread: ThreadPost

            switch selectedSegment {

            case .forYou:
                selectedThread = forYouThreads[indexPath.item]

            case .following:
                selectedThread = followingThreads[indexPath.item]

            case .myThreads:
                // Only allow tap on grid items (section 1)
                guard indexPath.section == 1 else { return }
                selectedThread = forYouThreads[indexPath.item]
            }

            let detailVC = ThreadDetailViewController()
            detailVC.thread = selectedThread

            navigationController?.pushViewController(detailVC, animated: true)
        }

}
