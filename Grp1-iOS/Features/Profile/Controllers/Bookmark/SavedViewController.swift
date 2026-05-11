import UIKit

class SavedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    var folderName: String = ""
    var segment: BookmarkSegment = .articles
    
    private var articles: [SavedArticle] = []
    private var threads: [APIThread] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = folderName
        view.backgroundColor = .systemGray6

        if segment == .articles {
            articles = SavedArticlesStore.shared.articles(in: folderName)
        } else {
            threads = SavedThreadsStore.shared.fetchBookmarkedThreads(in: folderName)
        }

        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh data on appear
        if segment == .articles {
            articles = SavedArticlesStore.shared.articles(in: folderName)
        } else {
            threads = SavedThreadsStore.shared.fetchBookmarkedThreads(in: folderName)
        }
        collectionView.reloadData()
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemGray6

        if segment == .articles {
            collectionView.register(
                UINib(nibName: "TrendingCollectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "trending_cell"
            )
        } else {
            collectionView.register(
                UINib(nibName: "collectionViewCell", bundle: nil),
                forCellWithReuseIdentifier: "collectionViewCell"
            )
        }

        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }

    private func generateLayout() -> UICollectionViewLayout {
        if segment == .articles {
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 15, trailing: 10)

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(320)
                ),
                subitems: [item]
            )

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0)

            return UICollectionViewCompositionalLayout(section: section)
        } else {
            // Layout for Threads
            return UICollectionViewCompositionalLayout { sectionIndex, _ in
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(200)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(200)
                )
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
                section.interGroupSpacing = 16
                return section
            }
        }
    }

    // MARK: - DataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return segment == .articles ? articles.count : threads.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        if segment == .articles {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "trending_cell",
                for: indexPath
            ) as! TrendingCollectionViewCell

            let saved = articles[indexPath.row]

            // Convert SavedArticle → NewsArticle for cell config
            let article = NewsArticle(
                id: saved.id,
                title: saved.title,
                description: saved.description,
                imageName: saved.imageName,
                category: saved.category,
                date: saved.date,
                source: saved.source,
                overview: saved.overview,
                keyTakeaways: saved.keyTakeaways,
                jargons: saved.jargons,
                selectedJargon: saved.selectedJargon,
                bodyText: ""
            )

            cell.configureCell(with: article)
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "collectionViewCell",
                for: indexPath
            ) as! collectionViewCell
            
            let thread = threads[indexPath.row]
            let currentUserId = UserDefaults.standard.string(forKey: "userId")
            let isOwnPost = thread.userId == currentUserId
            
            cell.isBookmarked = true   // always true — we're inside a bookmark folder
            cell.configure(with: thread, isFollowing: false, isOwnPost: isOwnPost)
            cell.applyStyle(isCard: true)
            
            // Unsave from this folder when toggle tapped
            cell.onBookmarkTapped = { [weak self] in
                guard let self else { return }
                SavedThreadsStore.shared.removeThreadBookmark(thread.id, from: self.folderName)
                self.threads = SavedThreadsStore.shared.fetchBookmarkedThreads(in: self.folderName)
                self.collectionView.reloadData()
                self.showToast(message: "Removed from \(self.folderName)")
            }
            
            return cell
        }
    }

    // MARK: - Navigation

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        if segment == .articles {
            let saved = articles[indexPath.row]

            let article = NewsArticle(
                id: saved.id,
                title: saved.title,
                description: saved.description,
                imageName: saved.imageName,
                category: saved.category,
                date: saved.date,
                source: saved.source,
                overview: saved.overview,
                keyTakeaways: saved.keyTakeaways,
                jargons: saved.jargons,
                selectedJargon: saved.selectedJargon,
                bodyText: ""
            )

            let storyboard = UIStoryboard(name: "HomeMain", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "news1ViewController") as? news1ViewController {
                vc.article = article
                navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            let thread = threads[indexPath.row]
            let detailVC = ThreadDetailViewController()
            detailVC.thread = thread
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}
