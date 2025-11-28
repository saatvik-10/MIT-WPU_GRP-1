import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    let items = ProfileDataSource.items

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = UIColor.systemGray6

        // register xibs
        collectionView.register(
            UINib(nibName: "ProfileOptionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "progress_cell"
        )
        collectionView.register(
            UINib(nibName: "ProfileOption2ViewCell", bundle: nil),
            forCellWithReuseIdentifier: "option_cell"
        )

        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }

    func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(75)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(500)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitems: [item]
        )

        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = 12
        
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 20,
            leading: 20,
            bottom: 20,
            trailing: 20
        )

        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension ProfileViewController:
    UICollectionViewDataSource,
    UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let item = items[indexPath.row]

        switch item.cellType {
        case .progress:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "progress_cell", for: indexPath
            ) as! ProfileOptionViewCell
            cell.configure(title: item.title, level: 2, progress: 0.6)
            return cell

        case .option:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "option_cell", for: indexPath
            ) as! ProfileOption2ViewCell
            cell.configure(title: item.title, isDestructive: item.isDestructive)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Tapped → \(items[indexPath.row].title)")
    }
}
