//
//  TwistViewController.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 09/02/26.
//

import UIKit

final class TwistViewController: UIViewController {

    var puzzle: DailyPuzzle!

        private let mainStack = UIStackView()
        private let cagrContainer = UIView()
        private let valuesStack = UIStackView()
        private let proceedButton = UIButton(type: .system)

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .systemBackground
            setupUI()
        }

        // MARK: - Navigation
        @objc private func didTapProceed() {
            performSegue(withIdentifier: "showInvest", sender: self)
        }

        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showInvest",
               let vc = segue.destination as? InvestViewController {
                vc.puzzle = puzzle
            }
        }

        // MARK: - UI
        private func setupUI() {

            // Main vertical stack
            mainStack.axis = .vertical
            mainStack.spacing = 20
            mainStack.alignment = .center
            mainStack.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(mainStack)

            NSLayoutConstraint.activate([
                mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
                mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
            ])

//            // Title
//            let title = UILabel()
//            title.text = "Evaluate the company"
//            title.font = .boldSystemFont(ofSize: 26)
//            mainStack.addArrangedSubview(title)

            let sector = UILabel()
            sector.text = "Sector - \(puzzle.sector)"
            sector.font = .systemFont(ofSize: 24)
            sector.textColor = .secondaryLabel
            mainStack.addArrangedSubview(sector)

            // WAIT label
            let waitLabel = UILabel()
            waitLabel.text = "WAIT!"
            waitLabel.font = .boldSystemFont(ofSize: 28)
            mainStack.addArrangedSubview(waitLabel)

            let subtitle = UILabel()
            subtitle.text = "This might help your decision"
            subtitle.font = .systemFont(ofSize: 20)
            subtitle.numberOfLines = 0
            subtitle.textAlignment = .center
            mainStack.addArrangedSubview(subtitle)

            setupCAGRSection()
            setupButton()
        }

        private func setupCAGRSection() {

            cagrContainer.translatesAutoresizingMaskIntoConstraints = false
            cagrContainer.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.15)
            cagrContainer.layer.cornerRadius = 24
            cagrContainer.clipsToBounds = true

            view.addSubview(cagrContainer)

            NSLayoutConstraint.activate([
                cagrContainer.topAnchor.constraint(equalTo: mainStack.bottomAnchor, constant: 30),
                cagrContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
                cagrContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
            ])

            let cagrTitle = UILabel()
            cagrTitle.text = "5 yr CAGR"
            cagrTitle.font = .boldSystemFont(ofSize: 24)
            cagrTitle.translatesAutoresizingMaskIntoConstraints = false

            cagrContainer.addSubview(cagrTitle)

            NSLayoutConstraint.activate([
                cagrTitle.topAnchor.constraint(equalTo: cagrContainer.topAnchor, constant: 20),
                cagrTitle.centerXAnchor.constraint(equalTo: cagrContainer.centerXAnchor)
            ])

            valuesStack.axis = .vertical
            valuesStack.spacing = 16
            valuesStack.translatesAutoresizingMaskIntoConstraints = false
            cagrContainer.addSubview(valuesStack)

            NSLayoutConstraint.activate([
                valuesStack.topAnchor.constraint(equalTo: cagrTitle.bottomAnchor, constant: 20),
                valuesStack.leadingAnchor.constraint(equalTo: cagrContainer.leadingAnchor, constant: 16),
                valuesStack.trailingAnchor.constraint(equalTo: cagrContainer.trailingAnchor, constant: -16),
                valuesStack.bottomAnchor.constraint(equalTo: cagrContainer.bottomAnchor, constant: -20)
            ])

            addIndicatorPills()
        }

        private func addIndicatorPills() {

            let grouped = Dictionary(grouping: puzzle.twistIndicators, by: { $0.companyId })

            for company in puzzle.companies {

                let pill = UIView()
                pill.backgroundColor = .secondarySystemBackground
                pill.layer.cornerRadius = 20
                pill.translatesAutoresizingMaskIntoConstraints = false
                pill.heightAnchor.constraint(equalToConstant: 60).isActive = true

                let label = UILabel()
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textAlignment = .center
                label.numberOfLines = 0
                label.font = .systemFont(ofSize: 16, weight: .medium)

                let value = grouped[company.id]?.first?.displayValue ?? "—"
                label.text = "\(company.name)\n\(value)"

                pill.addSubview(label)

                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 12),
                    label.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -12),
                    label.centerYAnchor.constraint(equalTo: pill.centerYAnchor)
                ])

                valuesStack.addArrangedSubview(pill)
            }
        }

        private func setupButton() {

            proceedButton.setTitle("PROCEED TO INVEST", for: .normal)
            proceedButton.backgroundColor = UIColor.systemGreen
            proceedButton.setTitleColor(.white, for: .normal)
            proceedButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
            proceedButton.layer.cornerRadius = 28
            proceedButton.translatesAutoresizingMaskIntoConstraints = false
            proceedButton.addTarget(self, action: #selector(didTapProceed), for: .touchUpInside)

            view.addSubview(proceedButton)

            NSLayoutConstraint.activate([
                proceedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
                proceedButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
                proceedButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
                proceedButton.heightAnchor.constraint(equalToConstant: 56)
            ])
        }
    }
