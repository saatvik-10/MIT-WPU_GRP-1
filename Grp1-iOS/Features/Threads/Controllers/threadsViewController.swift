import UIKit

enum ThreadsSegment {
    case forYou
    case following
    case myThreads
}

class threadsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    let threadsStore = ThreadsDataStore.shared

    private var forYouThreads: [ThreadPost] = []
    private var followingThreads: [ThreadPost] = []

    private var selectedSegment: ThreadsSegment = .forYou

    override func viewDidLoad() {
        super.viewDidLoad()

        forYouThreads = threadsStore.getAllThreads()
        followingThreads = threadsStore.getAllThreads()  // mock for now

        setupCollectionView()

        let bg = UIColor(white: 250 / 255, alpha: 1)
        view.backgroundColor = bg
        collectionView.backgroundColor = bg
    }

    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self

        // Feed cell
        let cellNib = UINib(nibName: "collectionViewCell", bundle: nil)
        collectionView.register(
            cellNib,
            forCellWithReuseIdentifier: "collectionViewCell"
        )
        
        collectionView.register(
                    UINib(nibName: "MyThreadsGridCollectionViewCell", bundle: nil),
                    forCellWithReuseIdentifier: "MyThreadsGridCollectionViewCell"
                )
        // Header
        let headerNib = UINib(
            nibName: "ThreadsHeaderCollectionReusableView",
            bundle: nil
        )
        collectionView.register(
            headerNib,
            forSupplementaryViewOfKind: UICollectionView
                .elementKindSectionHeader,
            withReuseIdentifier: "ThreadsHeaderCollectionReusableView"
        )
        // My Threads profile header
        let profileHeaderNib = UINib(
            nibName: "MyThreadsProfileHeaderCollectionReusableView",
            bundle: nil
        )
        collectionView.register(
            profileHeaderNib,
            forSupplementaryViewOfKind: UICollectionView
                .elementKindSectionHeader,
            withReuseIdentifier: "MyThreadsProfileHeaderCollectionReusableView"
        )
        if let layout = collectionView.collectionViewLayout
            as? UICollectionViewFlowLayout
        {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 20
            //change1
            layout.minimumInteritemSpacing = 12
            layout.sectionInset = UIEdgeInsets(
                top: 12,
                left: 16,   //0
                bottom: 24,   //20
                right: 16    //16
            )

            // CRITICAL FIX
            layout.estimatedItemSize = .zero
            // layout.headerReferenceSize = CGSize(width: view.frame.width, height: 100)
        }
    }

    // MARK: - Segment Change
    func didChangeSegment(index: Int) {
        switch index {
        case 0:
            selectedSegment = .forYou
        case 1:
            selectedSegment = .following
        case 2:
            selectedSegment = .myThreads
        default:
            selectedSegment = .forYou
        }

        collectionView.setContentOffset(.zero, animated: false)
        collectionView.reloadData()
    }

    // MARK: - Popover
//    private func presentThreadOptions(
//        from sourceView: UIView,
//        for post: ThreadPost
//    ) {
//        let vc = ThreadsOptionViewController()
//        vc.modalPresentationStyle = .popover
//
//        guard let popover = vc.popoverPresentationController else { return }
//        popover.sourceView = sourceView
//        popover.sourceRect = sourceView.bounds
//        popover.permittedArrowDirections = [.up, .down]
//        popover.backgroundColor = .clear
//        popover.delegate = self
//
//        present(vc, animated: true)
//    }
    private func presentThreadOptions(from sourceView: UIView) {
            let vc = ThreadsOptionViewController()
            vc.modalPresentationStyle = .popover

            guard let popover = vc.popoverPresentationController else { return }
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
            popover.permittedArrowDirections = [.up, .down]
            popover.backgroundColor = .clear
            popover.delegate = self

            present(vc, animated: true)
        }
}

// MARK: - CollectionView DataSource
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

           // MY THREADS GRID
           if selectedSegment == .myThreads {
               let cell = collectionView.dequeueReusableCell(
                   withReuseIdentifier: "MyThreadsGridCollectionViewCell",
                   for: indexPath
               ) as! MyThreadsGridCollectionViewCell

               let post = forYouThreads[indexPath.item]
               cell.configure(imageName: post.imageName)
               return cell
           }

           // FEED CELL (UNCHANGED)
           let cell = collectionView.dequeueReusableCell(
               withReuseIdentifier: "collectionViewCell",
               for: indexPath
           ) as! collectionViewCell

           let post = selectedSegment == .forYou
               ? forYouThreads[indexPath.item]
               : followingThreads[indexPath.item]

           cell.configure(with: post)

           cell.onMoreTapped = { [weak self, weak cell] in
               guard let button = cell?.moreButton else { return }
               self?.presentThreadOptions(from: button)
           }

           return cell
       }

       // MARK: - Headers
       func collectionView(
           _ collectionView: UICollectionView,
           viewForSupplementaryElementOfKind kind: String,
           at indexPath: IndexPath
       ) -> UICollectionReusableView {

           if indexPath.section == 0 {
               let header = collectionView.dequeueReusableSupplementaryView(
                   ofKind: kind,
                   withReuseIdentifier: "ThreadsHeaderCollectionReusableView",
                   for: indexPath
               ) as! ThreadsHeaderCollectionReusableView

               header.onSegmentChanged = { [weak self] index in
                   self?.didChangeSegment(index: index)
               }

               return header
           }

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
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {

        if selectedSegment == .myThreads {
                    let width = (collectionView.frame.width - 16*2 - 12) / 2
                    return CGSize(width: width, height: width)
                }

                // FEED CELL — DO NOT TOUCH
                return CGSize(width: collectionView.frame.width, height: 520)
            }
    
    func collectionView(
            _ collectionView: UICollectionView,
            layout collectionViewLayout: UICollectionViewLayout,
            referenceSizeForHeaderInSection section: Int
        ) -> CGSize {

            if section == 0 {
                return CGSize(width: collectionView.frame.width, height: 100)
            }

            // Profile header
            return CGSize(width: collectionView.frame.width, height: 140)
        }

}

// MARK: - Popover Delegate
extension threadsViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(
        for controller: UIPresentationController
    ) -> UIModalPresentationStyle {
        return .none
    }
}
