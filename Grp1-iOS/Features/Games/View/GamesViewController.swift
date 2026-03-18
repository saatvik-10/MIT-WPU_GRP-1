//
//  GamesViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 02/02/26.
//

import UIKit
import Charts
import SwiftUI

struct GameCategory {
    let title: String
    let icon: UIImage
    let colors: [UIColor]
    let description: String
}

final class GamesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var ChartOuterView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    private var currentData: [GameUsage] = []


    private let categories: [GameCategory] = [
        .init(
            title: "Scenario",
            icon: UIImage(systemName: "brain.head.profile")!,
            colors: [UIColor.white.withAlphaComponent(0.5), UIColor.systemGray3.withAlphaComponent(0.7)],
            description: "Navigate real-world business situations and make critical decisions."
        ),
        .init(
            title: "Wordle",
            icon: UIImage(systemName: "text.word.spacing")!,
            colors: [UIColor.white.withAlphaComponent(0.5), UIColor.systemGray3.withAlphaComponent(0.7)],
            description: "Guess the hidden word in six tries. One word, six chances."
        ),
        .init(
            title: "Evaluate the Company",
            icon: UIImage(systemName: "textformat")!,
            colors: [UIColor.white.withAlphaComponent(0.5), UIColor.systemGray3.withAlphaComponent(0.7)],
            description: "Analyse financials and judge whether a company is worth investing in."
        ),
        .init(
            title: "Crossword",
            icon: UIImage(systemName: "square.grid.3x3.fill")!,
            colors: [UIColor.white.withAlphaComponent(0.5), UIColor.systemGray3.withAlphaComponent(0.7)],
            description: "Fill the grid using clues across and down. Test your vocabulary."
        )
    ]
    private var gridCategories: [GameCategory] {
        Array(categories.prefix(4))
    }

    private var fullWidthCategory: GameCategory {
        categories.last!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
//        showWeekly()
//        styleChartOuterView()
    }
//    private func styleChartOuterView() {
//        ChartOuterView.layer.cornerRadius = 20
//        ChartOuterView.layer.masksToBounds = false
//
//        // Adaptive background (light / dark)
//        ChartOuterView.backgroundColor = UIColor { trait in
//            trait.userInterfaceStyle == .dark
//            ? UIColor.systemGray6
//            : UIColor.white
//        }
//
//        // Soft card shadow (Apple-style)
//        ChartOuterView.layer.shadowColor = UIColor.black.cgColor
//        ChartOuterView.layer.shadowOpacity = 0.12
//        ChartOuterView.layer.shadowOffset = CGSize(width: 0, height: 6)
//        ChartOuterView.layer.shadowRadius = 14
//
//        // Performance + crisp shadow
//        ChartOuterView.layer.shouldRasterize = true
//        ChartOuterView.layer.rasterizationScale = UIScreen.main.scale
//    }
    
    private func setupCollectionView() {
        collectionView.collectionViewLayout = makeLayout()
        collectionView.backgroundColor = .clear

        collectionView.register(
            UINib(nibName: "GameCategoryCell", bundle: nil),
            forCellWithReuseIdentifier: "GameCategoryCell"
        )

        collectionView.register(
            UINib(nibName: "GameCatergory3CollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "GameCatergory3CollectionViewCell"
        )

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    private func makeLayout() -> UICollectionViewLayout {

        return UICollectionViewCompositionalLayout { sectionIndex, _ in

            if sectionIndex == 0 {
                // 🔹 GRID (2 per row)
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

                return NSCollectionLayoutSection(group: group)

            } else {
                // 🔹 FULL-WIDTH CELL
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )

                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = .init(top: 3, leading: 12, bottom: 3, trailing: 12)

                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(160)
                )

                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: groupSize,
                    subitems: [item]
                )

                return NSCollectionLayoutSection(group: group)
            }
        }
    }
}

extension GamesViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        } else {
            return categories.count  // ✅ all 5
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "GameCategoryCell",
                for: indexPath
            ) as! GameCategoryCell

            cell.configure(with: gridCategories[indexPath.item])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "GameCatergory3CollectionViewCell",
                for: indexPath
            ) as! GameCatergory3CollectionViewCell

            cell.configure(with: categories[indexPath.item])  // ✅ use index, not hardcoded last item
            return cell
        }
    }
//    private func setupSegmentedControl() {
//            segmentedControl.removeAllSegments()
//            segmentedControl.insertSegment(withTitle: "Weekly", at: 0, animated: false)
//            segmentedControl.insertSegment(withTitle: "Monthly", at: 1, animated: false)
//            segmentedControl.insertSegment(withTitle: "Yearly", at: 2, animated: false)
//            segmentedControl.selectedSegmentIndex = 0
//        }
//
//        @IBAction func segmentChanged(_ sender: UISegmentedControl) {
//            switch sender.selectedSegmentIndex {
//            case 0: showWeekly()
//            case 1: showMonthly()
//            case 2: showYearly()
//            default: break
//            }
//        }
//
//        private func showWeekly() {
//            updateChart(with: weeklyData)
//        }
//
//        private func showMonthly() {
//            updateChart(with: monthlyData)
//        }
//
//        private func showYearly() {
//            updateChart(with: yearlyData)
//        }
//    private func makeChart(data: [GameUsage]) -> UIView {
//        let chartView = GameUsageChart(data: data)
//        let hosting = UIHostingController(rootView: chartView)
//
//        hosting.view.backgroundColor = .clear
//        hosting.view.translatesAutoresizingMaskIntoConstraints = false
//
//        return hosting.view
//    }
//
//        private func updateChart(with data: [GameUsage]) {
//            currentData = data
//            containerView.subviews.forEach { $0.removeFromSuperview() }
//
//            let chart = makeChart(data: currentData)
//            containerView.addSubview(chart)
//
//            chart.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                chart.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
//                chart.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
//                chart.topAnchor.constraint(equalTo: containerView.topAnchor),
//                chart.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
//            ])
//        }
}
extension GamesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let category = categories[indexPath.item]

        switch category.title {
        case "Wordle":
            performSegue(withIdentifier: "Wordle", sender: nil)

        case "Crossword":
            performSegue(withIdentifier: "crossword", sender: nil)

        default:
            print("No screen connected for:", category.title)
        }
    }
}

