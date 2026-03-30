import UIKit

class ProfileViewController: UIViewController, ProfileOptionCellDelegate {
    
    @IBOutlet weak var profileLevel: UILabel!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var profileImage: UIImageView!
    let sections = ProfileDataSource.sections
    private var profileData: APIProfileResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the main view background to match your header color
        view.backgroundColor = UIColor.systemBackground
        
        setupCardBackground()
        setupCollectionView()
        setupCardBackground()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        fetchProfile()
    }
    
    private func setupBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemBlue.withAlphaComponent(0.08).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.frame = view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    // ─────────────────────────────────────────────
    // MARK: - Card Background
    // ─────────────────────────────────────────────
    
    private func setupCardBackground() {
        let cardView = UIView()
        cardView.backgroundColor = UIColor.systemGray6
        cardView.layer.cornerRadius = 30
        cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] // top-left, top-right
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        // Insert behind collectionView
        view.insertSubview(cardView, belowSubview: collectionView)
        
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // Align top of card with top of collectionView
            cardView.topAnchor.constraint(equalTo: collectionView.topAnchor, constant: -10)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear  // ← transparent so card shows through
        
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
                        self?.applyProfileBackgroundImage(image)

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
    
    private func applyProfileBackgroundImage(_ image: UIImage) {
        profileImage.image = image
        profileImage.contentMode = .scaleAspectFill
        profileImage.clipsToBounds = true
        profileImage.alpha = 0.35  // ✅ more visible
        
        view.sendSubviewToBack(profileImage)
        view.viewWithTag(998)?.removeFromSuperview()
        
        // ✅ Extract dominant color
        let dominant = dominantColor(from: image) ?? UIColor.systemBlue
        
        let gradientView = UIView()
        gradientView.tag = 998
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(gradientView, aboveSubview: profileImage)
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: profileImage.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: profileImage.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: profileImage.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: profileImage.bottomAnchor)
        ])
        
        DispatchQueue.main.async {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [
                UIColor.clear.cgColor,
                dominant.withAlphaComponent(0.25).cgColor,   // ✅ dominant color mid
                UIColor.systemBackground.cgColor
            ]
            gradientLayer.locations = [0.0, 0.5, 1.0]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            gradientLayer.frame = gradientView.bounds
            gradientView.layer.addSublayer(gradientLayer)
        }
    }

    private func dominantColor(from image: UIImage) -> UIColor? {
        guard let inputImage = CIImage(image: image) else { return nil }
        
        let extent = inputImage.extent
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        
        guard let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [
                kCIInputImageKey: inputImage,
                kCIInputExtentKey: CIVector(cgRect: extent)
            ]) else { return nil }
        
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )
        
        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: 1
        )
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environment in
            guard let self = self else { return nil }

            var groupItems: [NSCollectionLayoutItem] = []
            var totalHeight: CGFloat = 0

            for (index, sectionType) in self.sections.enumerated() {
                let cellHeight: CGFloat
                switch sectionType {
                case .progress:       cellHeight = 200
                case .interests:      cellHeight = 100
                case .bookmarks:      cellHeight = 80
                case .about, .logout: cellHeight = 60
                }

                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(cellHeight)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                groupItems.append(item)
                totalHeight += cellHeight + (index > 0 ? 12 : 0)
            }

            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(totalHeight)
            )

            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: groupItems  // ✅ pass the full array, each with its own absolute height
            )
            group.interItemSpacing = .fixed(12)

            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)

            return section
        }
        return layout
    }}

extension ProfileViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = sections[indexPath.row]
        
        switch sectionType {
        case .progress(let data):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "progress_cell", for: indexPath) as! ProgressViewCell
            cell.configure(streakCount: 7)  // pass real streak value from your data
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
        
//        if case .progress = sectionType {
//            performSegue(withIdentifier: "progressSegue", sender: self)
//        }
        if case .interests = sectionType {
            performSegue(withIdentifier: "interestsSegue", sender: self)
        } else if case .bookmarks = sectionType  {
            performSegue(withIdentifier: "bookmarksSegue", sender: self)
        } else if case .about = sectionType {
            print("About us Tapped")
//            performSegue(withIdentifier: "aboutSegue", sender: self)
        } else if case .logout = sectionType {
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
