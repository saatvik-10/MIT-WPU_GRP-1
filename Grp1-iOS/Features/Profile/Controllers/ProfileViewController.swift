import UIKit

class ProfileViewController: UIViewController, ProfileOptionCellDelegate {
    
    @IBOutlet weak var profileLevel: UILabel!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let sections = ProfileDataSource.sections
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupProfileHeader()
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.systemGray6
        
        collectionView.register(UINib(nibName: "ProgressViewCell", bundle: nil), forCellWithReuseIdentifier: "progress_cell")
        collectionView.register(UINib(nibName: "InterestsViewCell", bundle: nil), forCellWithReuseIdentifier: "interests_cell")
        collectionView.register(UINib(nibName: "BookmarksViewCell", bundle: nil), forCellWithReuseIdentifier: "bookmarks_cell")
        collectionView.register(UINib(nibName: "ProfileOption2ViewCell", bundle: nil), forCellWithReuseIdentifier: "option_cell")
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
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
            heightDimension: .estimated(75)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = sections[indexPath.row]
        
        switch sectionType {
        case .progress(let data):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "progress_cell", for: indexPath) as! ProgressViewCell
            cell.configure(
                level: data.progressLevel,
                progressValue: Float(data.progressPercentage)
            )
            return cell
            
        case .interests(let data):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "interests_cell", for: indexPath) as! InterestsViewCell
            cell.configure(interests: data.interests)
            return cell
            
        case .bookmarks(let data):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bookmarks_cell", for: indexPath) as! BookmarksViewCell
            cell.configure(folders: data.totalFolders, bookmarks: data.totalBookmarks)
            
            return cell
            
        case .about, .logout:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "option_cell", for: indexPath) as! ProfileOption2ViewCell
            cell.delegate = self
            cell.configure(title: sectionType.title, isDestructive: sectionType.isDestructive)
            return cell
        }
    }
}

extension ProfileViewController {
    func didTapOption(for cell: ProfileOption2ViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let sectionType = sections[indexPath.row]
        
        switch sectionType {
        case .about:
            print("About us Tapped")
        case .logout:
            print("Logout tapped")
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionType = sections[indexPath.row]
        
        if case .progress = sectionType {
            performSegue(withIdentifier: "progressSegue", sender: self)
        } else if case .interests = sectionType {
            performSegue(withIdentifier: "interestsSegue", sender: self)
        } else {
            performSegue(withIdentifier: "bookmarksSegue", sender: self)
        }
    }
}
