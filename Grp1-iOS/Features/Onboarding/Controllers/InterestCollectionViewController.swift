//
//  InterestCollectionViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 12/01/26.
//

import UIKit

class InterestCollectionViewController: UIViewController {
    var onBackTapped: (() -> Void)?
    var preferences : [OnboardingInterestModel] = [
        OnboardingInterestModel(icon: "indianrupeesign.gauge.chart.lefthalf.righthalf", title: "Indian Economy", subtitle: "Consumption,inflation , growth"),
        OnboardingInterestModel(icon: "figure.wave", title:"Personal Finance", subtitle: "Exports, Imports and Trade Balance"),
        OnboardingInterestModel(icon: "newspaper", title:"Government and Policy", subtitle: "Public Spending and Reforms"),
        OnboardingInterestModel(icon: "chart.line.uptrend.xyaxis", title:"Stock Markets", subtitle: "Shares ,Indices and Market Cycles"),
        OnboardingInterestModel(icon: "building.2", title:"Real Estate Economics", subtitle: "Housing Interest rates, demand"),
        OnboardingInterestModel(icon: "globe.central.south.asia.fill", title:"Global Economy", subtitle: "Exports, Imports and Trade Balance"),
        OnboardingInterestModel(icon: "banknote", title:"Banking and credit", subtitle: "Loans , Interest rates and Moneyflow"),
        OnboardingInterestModel(icon: "bitcoinsign.circle", title:"Crypto", subtitle: "Bitcoin, Web3 and Digital Assets"),
        
    ]
    
    
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

