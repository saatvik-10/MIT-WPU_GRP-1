//
//  DomainSelectionViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 16/12/25.
//

import UIKit

class DomainSelectionViewController: UIViewController {
    
    @IBOutlet weak var stepLabel: UILabel!
    var onNextTapped: (() -> Void)?
    @IBOutlet weak var collectionView: UICollectionView!
    var domains: [DomainModel] = [
        DomainModel(title: "Stocks", icon: "chart.bar"),
        DomainModel(title: "Mutual Funds", icon: "building.columns"),
        DomainModel(title: "Crypto", icon: "bitcoinsign.circle"),
        DomainModel(title: "Macroeconomy", icon: "globe"),
        DomainModel(title: "Banking", icon: "creditcard"),
        DomainModel(title: "Commodities", icon: "cube.box")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        // Do any additional setup after loading the view.
        stepLabel.layer.masksToBounds = true
        stepLabel.layer.cornerRadius = 12
    }
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self

        collectionView.allowsMultipleSelection = true
    }

}

extension DomainSelectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return domains.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DomainCollectionViewCell",
            for: indexPath
        ) as! DomainCollectionViewCell

        cell.configure(domains[indexPath.item])
        return cell
    }
}
extension DomainSelectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.bounds.width - 12) / 2
        return CGSize(width: width, height: 90)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
