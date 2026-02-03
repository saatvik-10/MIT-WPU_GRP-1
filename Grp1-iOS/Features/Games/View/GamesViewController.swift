//
//  GamesViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 02/02/26.
//

import UIKit

struct GameCategory {
    let title: String
    let icon: UIImage
    let colors: [UIColor]
}

final class GamesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private let categories: [GameCategory] = [
        .init(
            title: "Scenario",
            icon: UIImage(systemName: "brain.head.profile")!,
            colors: [.systemOrange, .systemPink]
        ),
        .init(
            title: "Wordle",
            icon: UIImage(systemName: "text.word.spacing")!,
            colors: [.systemBlue, .systemTeal]
        ),
        .init(
            title: "Word Games",
            icon: UIImage(systemName: "textformat")!,
            colors: [.systemGreen, .systemMint]
        ),
        .init(
            title: "Crossword",
            icon: UIImage(systemName: "square.grid.3x3.fill")!,
            colors: [.systemPurple, .systemIndigo]
        )
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }

    private func setupCollectionView() {
        collectionView.collectionViewLayout = makeLayout()
        collectionView.backgroundColor = .clear

        collectionView.register(
            UINib(nibName: "GameCategoryCell", bundle: nil),
            forCellWithReuseIdentifier: "GameCategoryCell"
        )

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func makeLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 8, leading: 8, bottom: 8, trailing: 8)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(140)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 2
        )

        let section = NSCollectionLayoutSection(group: group)
        return UICollectionViewCompositionalLayout(section: section)
    }
}

extension GamesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "GameCategoryCell",
            for: indexPath
        ) as! GameCategoryCell

        cell.configure(with: categories[indexPath.item])
        return cell
    }
}

extension GamesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categories[indexPath.item]
        print("Tapped:", category.title)
    }
}
