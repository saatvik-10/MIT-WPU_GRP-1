//
//  InterestCollectionViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class InterestCollectionViewController: UIViewController {
    
    
    @IBOutlet weak var stepLabel: UILabel!
    var onBackTapped: (() -> Void)?
    
    
    
    @IBOutlet weak var interestCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        // Do any additional setup after loading the view.
    }
    private func setupCollectionView(){
        interestCollectionView.delegate = self
        interestCollectionView.dataSource = self
        interestCollectionView.allowsMultipleSelection = true
        stepLabel.layer.cornerRadius = 16
        interestCollectionView.register(
            UINib(nibName: "InterestCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "InterestCollectionViewCell"
        )
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        onBackTapped?()
    }
    

}

extension InterestCollectionViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return preferences.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath)
    -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "InterestCollectionViewCell",
            for: indexPath
        ) as! InterestCollectionViewCell
        cell.configure(preferences[indexPath.item])
        return cell
    }
}


extension InterestCollectionViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.bounds.width - 12) / 2
        return CGSize(width: width, height: 150)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

