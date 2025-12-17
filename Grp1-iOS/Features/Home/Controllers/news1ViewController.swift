import UIKit

class news1ViewController: UIViewController, UICollectionViewDataSource {
    
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var floatingButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    private var didSetupJargons = false

    var selectedJargon: String?
    @IBOutlet weak var optionsButton: UIBarButtonItem!
    @IBOutlet weak var glassView: UIView!
    //    @IBOutlet weak var collectionView: UICollectionView!
    //    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var overviewView: UIView!
    @IBOutlet weak var gradientImageView: UIImageView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var overviewTextLabel: UILabel!
    
    var passedDominantColor: UIColor = .systemBackground
    let newsStore = NewsDataStore.shared
    var relatedNews: [NewsArticle] = []     // for "More Like This"
    var qaHistory: [ArticleQA] = []         // for "Questions Asked"
    
    var article: NewsArticle?               // set from previous screen
    
    private var gradientApplied = false
    var extractedDominantColor: UIColor?
    var dominantColor: UIColor?
    // in news1ViewController
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        // --- Your original overview text ---
        overviewTextLabel.numberOfLines = 0
        if let points = article?.overview {
            overviewTextLabel.attributedText = bulletPointList(strings: points)
        }
        view.backgroundColor = .white
        overviewView.layer.cornerRadius = 25
        overviewView.layer.masksToBounds = true
        
        if article == nil {
            article = newsStore.getArticle(by: 1)  // Temporary testing article
        }
        
        setupUI()
        
        // --- Load data for bottom sections ---
        relatedNews = newsStore.getAllNews().shuffled()
        
        if let articleID = article?.id {
            // load Q&A for this article
            qaHistory = newsStore.getQAHistory(for: articleID)
        } else {
            qaHistory = []
        }
        print("QA count:", qaHistory.count)
        
        
        
        
        
        setupCollectionView()
        setupGlassEffect()
        setupOptionsMenu()
        

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        setupJargons()
    }
    
    
    
    private func setupUI() {
        guard let article = article else { return }

        headlineLabel.text = article.title
        dateLabel.text = ("\(article.source) • \(article.date)")

        if let image = UIImage(named: article.imageName) {
            topImageView.image = image
        }
    }
    
    // MARK: - Collection View Setup
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        // More Like This cell
        collectionView.register(
            UINib(nibName: "moreLikeThisCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "realexplore_cell"
        )
        
        // Q&A cell
        collectionView.register(
            UINib(nibName: "askQuestionsCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "ask_cell"
        )
        
        // Header view
        collectionView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "header_cell"
        )
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }
    
    // MARK: - Compositional Layout (2 sections)
    private func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            
            // ---------- Section 0: More Like This (now first) ----------
            if sectionIndex == 0 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalHeight(1.0)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 10)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .estimated(280)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(40)
                )
                
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: "header",
                    alignment: .top
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.boundarySupplementaryItems = [header]
                
                return section
            }
            
            // ---------- Section 1: Questions Asked (now second) ----------
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.98),
                heightDimension: .fractionalHeight(1.0)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 50, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.95),
                heightDimension: .estimated(220)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(40)
            )
            
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: "header",
                alignment: .top
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2   // 0 = More Like This, 1 = Questions Asked
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return relatedNews.count     // More Like This first
        }
        return qaHistory.count          // Questions Asked second
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            // More Like This
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "realexplore_cell",
                for: indexPath
            ) as! moreLikeThisCollectionViewCell
            
            cell.configureCell(with: relatedNews[indexPath.row])
            return cell
        }
        
        // Questions Asked
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ask_cell",
            for: indexPath
        ) as! askQuestionsCollectionViewCell
        
        let qa = qaHistory[indexPath.row]
        cell.configureCell(with: qa)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: "header",
            withReuseIdentifier: "header_cell",
            for: indexPath
        ) as! HeaderView
        
        if indexPath.section == 0 {
            headerView.headerLabel.text = "More Like This"
            headerView.arrowImageView.isHidden = true
        } else {
            headerView.headerLabel.text = "Questions Asked"
            headerView.arrowImageView.isHidden = true
        }
        
        headerView.headerLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return headerView
    }
    
    // MARK: - Your original helper methods (unchanged)
    
    func bulletPointList(strings: [String]) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 15
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.paragraphSpacing = 8
        
        let bullet = "•  "
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .regular),
            .paragraphStyle: paragraphStyle
        ]
        
        let string = strings.map { "\(bullet)\($0)" }.joined(separator: "\n")
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !gradientApplied,
           let img = topImageView.image,
           let color = dominantColor(from: img) {
            
            extractedDominantColor = color
            let gradientImg = createGradientImage(
                color: color,
                size: gradientImageView.bounds.size
            )
            AppTheme.shared.dominantColor = color
            gradientImageView.image = gradientImg
            gradientApplied = true
//            applyDominantColorToButton(color)
            floatingButton.tintColor = color.withAlphaComponent(0.80)
            
        }
        
        setupJargons()

        
    }
    
    // your original gradient function
    func createGradientImage(color: UIColor, size: CGSize) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        
        gradientLayer.colors = [
            UIColor.clear.cgColor,                         // 0% - clear
            color.withAlphaComponent(0.60).cgColor,        // 45% - soft tint
            color.withAlphaComponent(1.0).cgColor,        // 60% - extended soft
            color.withAlphaComponent(1.0).cgColor,        // 80% - strong tint
            color.withAlphaComponent(0.9).cgColor,
            UIColor.systemGray6.cgColor                          // 100% - fade to white
        ]
        
        gradientLayer.locations = [
            0.0,   // clear
            0.25,  // soft begin
            0.50,  // extend soft
            0.65,  // strong begin
            0.70,
            1.0    // end white fade
        ]
        
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)
        
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return gradientImage
    }
    
    func dominantColor(from image: UIImage) -> UIColor? {
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
    
    
    func showShareSheet() {
        guard let article = article else { return }
        
        let customActivity = ShareToFriendsActivity()
        customActivity.article = article
        
        let activityVC = UIActivityViewController(
            activityItems: [article.title, UIImage(named: article.imageName) ?? UIImage()],
            applicationActivities: [customActivity]
        )
        
        // iPad safety
        activityVC.popoverPresentationController?.sourceView = self.view
        
        present(activityVC, animated: true)
    }
    
    
    class ShareToFriendsActivity: UIActivity {
        
        var article: NewsArticle?
        
        override var activityTitle: String? { "Share to Friends" }
        override var activityImage: UIImage? { UIImage(systemName: "person.2.fill") }
        
        override class var activityCategory: UIActivity.Category {
            return .action   // ensures it appears in the lower action list
        }
        
        override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
            return true
        }
        
        override func perform() {
            print("Sharing to friends inside the app")
            activityDidFinish(true)
        }
    }
    
    
    private func setupOptionsMenu() {
        // 1. Recommend
            let recommendAction = UIAction(
                title: "Recommend article more",
                image: UIImage(systemName: "hand.thumbsup")
            ) { [weak self] _ in
                guard let self = self, let article = self.article else { return }

                // 👉 Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)

                // 👉 Small green pulse overlay on glassView
                self.animateRecommendationPulse()

                // 👉 Optional: toast
                self.showToast(message: "We’ll show you more stories like this.")
                
                print("Recommend more articles like: \(article.title)")
            }

            // 2. Save
            let saveAction = UIAction(
                title: "Save article",
                image: UIImage(systemName: "bookmark")
            ) { [weak self] _ in
                guard let self = self, let article = self.article else { return }

                // 👉 Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)

                // 👉 Cute bookmark animation
                self.animateSaveBookmarkIcon()

                // 👉 Optional: toast
                self.showToast(message: "Article saved to your reading list.")
                
                print("Saved article: \(article.title)")
            }

            // 3. Share (UNCHANGED)
            let shareAction = UIAction(
                title: "Share article",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { [weak self] _ in
                guard let self = self, let article = self.article else { return }

                let customActivity = ShareToFriendsActivity()
                customActivity.article = article

                let activityVC = UIActivityViewController(
                    activityItems: [article.title],
                    applicationActivities: [customActivity]
                )

                // iPad / big screens: anchor to this bar button
                activityVC.popoverPresentationController?.barButtonItem = self.optionsButton

                self.present(activityVC, animated: true)
            }

            // 4. Build the menu
            let menu = UIMenu(
                title: "",
                children: [recommendAction, saveAction, shareAction]
            )

            optionsButton.menu = menu
    }
    
    private func setupGlassEffect() {
        // Create blur effect
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = glassView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add blur first
        glassView.addSubview(blurView)
        blurView.layer.zPosition = 0
        
        // Style the container itself
        glassView.layer.cornerRadius = 22
        glassView.layer.masksToBounds = true
        
        // Optional glossy border
        glassView.layer.borderWidth = 1
        glassView.layer.borderColor = UIColor.white.withAlphaComponent(0.95).cgColor
        
        // Add tint if needed
        blurView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        
        // Bring UI controls (like buttons or labels) on top so they are not blurred
        for subview in glassView.subviews where !(subview is UIVisualEffectView) {
            subview.layer.zPosition = 1
        }
    }
    
    private func animateRecommendationPulse() {
        // Make sure glassView exists
        guard let glassView = self.glassView else { return }

        let pulseView = UIView(frame: glassView.bounds)
        pulseView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.22)
        pulseView.layer.cornerRadius = glassView.layer.cornerRadius
        pulseView.layer.masksToBounds = true
        pulseView.alpha = 0
        pulseView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        glassView.addSubview(pulseView)
        glassView.bringSubviewToFront(pulseView)

        UIView.animate(withDuration: 0.18, animations: {
            pulseView.alpha = 1
            pulseView.transform = .identity
        }) { _ in
            UIView.animate(withDuration: 0.25, delay: 0.15, options: .curveEaseOut, animations: {
                pulseView.alpha = 0
                pulseView.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            }) { _ in
                pulseView.removeFromSuperview()
            }
        }
    }
    
    private func animateSaveBookmarkIcon() {
        // Anchor near top-right of glassView if available, else on main view
        let anchorView: UIView = glassView ?? self.view

        let iconSize: CGFloat = 28
        let bookmark = UIImageView(image: UIImage(systemName: "bookmark.fill"))
        bookmark.tintColor = .systemYellow
        bookmark.alpha = 0
        bookmark.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)

        anchorView.addSubview(bookmark)
        bookmark.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            bookmark.topAnchor.constraint(equalTo: anchorView.topAnchor, constant: 16),
            bookmark.trailingAnchor.constraint(equalTo: anchorView.trailingAnchor, constant: -20),
            bookmark.widthAnchor.constraint(equalToConstant: iconSize),
            bookmark.heightAnchor.constraint(equalToConstant: iconSize)
        ])

        // Pop + slight move up
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseOut,
                       animations: {
            bookmark.alpha = 1
            bookmark.transform = .identity
            bookmark.transform = CGAffineTransform(translationX: 0, y: -4)
        }) { _ in
            UIView.animate(withDuration: 0.25,
                           delay: 0.7,
                           options: .curveEaseIn,
                           animations: {
                bookmark.alpha = 0
                bookmark.transform = CGAffineTransform(translationX: 0, y: -12)
            }) { _ in
                bookmark.removeFromSuperview()
            }
        }
    }
    
    
  
    func setupJargons() {
        guard !didSetupJargons else { return }
        didSetupJargons = true

        guard let jargons = article?.jargons else { return }

        glassView.layoutIfNeeded()   // 🔑 ensure correct size

        glassView.isUserInteractionEnabled = true
        glassView.subviews
            .filter { $0 is UIButton }
            .forEach { $0.removeFromSuperview() }

        let buttonSize: CGFloat = 90
        let padding: CGFloat = 12
        let maxAttempts = 50

        let maxX = glassView.bounds.width - buttonSize - padding
        let maxY = glassView.bounds.height - buttonSize - padding

        // ❗ Safety check
        guard maxX > padding, maxY > padding else { return }

        var placedFrames: [CGRect] = []

        for word in jargons {
            let button = UIButton(type: .system)
            button.setTitle(word, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = AppTheme.shared.dominantColor ?? .systemBlue
            button.layer.cornerRadius = buttonSize / 2
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            button.titleLabel?.numberOfLines = 2
            button.titleLabel?.textAlignment = .center

            button.accessibilityIdentifier = word
            button.addTarget(self, action: #selector(jargonTapped(_:)), for: .touchUpInside)

            button.layer.shadowColor = UIColor.black.cgColor
            button.layer.shadowOpacity = 0.25
            button.layer.shadowRadius = 6
            button.layer.shadowOffset = CGSize(width: 0, height: 4)

            var placed = false

            for _ in 0..<maxAttempts {
                let randomX = CGFloat.random(in: padding...maxX)
                let randomY = CGFloat.random(in: padding...maxY)

                let frame = CGRect(
                    x: randomX,
                    y: randomY,
                    width: buttonSize,
                    height: buttonSize
                )

                let overlaps = placedFrames.contains {
                    $0.insetBy(dx: -10, dy: -10).intersects(frame)
                }

                if !overlaps {
                    button.frame = frame
                    placedFrames.append(frame)
                    placed = true
                    break
                }
            }

            // ❌ NO FALLBACK THAT BREAKS BOUNDS
            if !placed { continue }

//            addTwinkleEffect(to: button)
            
            glassView.addSubview(button)
            glassView.bringSubviewToFront(button)
            addFloatingMotion(to: button, in: glassView)
            addTwinkleEffect(to: button)
        }
    }
    
    @objc func jargonTapped(_ sender: UIButton) {
        guard let word = sender.accessibilityIdentifier else { return }

        print("Jargon tapped:", word) // DEBUG — you WILL see this now

        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        selectedJargon = word
        performSegue(withIdentifier: "showJargonDetail", sender: self)
    }
    
    private func addTwinkleEffect(to view: UIView) {
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = 1.0
        scale.toValue = 1.05
        scale.duration = 1.3
        scale.autoreverses = true
        scale.repeatCount = .infinity
        scale.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        view.layer.add(scale, forKey: "twinkle")
    }
    
    
    private func addFloatingMotion(to button: UIButton, in container: UIView) {

        let maxOffset: CGFloat = 15   // small movement only

        func animate() {
            let dx = CGFloat.random(in: -maxOffset...maxOffset)
            let dy = CGFloat.random(in: -maxOffset...maxOffset)

            // Calculate safe position (never outside glassView)
            var newCenter = CGPoint(
                x: button.center.x + dx,
                y: button.center.y + dy
            )

            let halfSize = button.bounds.width / 2
            let minX = halfSize
            let maxX = container.bounds.width - halfSize
            let minY = halfSize
            let maxY = container.bounds.height - halfSize

            newCenter.x = min(max(newCenter.x, minX), maxX)
            newCenter.y = min(max(newCenter.y, minY), maxY)

            UIView.animate(
                withDuration: Double.random(in: 2.8...4.2),
                delay: 0,
                options: [.curveEaseInOut, .allowUserInteraction],
                animations: {
                    button.center = newCenter
                },
                completion: { _ in
                    animate() // loop forever
                }
            )
        }

        animate()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChat" {

            // 1. Destination is a UINavigationController
            if let nav = segue.destination as? UINavigationController {

                // 2. First VC inside nav is ChatDetailViewController
                if let chatVC = nav.topViewController as? HomeChatDetailViewController {

                    // 3. Pass dominant color
                    chatVC.dominantColor = self.dominantColor
                    chatVC.articleID = self.article?.id   // ✅ THIS IS KEY
                    
                }
            }
        }
        if segue.identifier == "showJargonDetail" {
                if let vc = segue.destination as? JargonDetailViewController {
                    vc.jargonWord = selectedJargon
                }
            }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        guard let articleID = article?.id else { return }

        // Reload updated Q&A
        qaHistory = newsStore.getQAHistory(for: articleID)

        // Refresh UI
        collectionView.reloadSections(IndexSet(integer: 1))
    }
    
    
    @IBAction func segmentChanged(_ sender: Any) {
        guard let article = article else { return }

            // 1️⃣ HAPTIC FEEDBACK
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()

            // 2️⃣ Determine new text + direction
            let newText: NSAttributedString
            let direction: CGFloat

            if (sender as AnyObject).selectedSegmentIndex == 0 {
                newText = bulletPointList(strings: article.overview)
                direction = -1   // card exits LEFT, new enters from RIGHT
            } else {
                newText = bulletPointList(strings: article.keyTakeaways)
                direction = 1    // card exits RIGHT, new enters from LEFT
            }

            // 3️⃣ ANIMATE THE WHOLE CARD
            let card = overviewView!
            let originalX = card.frame.origin.x
            let width = card.frame.width

            UIView.animate(withDuration: 0.25, animations: {
                // Slide card OFF screen
                card.frame.origin.x = originalX - direction * width
                card.alpha = 0
            }) { _ in
                // Update text while card is off-screen
                self.overviewTextLabel.attributedText = newText

                // Move card to opposite side (off-screen)
                card.frame.origin.x = originalX + direction * width

                // Animate card back in
                UIView.animate(
                    withDuration: 0.32,
                    delay: 0,
                    usingSpringWithDamping: 0.82,
                    initialSpringVelocity: 0.6,
                    options: [.curveEaseOut],
                    animations: {
                        card.frame.origin.x = originalX
                        card.alpha = 1
                    },
                    completion: nil
                )
            }
        
    }
    
}

extension news1ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // Only respond to taps from the More Like This section
        if indexPath.section == 0 {
            let selected = relatedNews[indexPath.row]

            // Create a NEW instance of news1ViewController
            let storyboard = UIStoryboard(name: "HomeMain", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "news1ViewController") as? news1ViewController {

                vc.article = selected   // pass the selected article

                // Push onto navigation stack
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}















//private var didSetupJargons = false
//
//func setupJargons() {
//    guard !didSetupJargons else { return }
//    didSetupJargons = true
//
//    guard let jargons = article?.jargons else { return }
//
//    jargonsContainerView.subviews.forEach { $0.removeFromSuperview() }
//
//    let buttonSize: CGFloat = 90
//    let padding: CGFloat = 12
//    let maxAttempts = 40
//
//    var placedFrames: [CGRect] = []
//
//    for word in jargons {
//        let button = UIButton(type: .system)
//        button.setTitle(word, for: .normal)
//        button.setTitleColor(.white, for: .normal)
//
//        button.backgroundColor = AppTheme.shared.dominantColor ?? .systemBlue
//        button.layer.cornerRadius = buttonSize / 2
//        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
//        button.titleLabel?.numberOfLines = 2
//        button.titleLabel?.textAlignment = .center
//        
//        button.accessibilityIdentifier = word
//
//        button.addTarget(self, action: #selector(jargonTapped(_:)), for: .touchUpInside)
//
//        // Shadow = clickable hint
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOpacity = 0.25
//        button.layer.shadowRadius = 6
//        button.layer.shadowOffset = CGSize(width: 0, height: 4)
//
//        var placed = false
//
//        for _ in 0..<maxAttempts {
//            let maxX = jargonsContainerView.bounds.width - buttonSize - padding
//            let maxY = jargonsContainerView.bounds.height - buttonSize - padding
//
//            let randomX = CGFloat.random(in: padding...max(padding, maxX))
//            let randomY = CGFloat.random(in: padding...max(padding, maxY))
//
//            let frame = CGRect(
//                x: randomX,
//                y: randomY,
//                width: buttonSize,
//                height: buttonSize
//            )
//
//            // 🔴 Overlap check
//            let overlaps = placedFrames.contains {
//                $0.insetBy(dx: -8, dy: -8).intersects(frame)
//            }
//
//            if !overlaps {
//                button.frame = frame
//                placedFrames.append(frame)
//                placed = true
//                break
//            }
//        }
//
//        // Fallback (just in case space is tight)
//        if !placed {
//            let y = CGFloat(placedFrames.count) * (buttonSize + padding)
//            button.frame = CGRect(
//                x: padding,
//                y: y,
//                width: buttonSize,
//                height: buttonSize
//            )
//        }
//        
//        
//        addTwinkleEffect(to: button)
//        print("Adding jargon:", word)
//        print("✅ Adding button for: \(word) at frame: \(button.frame)")
//        jargonsContainerView.addSubview(button)
//        jargonsContainerView.bringSubviewToFront(button)
//    }
//}
//
//
