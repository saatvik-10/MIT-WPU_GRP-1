import UIKit

class InterestsViewController: UIViewController {

    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!

    let domains = InterestsDataSource.domains
    let companies = InterestsDataSource.companies

    var currentItems: [InterestModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        currentItems = domains
        setupSegmented()
        setupCollectionView()
    }
}


// MARK: - Setup segmented + collectionview
extension InterestsViewController {

    private func setupSegmented() {
        segmented.removeAllSegments()
        segmented.insertSegment(withTitle: "Domains", at: 0, animated: false)
        segmented.insertSegment(withTitle: "Companies", at: 1, animated: false)
        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)

        // register both XIB cells
        collectionView.register(
            UINib(nibName: "DomainViewCell", bundle: nil),
            forCellWithReuseIdentifier: "DomainViewCell"
        )
        collectionView.register(
            UINib(nibName: "CompaniesViewCell", bundle: nil),
            forCellWithReuseIdentifier: "CompaniesViewCell"
        )
    }

    @objc private func segmentChanged() {
        currentItems = (segmented.selectedSegmentIndex == 0) ? domains : companies
        collectionView.reloadData()
    }
}


// MARK: - CollectionView datasource
extension InterestsViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return currentItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let model = currentItems[indexPath.row]

        if segmented.selectedSegmentIndex == 0 {
            // DOMAIN CELL
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DomainViewCell",
                for: indexPath
            ) as! DomainViewCell
            cell.configure(model)
            return cell
        } else {
            // COMPANIES CELL
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "CompaniesViewCell",
                for: indexPath
            ) as! CompaniesViewCell
            cell.configure(model)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        print("Tapped → \(currentItems[indexPath.row].title)")
    }
}


// MARK: - Compositional Layout
extension InterestsViewController {
    func generateLayout() -> UICollectionViewLayout {

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(95)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 2
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)

        return UICollectionViewCompositionalLayout(section: section)
    }
}
