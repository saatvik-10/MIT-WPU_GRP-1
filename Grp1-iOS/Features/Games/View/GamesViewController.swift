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
        ),
        .init(
            title: "Guess the Order",
            icon: UIImage(systemName: "list.number")!,
            colors: [
                UIColor(red: 0.98, green: 0.86, blue: 0.35, alpha: 1), // soft yellow
                UIColor(red: 0.78, green: 0.62, blue: 0.18, alpha: 1)  // mustard
            ]
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
        setupSegmentedControl()
        showWeekly()
        styleChartOuterView()
    }
    private func styleChartOuterView() {
        ChartOuterView.layer.cornerRadius = 20
        ChartOuterView.layer.masksToBounds = false

        // Adaptive background (light / dark)
        ChartOuterView.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor.systemGray6
            : UIColor.white
        }

        // Soft card shadow (Apple-style)
        ChartOuterView.layer.shadowColor = UIColor.black.cgColor
        ChartOuterView.layer.shadowOpacity = 0.12
        ChartOuterView.layer.shadowOffset = CGSize(width: 0, height: 6)
        ChartOuterView.layer.shadowRadius = 14

        // Performance + crisp shadow
        ChartOuterView.layer.shouldRasterize = true
        ChartOuterView.layer.rasterizationScale = UIScreen.main.scale
    }
    
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
                item.contentInsets = .init(top: 12, leading: 12, bottom: 12, trailing: 12)

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
            return gridCategories.count
        } else {
            return 1
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

            cell.configure(with: fullWidthCategory)
            return cell
        }
    }
    private func setupSegmentedControl() {
            segmentedControl.removeAllSegments()
            segmentedControl.insertSegment(withTitle: "Weekly", at: 0, animated: false)
            segmentedControl.insertSegment(withTitle: "Monthly", at: 1, animated: false)
            segmentedControl.insertSegment(withTitle: "Yearly", at: 2, animated: false)
            segmentedControl.selectedSegmentIndex = 0
        }

        @IBAction func segmentChanged(_ sender: UISegmentedControl) {
            switch sender.selectedSegmentIndex {
            case 0: showWeekly()
            case 1: showMonthly()
            case 2: showYearly()
            default: break
            }
        }

        private func showWeekly() {
            updateChart(with: weeklyData)
        }

        private func showMonthly() {
            updateChart(with: monthlyData)
        }

        private func showYearly() {
            updateChart(with: yearlyData)
        }
    private func makeChart(data: [GameUsage]) -> UIView {
        let chartView = GameUsageChart(data: data)
        let hosting = UIHostingController(rootView: chartView)

        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false

        return hosting.view
    }

        private func updateChart(with data: [GameUsage]) {
            currentData = data
            containerView.subviews.forEach { $0.removeFromSuperview() }

            let chart = makeChart(data: currentData)
            containerView.addSubview(chart)

            chart.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                chart.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                chart.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                chart.topAnchor.constraint(equalTo: containerView.topAnchor),
                chart.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        }
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


