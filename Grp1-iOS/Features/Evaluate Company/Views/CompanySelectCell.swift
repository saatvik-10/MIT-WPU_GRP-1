//
//  CompanySelectCell.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 18/02/26.
//

import UIKit

final class CompanySelectCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var tickImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()

        containerView.layer.cornerRadius = 20
        containerView.backgroundColor = UIColor.systemGray6
        containerView.layer.masksToBounds = false

        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        descLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descLabel.textColor = .secondaryLabel

        tickImageView.image = UIImage(systemName: "checkmark.circle.fill")
        tickImageView.tintColor = .systemBlue
        tickImageView.isHidden = true

        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    func configure(company: Company, isSelected: Bool) {
        nameLabel.text = company.name
        descLabel.text = company.description
        tickImageView.isHidden = !isSelected

        containerView.backgroundColor = isSelected
            ? UIColor.systemGray5
            : UIColor.systemGray6
    }
}
