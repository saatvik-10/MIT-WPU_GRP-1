import UIKit

class HomeViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var autoScrollTimer: Timer?
        var currentIndex = 0
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAutoScroll()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoScroll()
    }
    var onArticleLensTapped: (() -> Void)?
    
    let newsStore = NewsDataStore.shared
    
    var todaysPick: [NewsArticle] = []
    var trendingNews: [NewsArticle] = []
    var marketHighlights: [NewsArticle] = []
    var article: NewsArticle?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        
        registerCells()

        todaysPick = newsStore.getAllNews()
        trendingNews = newsStore.getAllNews().reversed()
        marketHighlights = newsStore.getAllNews().shuffled()
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    func startAutoScroll() {
        stopAutoScroll()   // avoid duplicate timers

        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { [weak self] _ in
            self?.scrollTodaysPick()
        }
    }

    func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }

    func scrollTodaysPick() {
        guard todaysPick.count > 1 else { return }

        let section = 0
        let lastIndex = todaysPick.count - 1

        // Move to next
        if currentIndex < lastIndex {
            currentIndex += 1
        } else {
            currentIndex = 0
        }

        let indexPath = IndexPath(item: currentIndex, section: section)

        collectionView.scrollToItem(at: indexPath,
                                    at: .centeredHorizontally,
                                    animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            
            var selectedArticle: NewsArticle?

            if indexPath.section == 0 {
                selectedArticle = todaysPick[indexPath.row]
            } else if indexPath.section == 1 {
                selectedArticle = trendingNews[indexPath.row]
            } else if indexPath.section == 2 {
                selectedArticle = marketHighlights[indexPath.row]
            } else {
                selectedArticle = marketHighlights[indexPath.row]
            }

            performSegue(withIdentifier: "showArticleDetail", sender: selectedArticle)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showArticleDetail" {
                if let destinationVC = segue.destination as? news1ViewController,
                   let article = sender as? NewsArticle {
                    destinationVC.article = article
                }
            }
        }
    
    func generateLayout()->UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { section, _ in
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .absolute(50)
            )
            
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: "header",
                alignment: .top
            )
            
            // SECTION 0 - Full screen horizontal cards
            if section == 0 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(410)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.contentInsets = NSDirectionalEdgeInsets(top: -170, leading: 0, bottom: 15, trailing: 0)
                section.boundarySupplementaryItems = [headerItem]
                
                
                
                return section
            }
            
            // SECTION 1 - Medium horizontal cards
            if section == 1 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 15, trailing: 10)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(320)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
//                section.orthogonalScrollingBehavior = .groupPagingCentered
//                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
                section.boundarySupplementaryItems = [headerItem]
                
                return section
            }
            
            // SECTION 3 - Real Explore (bigger vertical cards)
            if section == 3 {
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.5),
                    heightDimension: .fractionalHeight(1.0)
                )
                
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10)
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .estimated(250)  // adjust height
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.boundarySupplementaryItems = [headerItem]
                return section
            }
            
            // SECTION 2 - Vertical List
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(175)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
//            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
//            section.boundarySupplementaryItems = [headerItem]
            return section
        }
        
        return layout
    }
    
    func registerCells() {
        collectionView.register(
            UINib(nibName: "TodaysPickCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "today_cell"
        )
        
        collectionView.register(
            UINib(nibName: "TrendingCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "trending_cell"
        )
        
        collectionView.register(
            UINib(nibName: "ExploreCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "explore_cell"
        )
        
        collectionView.register(
            UINib(nibName: "RealExploreCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "realexplore_cell"
        )
        
        collectionView.register(
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "header_cell"
        )
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        4
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return todaysPick.count
        case 1: return 1
        case 2: return marketHighlights.count
        case 3: return marketHighlights.count   // real explore section
        default: return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "today_cell", for: indexPath) as! TodaysPickCollectionViewCell
            cell.configureCell(with: todaysPick[indexPath.row])
            //            cell.onArticleLensTapped = { [weak self] in
            //                    self?.presentArticleLens()
            return cell
        }
        else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trending_cell", for: indexPath) as! TrendingCollectionViewCell
            cell.configureCell(with: trendingNews[indexPath.row])
            cell.onArticleLensTapped = { [weak self] in
                    guard let self = self else { return }

                    let popupVC = ArticleLensPopupViewController(nibName: "ArticleLensPopupViewController", bundle: nil)
                    popupVC.modalPresentationStyle = .overFullScreen
                    popupVC.modalTransitionStyle = .crossDissolve
                    self.present(popupVC, animated: true)
                }
            cell.onRecommendTapped = { [weak self] in
                    self?.showToast(message: "Recommendation sent!")   // << toast works here
                }

            return cell
        } else if indexPath.section == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "explore_cell", for: indexPath) as! ExploreCollectionViewCell
            cell.configureCell(with: marketHighlights[indexPath.row])
            cell.onArticleLensTapped = { [weak self] in
                    guard let self = self else { return }

                    let popupVC = ArticleLensPopupViewController(nibName: "ArticleLensPopupViewController", bundle: nil)
                    popupVC.modalPresentationStyle = .overFullScreen
                    popupVC.modalTransitionStyle = .crossDissolve
                    self.present(popupVC, animated: true)
                }
            cell.onRecommendTapped = { [weak self] in
                    self?.showToast(message: "Recommendation sent!")   // << toast works here
                }
            return cell
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "realexplore_cell", for: indexPath) as! RealExploreCollectionViewCell
            cell.configureCell(with: marketHighlights[indexPath.row])
            return cell
        }
        
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
            headerView.headerLabel.text = " "
            headerView.arrowImageView.isHidden = true
            headerView.headerLabel.font = UIFont.systemFont(ofSize: 34, weight: .bold)  // << Bigger title
            headerView.headerLabel.textColor = .black
        }
        else if indexPath.section == 1 {
            headerView.headerLabel.text = "Your News Feed"
            headerView.arrowImageView.isHidden = true
            headerView.headerLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
            headerView.headerLabel.textColor = .black
        }
        else if indexPath.section == 2 {
            headerView.headerLabel.text = "Explore More"
            headerView.arrowImageView.isHidden = true
            headerView.headerLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        }
        else {
            headerView.headerLabel.text = "Explore More"
            headerView.arrowImageView.isHidden = false
            headerView.headerLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        }
        
        
        headerView.onTap = { [weak self] in
                guard let self = self else { return }

                if indexPath.section == 2 || indexPath.section == 3 {
                    self.openExploreMore()
                }
            }
        
        return headerView
    }
    
    
    func openExploreMore() {
        self.performSegue(withIdentifier: "toExploreMore", sender: nil)
    }
}
