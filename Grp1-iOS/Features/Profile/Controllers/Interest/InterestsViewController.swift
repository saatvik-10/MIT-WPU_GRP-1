import UIKit

class InterestsViewController: UIViewController {

    @IBOutlet weak var segmented: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!

    let domains = InterestsDataSource.domains
//    let companies = InterestsDataSource.companies
    let preferences = InterestsDataSource.preferences

    var currentItems: [InterestModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        currentItems = domains
        setupSegmented()
        setupCollectionView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let navController = segue.destination as? UINavigationController,
           let vc = navController.viewControllers.first as? AddInterestViewController {
            
            vc.interestType = (segmented.selectedSegmentIndex == 0) ? .domain : .preference
            vc.sourceItems = (segmented.selectedSegmentIndex == 0) ? domains : preferences
        }
    }
}

// MARK: - Setup segmented + collectionview
extension InterestsViewController {
    
    private func setupSegmented() {
        segmented.removeAllSegments()
        segmented.insertSegment(withTitle: "Domains", at: 0, animated: false)
//        segmented.insertSegment(withTitle: "Companies", at: 1, animated: false)
        segmented.insertSegment(withTitle: "Preferences", at: 1, animated: false)
        segmented.selectedSegmentIndex = 0
        segmented.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)

        collectionView.register(
            UINib(nibName: "DomainViewCell", bundle: nil),
            forCellWithReuseIdentifier: "DomainViewCell"
        )
//        collectionView.register(
//            UINib(nibName: "CompaniesViewCell", bundle: nil),
//            forCellWithReuseIdentifier: "CompaniesViewCell"
//        )
        collectionView.register(
            UINib(nibName: "PreferencesViewCell", bundle: nil),
            forCellWithReuseIdentifier: "PreferencesViewCell"
        )
    }

    @objc private func segmentChanged() {
        currentItems = (segmented.selectedSegmentIndex == 0) ? domains : preferences
        collectionView.reloadData()
    }
}

// MARK: - CollectionView datasource & delegate
extension InterestsViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return currentItems.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let model = currentItems[indexPath.row]

        if segmented.selectedSegmentIndex == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "DomainViewCell",
                for: indexPath
            ) as! DomainViewCell
            cell.configure(model)
            return cell
        } else {
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "CompaniesViewCell",
//                for: indexPath
//            ) as! CompaniesViewCell
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "PreferencesViewCell",
                for: indexPath
            ) as! PreferencesViewCell
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
            heightDimension: .absolute(160)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(300)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            repeatingSubitem: item,
            count: 2
        )

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 20, trailing: 10)

        return UICollectionViewCompositionalLayout(section: section)
    }
}
