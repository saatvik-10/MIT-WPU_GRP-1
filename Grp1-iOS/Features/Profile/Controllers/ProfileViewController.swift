import UIKit

class ProfileViewController: UIViewController, ProfileOptionCellDelegate {
    
    @IBOutlet weak var profileLevel: UILabel!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let sections = ProfileDataSource.sections
    private var profileData: APIProfileResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchProfile()
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

    private func performLogout() {
    // 1. Call your existing AuthenticationService
    AuthenticationService.shared.signOut { [weak self] success in
        guard success else {
            print("Error signing out.")
            return
        }
        
        // 2. Redirect to the Authentication Storyboard
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Authentication", bundle: nil)
            if let authVC = storyboard.instantiateInitialViewController(),
               let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                
                // Swap out the root view controller
                window.rootViewController = authVC
                
                // Add a smooth fade animation
                UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
            }
        }
    }
    }
    
    private func fetchProfile() {
        guard let token = SessionManager.shared.authToken else {
            setupProfileHeader()
            return
        }
        
        APIService.shared.fetchProfile(token: token) { [weak self] result in
            switch result {
            case .success(let profile):
                self?.profileData = profile
                self?.setupProfileHeader()
            case .failure:
                self?.setupProfileHeader()
            }
        }
    }
    
    func setupProfileHeader() {
        profileBtn.layer.cornerRadius = profileBtn.bounds.height / 2
        profileBtn.clipsToBounds = true
        
        if let profile = profileData {
            profileName.text = profile.name
            let level = profile.username
            profileLevel.text = level
            
            
            if let urlString = profile.profileImageUrl, let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                    guard let data = data, let image = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        self?.profileBtn.setImage(nil, for: .normal)
                        self?.profileBtn.setBackgroundImage(image, for: .normal)
                    }
                }.resume()
            }
        } else {
            let user = User.current
            profileName.text = user.name
            profileLevel.text = user.level.rawValue
            profileLevel.textColor = user.level.color
        }
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(100)
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
            performLogout()
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
        } else if case .bookmarks = sectionType  {
            performSegue(withIdentifier: "bookmarksSegue", sender: self)
        } else if case .about = sectionType {
            print("About us Tapped")
//            performSegue(withIdentifier: "aboutSegue", sender: self)
        } else {
            print("Logout tapped")
            performLogout()
//            performSegue(withIdentifier: "logoutSegue", sender: self)
        }
    }
}

extension ProfileSection {
    
    var title: String {
        switch self {
        case .progress: return "Progress"
        case .interests: return "Interests"
        case .bookmarks: return "Bookmarks"
        case .about: return "About Us"
        case .logout: return "Logout"
        }
    }
    
    var isDestructive: Bool {
        if case .logout = self { return true }
        return false
    }
}
