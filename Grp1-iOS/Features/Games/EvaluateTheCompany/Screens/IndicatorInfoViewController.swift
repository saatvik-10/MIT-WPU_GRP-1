//
//  IndicatorInfoViewController.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 24/03/26.
//

import UIKit

struct IndicatorInfo {
    let icon: String
    let iconBg: UIColor
    let name: String
    let description: String
}

class IndicatorInfoViewController: UIViewController {

    private let indicators: [IndicatorInfo] = [
        IndicatorInfo(
            icon: "chart.line.uptrend.xyaxis",
            iconBg: UIColor(red: 0.91, green: 0.96, blue: 0.87, alpha: 1),
            name: "Net Profit Margin",
            description: "How much profit a company keeps from every ₹100 of revenue. Higher is generally better."
        ),
        IndicatorInfo(
            icon: "arrow.up.right.circle",
            iconBg: UIColor(red: 0.90, green: 0.95, blue: 0.98, alpha: 1),
            name: "EPS Growth (YoY)",
            description: "Growth in earnings per share vs last year. Shows if the company is becoming more profitable over time."
        ),
        IndicatorInfo(
            icon: "scalemass",
            iconBg: UIColor(red: 0.98, green: 0.93, blue: 0.85, alpha: 1),
            name: "Debt-to-Equity",
            description: "How much the company relies on debt vs its own funds. A lower ratio means less financial risk."
        ),
        IndicatorInfo(
            icon: "tag",
            iconBg: UIColor(red: 0.98, green: 0.91, blue: 0.94, alpha: 1),
            name: "P/E Ratio",
            description: "Price investors pay for every ₹1 of earnings. High P/E can mean growth expectations are already priced in."
        )
    ]

    // MARK: - UI

    private let handleView: UIView = {
        let v = UIView()
        v.backgroundColor    = UIColor(white: 0.85, alpha: 1)
        v.layer.cornerRadius = 2.5
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text      = "Understanding the indicators"
        l.font      = UIFont.systemFont(ofSize: 20, weight: .semibold)
        l.textColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text      = "4 metrics shown on every company card"
        l.font      = UIFont.systemFont(ofSize: 16, weight: .regular)
        l.textColor = .secondaryLabel
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis      = .vertical
        sv.spacing   = 0
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        buildRows()
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(handleView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            handleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            handleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 36),
            handleView.heightAnchor.constraint(equalToConstant: 5),

            titleLabel.topAnchor.constraint(equalTo: handleView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            stackView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    private func buildRows() {
        for (i, info) in indicators.enumerated() {
            let row = makeRow(info)
            stackView.addArrangedSubview(row)

            if i < indicators.count - 1 {
                let divider = UIView()
                divider.backgroundColor = UIColor(white: 0.0, alpha: 0.06)
                divider.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                stackView.addArrangedSubview(divider)
            }
        }
    }

    private func makeRow(_ info: IndicatorInfo) -> UIView {
        // Icon
        let iconBg = UIView()
        iconBg.backgroundColor    = info.iconBg
        iconBg.layer.cornerRadius = 10
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconBg.widthAnchor.constraint(equalToConstant: 38),
            iconBg.heightAnchor.constraint(equalToConstant: 38)
        ])

        let iconImage = UIImageView()
        iconImage.image               = UIImage(systemName: info.icon)
        iconImage.tintColor           = .secondaryLabel
        iconImage.contentMode         = .scaleAspectFit
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconImage)
        NSLayoutConstraint.activate([
            iconImage.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 18),
            iconImage.heightAnchor.constraint(equalToConstant: 18)
        ])

        // Text
        let nameLabel = UILabel()
        nameLabel.text      = info.name
        nameLabel.font      = UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.textColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)

        let descLabel = UILabel()
        descLabel.text          = info.description
        descLabel.font          = UIFont.systemFont(ofSize: 14, weight: .regular)
        descLabel.textColor     = .secondaryLabel
        descLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [nameLabel, descLabel])
        textStack.axis    = .vertical
        textStack.spacing = 3

        // Row
        let row = UIStackView(arrangedSubviews: [iconBg, textStack])
        row.axis      = .horizontal
        row.spacing   = 14
        row.alignment = .top

        // Wrap in a container for padding
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        row.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(row)
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            row.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),
            row.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
        return container
    }
}
