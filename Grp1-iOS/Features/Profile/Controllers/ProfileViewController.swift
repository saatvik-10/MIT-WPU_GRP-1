import UIKit

class ProfileViewController: UIViewController, ProfileOptionCellDelegate {
    
    @IBOutlet weak var profileLevel: UILabel!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let items = ProfileDataSource.items
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setupProfileHeader()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = UIColor.systemGray6
        
        collectionView.register(
            UINib(nibName: "ProfileOption2ViewCell", bundle: nil),
            forCellWithReuseIdentifier: "option_cell"
        )
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            setupProfileHeader()
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editProfileSegue",
           let editVC = segue.destination as? EditProfileViewController {

            editVC.onProfileUpdated = { [weak self] in
                self?.setupProfileHeader()
            }
        }
    }
    
    func setupProfileHeader() {
        let user = User.current

        profileName.text = user.name
        profileLevel.text = user.level.rawValue
        profileLevel.textColor = user.level.color
        profileBtn.layer.cornerRadius = profileBtn.bounds.height / 2
        profileBtn.clipsToBounds = true
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

// MARK: - UICollectionViewDataSource & Delegate
extension ProfileViewController:
    UICollectionViewDataSource,
    UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ : UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let item = items[indexPath.row]
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "option_cell", for: indexPath
        ) as? ProfileOption2ViewCell else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        cell.configure(title: item.title, subTitle: item.subTitle, isDestructive: item.isDestructive)
        return cell
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
                print("Storyboard ID err")
                return
            }
            navigationController?.pushViewController(interestsVC, animated: true)
            
        case "Bookmarks":
            print("Navigating to Bookmarks...")
            guard let storyboard = self.storyboard else { return }
            guard let bookmarksVC = storyboard.instantiateViewController(withIdentifier: "BookmarkViewController") as? BookmarkViewController else {
                print("Storyboard ID err")
                return
            }
            navigationController?.pushViewController(bookmarksVC, animated: true)
            
        case "Achievements":
            print("Navigating to Achievements...")
            // TODO: Achievements
            break
            
        case "About us":
            print("About us...")
            // TODO: About us
            break
            
        case "Logout":
            print("Logging out...")
            // TODO: Logout
            break
            
        default:
            break
        }
    }
}
