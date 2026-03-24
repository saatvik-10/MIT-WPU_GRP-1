//
//  GameCatergory3CollectionViewCell.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 03/02/26.
//

import UIKit

class GameCatergory3CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    private let gradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    private func setupUI() {
        contentView.layer.cornerRadius = 18
        contentView.clipsToBounds = true

        gradientLayer.cornerRadius = 18
        contentView.layer.insertSublayer(gradientLayer, at: 0)

        iconView.tintColor = .white.withAlphaComponent(0.3)
//        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)

        // Thin border
        contentView.layer.borderColor = UIColor.systemGray3.cgColor
        contentView.layer.borderWidth = 2
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = contentView.bounds
    }

    func configure(with model: GameCategory) {
        titleLabel.text = model.title
        iconView.image = model.icon
        iconView.tintColor = .systemGray.withAlphaComponent(0.8)
        descriptionLabel.text = model.description
        gradientLayer.colors = model.colors.map { $0.cgColor }
    }
}
