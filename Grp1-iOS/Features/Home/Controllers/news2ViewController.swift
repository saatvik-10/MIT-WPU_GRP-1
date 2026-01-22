//
//  news2ViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 13/01/26.
//

import UIKit

class news2ViewController: UIViewController, UICollectionViewDataSource {

    
    
    
    @IBOutlet weak var QuizButton: UIButton!
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
    
    let newsStore = NewsDataStore.shared
    var relatedNews: [NewsArticle] = []
    var qaHistory: [ArticleQA] = []
    
    var article: NewsArticle?
    
    private var gradientApplied = false

    

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        overviewTextLabel.numberOfLines = 0
        if let points = article?.overview {
            overviewTextLabel.attributedText = bulletPointList(strings: points)
        }
        view.backgroundColor = .white
        overviewView.layer.cornerRadius = 25
        overviewView.layer.masksToBounds = true
        
        if article == nil {
            article = newsStore.getArticle(by: 1)
        }
        setupUI()
        relatedNews = newsStore.getAllNews().shuffled()
        if let articleID = article?.id {
            qaHistory = newsStore.getQAHistory(for: articleID)
        }
        else {
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

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        

        collectionView.register(UINib(nibName: "moreLikeThisCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "realexplore_cell")
        
        collectionView.register(UINib(nibName: "askQuestionsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ask_cell"
        )
        
        collectionView.register(UINib(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: "header", withReuseIdentifier: "header_cell"
        )
    
        collectionView.setCollectionViewLayout(generateLayout(), animated: false)
    }
    

    private func generateLayout() -> UICollectionViewLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            

            if sectionIndex == 0 {
                let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 10)
                
                let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .estimated(280))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
                
                let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                section.boundarySupplementaryItems = [header]
                
                return section
            }
            

            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.98), heightDimension: .fractionalHeight(1.0))
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 50, trailing: 2)
            
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95), heightDimension: .estimated(220))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .top)
            
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
            section.boundarySupplementaryItems = [header]
            
            return section
        }
    }
    

    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    @objc func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return relatedNews.count
        }
        return qaHistory.count
    }
    
    @objc(collectionView:cellForItemAtIndexPath:) func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "realexplore_cell", for: indexPath) as! moreLikeThisCollectionViewCell
            
            cell.configureCell(with: relatedNews[indexPath.row])
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ask_cell", for: indexPath) as! askQuestionsCollectionViewCell
        
        let qa = qaHistory[indexPath.row]
        cell.configureCell(with: qa)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: "header", withReuseIdentifier: "header_cell", for: indexPath) as! HeaderView
        
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
            
            let gradientImg = createGradientImage(color: color, size: gradientImageView.bounds.size)
            AppTheme.shared.dominantColor = color
            gradientImageView.image = gradientImg
            gradientApplied = true
//            applyDominantColorToButton(color)
            floatingButton.tintColor = color.withAlphaComponent(0.80)
            QuizButton.tintColor = color.withAlphaComponent(0.80)
        }
        setupJargons()
    }
    

    func createGradientImage(color: UIColor, size: CGSize) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)
        gradientLayer.colors = [
            UIColor.clear.cgColor,                         // clear
            color.withAlphaComponent(0.60).cgColor,        // soft tint
            color.withAlphaComponent(1.0).cgColor,        // extended soft
            color.withAlphaComponent(1.0).cgColor,        // strong tint
            color.withAlphaComponent(0.9).cgColor,        // extend strong tint
            UIColor.systemGray6.cgColor                  // fade to white
        ]
        
        gradientLayer.locations = [
            0.0,   //clear
            0.25,  //soft tint begin
            0.50,  //extend soft tint
            0.65,  //strong tint begin
            0.70,  //
            1.0    //end white fade
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
            parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: CIVector(cgRect: extent)]) else { return nil }
        
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
    
    
    class ShareToFriendsActivity: UIActivity {
        
        var article: NewsArticle?
        override var activityTitle: String? { "Share to Friends" }
        override var activityImage: UIImage? { UIImage(systemName: "person.2.fill") }
        override class var activityCategory: UIActivity.Category {
            return .action
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
            let recommendAction = UIAction(
                title: "Recommend article more",
                image: UIImage(systemName: "hand.thumbsup")
            ) { [weak self] _ in
                guard let self = self, let article = self.article else { return }
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                self.showToast(message: "We’ll show more stories like this.")
                print("Recommend more articles like: \(article.title)")
            }
            let saveAction = UIAction(
                title: "Save article",
                image: UIImage(systemName: "bookmark")
            ) { [weak self] _ in
                guard let self = self, let article = self.article else { return }
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                self.showToast(message: "Article saved to reading list.")
                
                print("Saved article: \(article.title)")
            }
            let shareAction = UIAction(
                title: "Share article",
                image: UIImage(systemName: "square.and.arrow.up")
            ) { [weak self] _ in
                guard let self = self, let article = self.article else { return }

                let customActivity = ShareToFriendsActivity()
                customActivity.article = article

                if let pdfURL = createPDFOfScreen() {

                    let activityVC = UIActivityViewController(
                        activityItems: [pdfURL, article.title],
                        applicationActivities: [customActivity]
                    )

                    activityVC.popoverPresentationController?.barButtonItem = self.optionsButton
                    present(activityVC, animated: true)
                }
            }
            let menu = UIMenu(
                title: "",
                children: [recommendAction, saveAction, shareAction]
            )

            optionsButton.menu = menu
    }
    
    func createPDFOfScreen() -> URL? {

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: view.bounds)

        let fileName = "Article.pdf"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try pdfRenderer.writePDF(to: fileURL) { context in
                context.beginPage()
                view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            }
            return fileURL
        } catch {
            print("Failed to create PDF:", error)
            return nil
        }
    }
    
    private func setupGlassEffect() {
        // Create blur
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = glassView.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add blur first
        glassView.addSubview(blurView)
        blurView.layer.zPosition = 0
        glassView.layer.cornerRadius = 22
        glassView.layer.masksToBounds = true
        glassView.layer.borderWidth = 1
        glassView.layer.borderColor = UIColor.white.withAlphaComponent(0.95).cgColor
        blurView.backgroundColor = UIColor.white.withAlphaComponent(0.95)
        
        
        for subview in glassView.subviews where !(subview is UIVisualEffectView) {
            subview.layer.zPosition = 1
        }
    }
  
    func setupJargons() {
        guard !didSetupJargons else { return }
        didSetupJargons = true

        guard let jargons = article?.jargons else { return }

        glassView.layoutIfNeeded()

        glassView.isUserInteractionEnabled = true
        glassView.subviews
            .filter { $0 is UIButton }
            .forEach { $0.removeFromSuperview() }

        let buttonSize: CGFloat = 90
        let padding: CGFloat = 12
        let maxAttempts = 50

        let maxX = glassView.bounds.width - buttonSize - padding
        let maxY = glassView.bounds.height - buttonSize - padding
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
                let frame = CGRect(x: randomX, y: randomY, width: buttonSize, height: buttonSize)
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
            if !placed { continue }
            
            glassView.addSubview(button)
            glassView.bringSubviewToFront(button)
            addFloatingMotion(to: button, in: glassView)
            addTwinkleEffect(to: button)
        }
    }
    
    @objc func jargonTapped(_ sender: UIButton) {
        guard let word = sender.accessibilityIdentifier else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        selectedJargon = word
        selectedWord.word = word
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
        let maxOffset: CGFloat = 15
        func animate() {
            let dx = CGFloat.random(in: -maxOffset...maxOffset)
            let dy = CGFloat.random(in: -maxOffset...maxOffset)
            var newCenter = CGPoint(x: button.center.x + dx, y: button.center.y + dy)

            let halfSize = button.bounds.width / 2
            let minX = halfSize
            let maxX = container.bounds.width - halfSize
            let minY = halfSize
            let maxY = container.bounds.height - halfSize

            newCenter.x = min(max(newCenter.x, minX), maxX)
            newCenter.y = min(max(newCenter.y, minY), maxY)

            UIView.animate(withDuration: Double.random(in: 2.8...4.2), delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
                    button.center = newCenter
                },completion: { _ in
                    animate()
                })
        }
        animate()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toChat" {
            if let nav = segue.destination as? UINavigationController {
                if let chatVC = nav.topViewController as? HomeChatDetailViewController {
                    chatVC.articleID = self.article?.id
                    
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
        qaHistory = newsStore.getQAHistory(for: articleID)
        collectionView.reloadSections(IndexSet(integer: 1))
    }
    
    
    @IBAction func segmentChanged(_ sender: Any) {
        guard let article = article else { return }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            let newText: NSAttributedString
            let direction: CGFloat

            if (sender as AnyObject).selectedSegmentIndex == 0 {
                newText = bulletPointList(strings: article.overview)
                direction = -1
            } else {
                newText = bulletPointList(strings: article.keyTakeaways)
                direction = 1
            }
            let card = overviewView!
            let originalX = card.frame.origin.x
            let width = card.frame.width

            UIView.animate(withDuration: 0.25, animations: {
                card.frame.origin.x = originalX - direction * width
                card.alpha = 0
            }) { _ in
                self.overviewTextLabel.attributedText = newText
                card.frame.origin.x = originalX + direction * width
                UIView.animate(withDuration: 0.32, delay: 0, usingSpringWithDamping: 0.82, initialSpringVelocity: 0.6, options: [.curveEaseOut], animations: {
                        card.frame.origin.x = originalX
                        card.alpha = 1
                    }, completion: nil)
            }
    }
    
    
    
    @IBAction func startQuizTapped(_ sender: Any) {
        
        guard let article = article else {
               print("Article is nil")
               return
           }

           QuizContext.shared.selectedArticleId = article.id
    }
    
}

extension news2ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let selected = relatedNews[indexPath.row]
            let storyboard = UIStoryboard(name: "HomeMain", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "news1ViewController") as? news1ViewController {

                vc.article = selected
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
