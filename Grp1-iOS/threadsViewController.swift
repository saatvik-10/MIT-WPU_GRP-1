






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
        
        // Simple flow layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 20
            layout.sectionInset = UIEdgeInsets(top: 12, left: 0, bottom: 20, right: 0)
            
            layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
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

  
   
    
}
