import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let newsStore = NewsDataStore.shared
    
    var todaysPick: [NewsArticle] = []
    var trendingNews: [NewsArticle] = []
    var marketHighlights: [NewsArticle] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()

        todaysPick = newsStore.getAllNews()
        trendingNews = newsStore.getAllNews().reversed()
        marketHighlights = newsStore.getAllNews().shuffled()
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
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
                    heightDimension: .estimated(480)
                )
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: groupSize,
                    subitems: [item]
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .groupPagingCentered
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
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
            
            // SECTION 2 - Vertical List
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(180)
            )
            
            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: groupSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0)
            section.boundarySupplementaryItems = [headerItem]
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
            UINib(nibName: "HeaderView", bundle: nil),
            forSupplementaryViewOfKind: "header",
            withReuseIdentifier: "header_cell"
        )
    }
}

extension HomeViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return todaysPick.count
        case 1: return trendingNews.count
        default: return marketHighlights.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "today_cell", for: indexPath) as! TodaysPickCollectionViewCell
            cell.configureCell(with: todaysPick[indexPath.row])
            return cell
        }
        else if indexPath.section == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "trending_cell", for: indexPath) as! TrendingCollectionViewCell
            cell.configureCell(with: trendingNews[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "explore_cell", for: indexPath) as! ExploreCollectionViewCell
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
            headerView.headerLabel.text = "Today's Picks"
        } else if indexPath.section == 1 {
            headerView.headerLabel.text = "Your News Feed"
        } else {
            headerView.headerLabel.text = "Explore More"
        }
        return headerView
    }
}
