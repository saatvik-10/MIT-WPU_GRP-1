//
//  BookmarkViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 11/12/25.
//

import UIKit

class BookmarkViewController: UIViewController {

    
    @IBOutlet weak var collectionView: UICollectionView!

        // MARK: - Data Source
    private var items: [BookmarkItem] = Bookmarks.mockBookmarks

        override func viewDidLoad() {
            super.viewDidLoad()

            title = "Bookmarks"
            setupCollectionView()
            collectionView.setCollectionViewLayout(generateLayout(), animated: false)
        }
        
        private func setupCollectionView() {
            collectionView.dataSource = self
            collectionView.delegate = self

            collectionView.register(
                UINib(nibName: "BookmarkViewCell", bundle: nil),
                forCellWithReuseIdentifier: "BookmarkViewCell"
            )
        }
}

private func generateLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1.0),
        heightDimension: .absolute(70)
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


extension BookmarkViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "BookmarkViewCell",
            for: indexPath
        ) as! BookmarkViewCell

        cell.configure(items[indexPath.row])
        cell.delegate = self

        return cell
    }
}

extension BookmarkViewController: BookmarkCellDelegate {
    func didTapBookmark(in cell: BookmarkViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        print("Bookmark tapped → \(items[indexPath.row].title)")
    }
}
