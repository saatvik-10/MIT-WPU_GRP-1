import UIKit

class SavedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    var folderName: String = ""
    private var articles: [SavedArticle] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = folderName
        view.backgroundColor = .systemGray6

        articles = SavedArticlesStore.shared.articles(in: folderName)

        setupCollectionView()
        
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemGray6

        collectionView.register(
            UINib(nibName: "TrendingCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "trending_cell"
        )

        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }

    private func generateLayout() -> UICollectionViewLayout {
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
    }

    // MARK: - DataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return articles.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

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
    }

    // MARK: - Navigation

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
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
    }
}
