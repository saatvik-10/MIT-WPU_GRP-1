//
//  ThreadsHeaderCollectionReusableView.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 12/12/25.
//

import UIKit

class ThreadsHeaderCollectionReusableView: UICollectionReusableView {

    
    @IBOutlet weak var pageTitleLabel: UILabel!
    
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var pageSegmentedControl: UISegmentedControl!
    
    var onSegmentChanged: ((Int) -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
     
        // Initialization code
        setupUI()
        setupActions()
    }
    
    private func setupUI() {

            backgroundColor = UIColor(white: 250/255, alpha: 1)

            // Title
            pageTitleLabel.text = "Threads"
            pageTitleLabel.font = UIFont.systemFont(ofSize: 26, weight: .bold)
            pageTitleLabel.textColor = .black

            // Search button
            searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
            searchButton.tintColor = .black

            // Create button (+)
            createButton.setImage(UIImage(systemName: "plus"), for: .normal)
            createButton.tintColor = .black

            // Segmented control
            pageSegmentedControl.removeAllSegments()
            pageSegmentedControl.insertSegment(withTitle: "For You", at: 0, animated: false)
            pageSegmentedControl.insertSegment(withTitle: "Following", at: 1, animated: false)
            pageSegmentedControl.insertSegment(withTitle: "My Threads", at: 2, animated: false)
            pageSegmentedControl.selectedSegmentIndex = 0

            // Segmented control styling
            pageSegmentedControl.backgroundColor = UIColor(white: 0.92, alpha: 1)
            pageSegmentedControl.selectedSegmentTintColor = .white
            pageSegmentedControl.layer.cornerRadius = 20
            pageSegmentedControl.layer.masksToBounds = true

            let textAttrs: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.darkGray,
                .font: UIFont.systemFont(ofSize: 14, weight: .medium)
            ]

            pageSegmentedControl.setTitleTextAttributes(textAttrs, for: .normal)
        }
    private func setupActions() {
            pageSegmentedControl.addTarget(
                self,
                action: #selector(segmentChanged),
                for: .valueChanged
            )
        }
        
    @objc private func segmentChanged() {
        print("HEADER segment tapped:", pageSegmentedControl.selectedSegmentIndex)
        onSegmentChanged?(pageSegmentedControl.selectedSegmentIndex)
    }
    
    func configure(selectedIndex: Int) {
        pageSegmentedControl.selectedSegmentIndex = selectedIndex
    }

}
