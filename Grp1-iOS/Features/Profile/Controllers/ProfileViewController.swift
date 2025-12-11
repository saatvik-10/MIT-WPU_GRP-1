import UIKit

// MARK: - Main View Controller
// 1. Adopt the ProfileOptionCellDelegate protocol
class ProfileViewController: UIViewController, ProfileOptionCellDelegate {

    @IBOutlet weak var profileLevel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let items = ProfileDataSource.items

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupProfileHeader()

        collectionView.dataSource = self
        // Note: We only need dataSource for data. Delegate logic is handled by the protocol now.
        // We can safely keep collectionView.delegate = self, but it is no longer mandatory
        // for the selection, only for other CollectionView delegate methods if used.
        collectionView.delegate = self
        
        collectionView.backgroundColor = UIColor.systemGray6

        // Register XIBs/NIBs
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
    
    func setupProfileHeader() {
        let profileData = Profile.current

        profileName.text = profileData.name
        profileLevel.text = profileData.level.rawValue
        profileLevel.textColor = profileData.level.color

        let imageName = profileData.image
        if !imageName.isEmpty {
            profileImage.image = UIImage(named: imageName)
            profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
            profileImage.clipsToBounds = true
        } else {
            profileImage.image = UIImage(systemName: "person")
        }
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

//---

// MARK: - UICollectionViewDataSource & Delegate
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
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "progress_cell", for: indexPath
            ) as? ProfileOptionViewCell else { return UICollectionViewCell() }
            
            cell.configure(title: item.title, level: 2, progress: 0.6)
            return cell

        case .option:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "option_cell", for: indexPath
            ) as? ProfileOption2ViewCell else { return UICollectionViewCell() }
            
            // 2. Set the delegate to self (the View Controller)
            cell.delegate = self
            
            cell.configure(title: item.title, isDestructive: item.isDestructive)
            return cell
        }
    }
}
// MARK: - ProfileOptionCellDelegate (The Navigation Trigger)
extension ProfileViewController {
    func didTapOption(for cell: ProfileOption2ViewCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let item = items[indexPath.row]
        
        switch item.title {
        case "Interests":
            guard let storyboard = self.storyboard else { return }
            guard let interestsVC = storyboard.instantiateViewController(withIdentifier: "InterestsViewController") as? InterestsViewController else {
                print("❌ Instantiation Error: Check Storyboard ID 'InterestsViewController'.")
                return
            }
            navigationController?.pushViewController(interestsVC, animated: true)
            
        case "Bookmarks":
            print("Navigating to Bookmarks...")
            guard let storyboard = self.storyboard else { return }
            guard let bookmarksVC = storyboard.instantiateViewController(withIdentifier: "BookmarkViewController") as? BookmarkViewController else {
                print("❌ Instantiation Error: Check Storyboard ID 'BookmarkViewController'.")
                return
            }
            navigationController?.pushViewController(bookmarksVC, animated: true)
            
        case "Achievements":
            print("Navigating to Achievements...")
            // TODO: Add navigation logic for Achievements
            break
            
        case "Logout":
            print("Logging out...")
            // TODO: Add logout action/alert
            break

        default:
            break
        }
    }
}
