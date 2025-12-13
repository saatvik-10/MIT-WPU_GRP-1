


import UIKit

class threadsViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let threadsStore = ThreadsDataStore.shared
    var threads: [ThreadPost] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        threads = threadsStore.getAllThreads()
        setupCollectionView()
        let threadsBG = UIColor(white: 250/255, alpha: 1)
        view.backgroundColor = threadsBG
        collectionView.backgroundColor = threadsBG
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Register nib - ensure nib name matches your xib filename
        let nib = UINib(nibName: "collectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "collectionViewCell")
        
        let headerNib = UINib(nibName: "ThreadsHeaderCollectionReusableView", bundle: nil)
        collectionView.register(
            headerNib,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "ThreadsHeaderCollectionReusableView"
        )
        
        // Simple flow layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 20
            layout.sectionInset = UIEdgeInsets(top: 12, left: 0, bottom: 20, right: 0)
            
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            
            layout.headerReferenceSize = CGSize(width: view.frame.width, height: 100)
           // layout.sectionHeadersPinToVisibleBounds = true
        }
    }
}

// MARK: - CollectionView Methods
extension threadsViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return threads.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "collectionViewCell",
            for: indexPath
        ) as? collectionViewCell else {
            return UICollectionViewCell()
        }
        
        let post = threads[indexPath.item]
        cell.configure(with: post)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {

        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "ThreadsHeaderCollectionReusableView",
            for: indexPath
        ) as! ThreadsHeaderCollectionReusableView

        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                            layout collectionViewLayout: UICollectionViewLayout,
                            referenceSizeForHeaderInSection section: Int) -> CGSize {
            
            return CGSize(width: collectionView.frame.width, height: 150)
        }
    

   
    
}
