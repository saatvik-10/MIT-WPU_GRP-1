//
//  CompanyCardCellCollectionViewCell.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 17/02/26.
//

//
//  CompanyCardCollectionViewCell.swift
//  evaluateTheCompany
//
 
import UIKit
 
class CompanyCardCollectionViewCell: UICollectionViewCell {
 
    // ── XIB outlets (all connected in CompanyCardCollectionViewCell.xib) ──
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var indicatorStackView: UIStackView!
    @IBOutlet weak var indicator1Label: UILabel!
    @IBOutlet weak var indicator2Label: UILabel!
    @IBOutlet weak var indicator3Label: UILabel!
    @IBOutlet weak var indicator4Label: UILabel!
 
    private var isFlipped = false
     
        // MARK: - awakeFromNib
     
        override func awakeFromNib() {
            super.awakeFromNib()
            styleCard()
            styleFront()
            styleBack()
            injectPill()
     
            frontView.isHidden = false
            backView.isHidden  = true
            isFlipped          = false
        }
     
        // MARK: - Card shell
     
        private func styleCard() {
            // Shadow on the cell layer
            layer.cornerRadius   = 20
            layer.cornerCurve    = .continuous
            layer.masksToBounds  = false
            layer.shadowColor    = UIColor.black.cgColor
            layer.shadowOpacity  = 0.08
            layer.shadowRadius   = 12
            layer.shadowOffset   = CGSize(width: 0, height: 5)
     
            // Container clips rounded corners
            cardContainerView.layer.cornerRadius  = 20
            cardContainerView.layer.cornerCurve   = .continuous
            cardContainerView.layer.masksToBounds = true
            cardContainerView.layer.borderWidth   = 1
            cardContainerView.layer.borderColor   = UIColor.black.withAlphaComponent(0.06).cgColor
        }
     
        // MARK: - Front face
     
        private func styleFront() {
            frontView.backgroundColor = .systemBackground
     
            // Serif title — matches preview exactly
            companyNameLabel.font          = UIFont(name: "Georgia-Bold", size: 20)
                ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
            companyNameLabel.textColor     = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
            companyNameLabel.numberOfLines = 2
     
            // Description
            descLabel.font          = UIFont.systemFont(ofSize: 16, weight: .regular)
            descLabel.textColor     = .secondaryLabel
            descLabel.numberOfLines = 4
        }
     
        /// Replaces the plain "Tap to see indicators" label with a proper green pill view.
        private func injectPill() {
            guard let plainLabel = frontView.allSubviews
                .compactMap({ $0 as? UILabel })
                .first(where: { $0.text == "Tap to see indicators" })
            else { return }
     
            // Hide original
            plainLabel.isHidden = true
     
            let green = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)
     
            // Dot view
            let dot = UIView()
            dot.backgroundColor    = green
            dot.layer.cornerRadius = 3.5
            dot.translatesAutoresizingMaskIntoConstraints = false
            dot.widthAnchor.constraint(equalToConstant: 7).isActive  = true
            dot.heightAnchor.constraint(equalToConstant: 7).isActive = true
     
            // Text label
            let lbl = UILabel()
            lbl.text      = "Tap to reveal"
            lbl.font      = UIFont.systemFont(ofSize: 12, weight: .medium)
            lbl.textColor = green
     
            // Horizontal stack: dot + text
            let stack = UIStackView(arrangedSubviews: [dot, lbl])
            stack.axis      = .horizontal
            stack.spacing   = 5
            stack.alignment = .center
            stack.translatesAutoresizingMaskIntoConstraints = false
     
            // Pill container
            let pill = UIView()
            pill.backgroundColor    = green.withAlphaComponent(0.1)
            pill.layer.cornerRadius = 12
            pill.translatesAutoresizingMaskIntoConstraints = false
            pill.addSubview(stack)
     
            NSLayoutConstraint.activate([
                stack.topAnchor.constraint(equalTo: pill.topAnchor, constant: 7),
                stack.bottomAnchor.constraint(equalTo: pill.bottomAnchor, constant: -7),
                stack.leadingAnchor.constraint(equalTo: pill.leadingAnchor, constant: 11),
                stack.trailingAnchor.constraint(equalTo: pill.trailingAnchor, constant: -11),
            ])
     
            frontView.addSubview(pill)
     
            // Align pill to same position as the hidden label
            NSLayoutConstraint.activate([
                pill.centerXAnchor.constraint(equalTo: plainLabel.centerXAnchor),
                pill.centerYAnchor.constraint(equalTo: plainLabel.centerYAnchor),
            ])
        }
     
        // MARK: - Back face
     
        private func styleBack() {
            backView.backgroundColor = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
     
            // Soft mint text for indicators
            let mint = UIColor(red: 0.75, green: 0.95, blue: 0.82, alpha: 1)
            for label in [indicator1Label, indicator2Label, indicator3Label, indicator4Label] {
                label?.font          = UIFont.systemFont(ofSize: 14.5, weight: .medium)
                label?.textColor     = mint
                label?.numberOfLines = 2
            }
            indicatorStackView.spacing = 6
        }
     
        // MARK: - Configure
     
        func configureFront(company: Company) {
            companyNameLabel.text = company.name
            descLabel.text        = company.description
        }
     
        func configureBack(indicators: [IndicatorValue]) {
            let labels = [indicator1Label, indicator2Label, indicator3Label, indicator4Label]
            for (i, label) in labels.enumerated() {
                if indicators.indices.contains(i) {
                    let ind = indicators[i]
                    label?.text = "· \(ind.indicatorName)   \(ind.displayValue)"
                } else {
                    label?.text = ""
                }
            }
        }
     
        // MARK: - Flip (horizontal, matching preview)
     
        func flip() {
            let fromView = isFlipped ? backView!  : frontView!
            let toView   = isFlipped ? frontView! : backView!
            let angle    = isFlipped ? CGFloat.pi : -CGFloat.pi
     
            var t = CATransform3DIdentity
            t.m34 = -1.0 / 700          // perspective
     
            // Phase 1 — fold away
            UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseIn) {
                fromView.layer.transform = CATransform3DRotate(t, angle / 2, 0, 1, 0)
            } completion: { _ in
                fromView.isHidden      = true
                toView.layer.transform = CATransform3DRotate(t, -angle / 2, 0, 1, 0)
                toView.isHidden        = false
     
                // Phase 2 — unfold in
                UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseOut) {
                    toView.layer.transform = CATransform3DIdentity
                }
            }
     
            isFlipped.toggle()
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
     
    // MARK: - UIView helper
     
    private extension UIView {
        /// Returns all subviews recursively
        var allSubviews: [UIView] {
            subviews + subviews.flatMap { $0.allSubviews }
        }
    }
