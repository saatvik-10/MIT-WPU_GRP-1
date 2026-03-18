//
//  Untitled.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 12/02/26.
//


import UIKit

final class ResultViewController: UIViewController {

    // MARK: – Injected by the previous screen (already wired in your project)
    var puzzle: DailyPuzzle!
    var selectedCompanyId: String!

    // MARK: – Private state
    private var data: ResultScreenData!

    // MARK: – UI root
    private let scrollView  = UIScrollView()
    private let contentView = UIView()

    // MARK: – Palette
    private enum C {
        static let green      = UIColor(red: 0.18, green: 0.75, blue: 0.42, alpha: 1)
        static let greenLight = UIColor(red: 0.90, green: 0.98, blue: 0.93, alpha: 1)
        static let red        = UIColor(red: 1.00, green: 0.27, blue: 0.23, alpha: 1)
        static let redLight   = UIColor(red: 1.00, green: 0.94, blue: 0.94, alpha: 1)
        static let redBorder  = UIColor(red: 1.00, green: 0.70, blue: 0.69, alpha: 1)
        static let teal       = UIColor(red: 0.20, green: 0.68, blue: 0.90, alpha: 1)
        static let tealLight  = UIColor(red: 0.91, green: 0.96, blue: 0.99, alpha: 1)
        static let tealBorder = UIColor(red: 0.20, green: 0.68, blue: 0.90, alpha: 0.28)
        static let gold       = UIColor(red: 1.00, green: 0.72, blue: 0.00, alpha: 1)
        static let goldLight  = UIColor(red: 1.00, green: 0.98, blue: 0.91, alpha: 1)
        static let cardBg     = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
        static let border     = UIColor(red: 0.90, green: 0.90, blue: 0.91, alpha: 1)
        static let text       = UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1)
        static let subtext    = UIColor(red: 0.42, green: 0.42, blue: 0.44, alpha: 1)
        static let orange     = UIColor(red: 1.00, green: 0.58, blue: 0.00, alpha: 1)
    }

    // MARK: – Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        guard let d = puzzle.buildResultScreenData(selectedCompanyId: selectedCompanyId) else {
            return
        }
        self.data = d

        setupScrollView()
        buildUI()
        animateEntrance()
    }

    // MARK: – ScrollView scaffold

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: – Build all sections

    private func buildUI() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -32)
        ])

        // Back button row
        stack.addArrangedSubview(makeBackRow())

        // 1. Hero banner
        stack.addArrangedSubview(padded(makeBanner(), h: 16, v: 14))

        // 2. Your Pick
        stack.addArrangedSubview(sectionLabel("Your Pick"))
        stack.addArrangedSubview(padded(makePickStrip(), h: 18, v: 0))

        // 3. Twist definition
        stack.addArrangedSubview(sectionLabel("🌀  Twist Indicator — What It Means"))
        stack.addArrangedSubview(padded(makeTwistCard(), h: 18, v: 0))

        // 4. Correlations
        stack.addArrangedSubview(sectionLabel("🔗  How \(data.twistIndicatorName) Connects"))
        stack.addArrangedSubview(padded(makeCorrelationsStack(), h: 18, v: 0))

        // 5. Best pick
        stack.addArrangedSubview(sectionLabel("🏆  Best Company to Invest In"))
        stack.addArrangedSubview(padded(makeBestCard(), h: 18, v: 0))

        // 6. Rankings
        stack.addArrangedSubview(sectionLabel("📋  Final Rankings"))
        stack.addArrangedSubview(padded(makeRankTable(), h: 18, v: 0))

        // 7. CTAs
        stack.addArrangedSubview(padded(makeCTAs(), h: 18, v: 20))
    }

    // MARK: – Section helpers

    private func makeBackRow() -> UIView {
        let row = UIView()
        let btn = UIButton(type: .system)
        btn.setTitle("‹  Back", for: .normal)
        btn.setTitleColor(C.teal, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(btn)
        NSLayoutConstraint.activate([
            btn.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
            btn.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 20),
            btn.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -4)
        ])
        return row
    }

    // ── 1. Hero Banner ──────────────────────────────────────────────────────

    private func makeBanner() -> UIView {
        let card = UIView()
        card.layer.cornerRadius = 26
        card.clipsToBounds = true

        // Gradient
        let grad = CAGradientLayer()
        grad.colors = data.isCorrect
            ? [UIColor(red:0.15,green:0.68,blue:0.38,alpha:1).cgColor, UIColor(red:0.18,green:0.75,blue:0.42,alpha:1).cgColor]
            : [UIColor(red:0.75,green:0.22,blue:0.17,alpha:1).cgColor, UIColor(red:1.00,green:0.27,blue:0.23,alpha:1).cgColor]
        grad.startPoint = CGPoint(x: 0, y: 0)
        grad.endPoint   = CGPoint(x: 1, y: 1)
        card.layer.insertSublayer(grad, at: 0)

        // Dot-grid overlay using a pattern image
        let dot = UIView()
        dot.backgroundColor = UIColor(patternImage: dotPatternImage())
        dot.alpha = 0.18
        dot.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(dot)

        let emoji = UILabel()
        emoji.text = data.isCorrect ? "🎯" : "📉"
        emoji.font = .systemFont(ofSize: 44)

        let title = UILabel()
        title.text = data.isCorrect ? "Nailed it, Analyst!" : "Close, But Not Quite!"
        title.font = .systemFont(ofSize: 22, weight: .heavy)
        title.textColor = .white
        title.numberOfLines = 0

        let msg = UILabel()
        msg.text = data.isCorrect
            ? "You read all the indicators like a pro. \(data.bestCompany.name) was the clear winner — and you saw it. Your instincts are investor-grade. 💼"
            : "The twist indicator was the key signal. A low \(data.twistIndicatorName) told the whole story. Every miss is a lesson in reading the numbers. 📖"
        msg.font = .systemFont(ofSize: 13.5, weight: .regular)
        msg.textColor = UIColor.white.withAlphaComponent(0.9)
        msg.numberOfLines = 0

        let vstack = UIStackView(arrangedSubviews: [emoji, title, msg])
        vstack.axis = .vertical
        vstack.spacing = 8
        vstack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(vstack)

        NSLayoutConstraint.activate([
            dot.topAnchor.constraint(equalTo: card.topAnchor),
            dot.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            dot.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            dot.bottomAnchor.constraint(equalTo: card.bottomAnchor),

            vstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            vstack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 22),
            vstack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -22),
            vstack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
        ])

        card.layoutIfNeeded()
        grad.frame = card.bounds

        // Update gradient frame after layout
        DispatchQueue.main.async {
            grad.frame = card.bounds
        }

        return card
    }

    // ── 2. Your Pick Strip ──────────────────────────────────────────────────

    private func makePickStrip() -> UIView {
        let card = UIView()
        card.backgroundColor = data.isCorrect ? C.greenLight : C.redLight
        card.layer.cornerRadius = 18
        card.layer.borderWidth  = 1.5
        card.layer.borderColor  = (data.isCorrect ? C.green.withAlphaComponent(0.4) : C.redBorder).cgColor

        // Left: company name + wrong/correct chip + description
        let nameLabel = UILabel()
        nameLabel.text = data.selectedCompany.name
        nameLabel.font = .systemFont(ofSize: 17, weight: .heavy)
        nameLabel.textColor = C.text

        let chip = makePill(
            text: data.isCorrect ? "Correct ✓" : "Wrong ✗",
            bg: data.isCorrect ? C.green : C.red,
            fg: .white,
            size: 10
        )

        let nameRow = UIStackView(arrangedSubviews: [nameLabel, chip])
        nameRow.axis = .horizontal
        nameRow.spacing = 8
        nameRow.alignment = .center

        let descLabel = UILabel()
        descLabel.text = data.selectedCompany.description
        descLabel.font = .systemFont(ofSize: 12.5, weight: .regular)
        descLabel.textColor = C.subtext

        let leftStack = UIStackView(arrangedSubviews: [nameRow, descLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4

        // Divider
        let divider = UIView()
        divider.backgroundColor = data.isCorrect ? C.green.withAlphaComponent(0.25) : C.redBorder
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.widthAnchor.constraint(equalToConstant: 1).isActive = true

        // Right: rank
        let rankNum = UILabel()
        let suffix = ordinalSuffix(data.selectedRank)
        rankNum.text = "\(data.selectedRank)\(suffix)"
        rankNum.font = .systemFont(ofSize: 30, weight: .heavy)
        rankNum.textColor = data.isCorrect ? C.green : C.red
        rankNum.textAlignment = .center

        let rankSub = UILabel()
        rankSub.text = "out of \(data.rankedResults.count)"
        rankSub.font = .systemFont(ofSize: 11, weight: .regular)
        rankSub.textColor = C.subtext
        rankSub.textAlignment = .center

        let rightStack = UIStackView(arrangedSubviews: [rankNum, rankSub])
        rightStack.axis = .vertical
        rightStack.spacing = 2
        rightStack.alignment = .center
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.widthAnchor.constraint(equalToConstant: 72).isActive = true

        let hstack = UIStackView(arrangedSubviews: [leftStack, divider, rightStack])
        hstack.axis = .horizontal
        hstack.spacing = 14
        hstack.alignment = .center
        hstack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(hstack)

        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            hstack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            hstack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            hstack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
        ])

        return card
    }

    // ── 3. Twist Definition Card ────────────────────────────────────────────

    private func makeTwistCard() -> UIView {
        let card = UIView()
        card.backgroundColor = C.tealLight
        card.layer.cornerRadius = 18
        card.layer.borderWidth  = 1.5
        card.layer.borderColor  = C.tealBorder.cgColor

        let titleRow = UIStackView(arrangedSubviews: [
            makeLabel(data.twistIndicatorName, size: 16, weight: .heavy, color: C.text),
            makePill(text: "Twist Metric", bg: C.teal, fg: .white, size: 9)
        ])
        titleRow.axis = .horizontal
        titleRow.spacing = 8
        titleRow.alignment = .center

        let defLabel = UILabel()
        defLabel.text = data.twistDefinition
        defLabel.font = .systemFont(ofSize: 13.5, weight: .regular)
        defLabel.textColor = C.text
        defLabel.numberOfLines = 0

        // Formula box
        let formulaBox = UIView()
        formulaBox.backgroundColor = C.teal.withAlphaComponent(0.12)
        formulaBox.layer.cornerRadius = 10

        let leftBar = UIView()
        leftBar.backgroundColor = C.teal
        leftBar.layer.cornerRadius = 1.5
        leftBar.translatesAutoresizingMaskIntoConstraints = false
        leftBar.widthAnchor.constraint(equalToConstant: 3).isActive = true

        let formulaLabel = UILabel()
        formulaLabel.text = data.twistFormula
        formulaLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        formulaLabel.textColor = UIColor(red: 0.10, green: 0.37, blue: 0.48, alpha: 1)
        formulaLabel.numberOfLines = 0

        let formulaInner = UIStackView(arrangedSubviews: [leftBar, formulaLabel])
        formulaInner.axis = .horizontal
        formulaInner.spacing = 10
        formulaInner.alignment = .center
        formulaInner.translatesAutoresizingMaskIntoConstraints = false
        formulaBox.addSubview(formulaInner)
        NSLayoutConstraint.activate([
            formulaInner.topAnchor.constraint(equalTo: formulaBox.topAnchor, constant: 10),
            formulaInner.leadingAnchor.constraint(equalTo: formulaBox.leadingAnchor, constant: 12),
            formulaInner.trailingAnchor.constraint(equalTo: formulaBox.trailingAnchor, constant: -12),
            formulaInner.bottomAnchor.constraint(equalTo: formulaBox.bottomAnchor, constant: -10),
        ])

        let vstack = UIStackView(arrangedSubviews: [titleRow, defLabel, formulaBox])
        vstack.axis = .vertical
        vstack.spacing = 10
        vstack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(vstack)

        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            vstack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            vstack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            vstack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
        ])
        return card
    }

    // ── 4. Correlations ─────────────────────────────────────────────────────

    private func makeCorrelationsStack() -> UIView {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 9

        let icons = ["📈", "💰", "⚖️", "🔬"]
        let iconColors: [UIColor] = [
            UIColor(red: 0.87, green: 0.97, blue: 0.91, alpha: 1),
            UIColor(red: 1.00, green: 0.95, blue: 0.88, alpha: 1),
            UIColor(red: 0.95, green: 0.94, blue: 1.00, alpha: 1),
            UIColor(red: 0.91, green: 0.94, blue: 1.00, alpha: 1),
        ]

        for (i, name) in data.correlatedIndicators.enumerated() {
            let icon  = icons[safe: i] ?? "📊"
            let color = iconColors[safe: i] ?? C.cardBg
            let desc  = correlationDescription(for: name)
            container.addArrangedSubview(makeCorrelationRow(icon: icon, iconBg: color, title: name, desc: desc))
        }

        return container
    }

    private func makeCorrelationRow(icon: String, iconBg: UIColor, title: String, desc: String) -> UIView {
        let card = UIView()
        card.backgroundColor = C.tealLight
        card.layer.cornerRadius = 15
        card.layer.borderWidth  = 1.5
        card.layer.borderColor  = C.tealBorder.cgColor

        let iconBox = UIView()
        iconBox.backgroundColor = iconBg
        iconBox.layer.cornerRadius = 11
        iconBox.translatesAutoresizingMaskIntoConstraints = false
        iconBox.widthAnchor.constraint(equalToConstant: 38).isActive = true
        iconBox.heightAnchor.constraint(equalToConstant: 38).isActive = true

        let iconLabel = UILabel()
        iconLabel.text = icon
        iconLabel.font = .systemFont(ofSize: 18)
        iconLabel.textAlignment = .center
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        iconBox.addSubview(iconLabel)
        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor.constraint(equalTo: iconBox.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconBox.centerYAnchor),
        ])

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .bold)
        titleLabel.textColor = C.text

        let descLabel = UILabel()
        descLabel.text = desc
        descLabel.font = .systemFont(ofSize: 12.5, weight: .regular)
        descLabel.textColor = C.subtext
        descLabel.numberOfLines = 0

        let textStack = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        textStack.axis = .vertical
        textStack.spacing = 3

        let hstack = UIStackView(arrangedSubviews: [iconBox, textStack])
        hstack.axis = .horizontal
        hstack.spacing = 12
        hstack.alignment = .top
        hstack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(hstack)

        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 13),
            hstack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            hstack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            hstack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -13),
        ])
        return card
    }

    // ── 5. Best Company Card ────────────────────────────────────────────────

    private func makeBestCard() -> UIView {
        let card = UIView()
        card.backgroundColor = C.goldLight
        card.layer.cornerRadius = 22
        card.layer.borderWidth  = 2
        card.layer.borderColor  = C.gold.cgColor

        let topRow = UIStackView()
        topRow.axis = .horizontal
        topRow.spacing = 12
        topRow.alignment = .center

        let medal = makeLabel("🥇", size: 34, weight: .regular, color: .label)
        let nameLabel = makeLabel(data.bestCompany.name, size: 19, weight: .heavy, color: C.text)
        let typeLabel = makeLabel(data.bestCompany.description, size: 12, weight: .regular, color: C.subtext)
        let nameStack = UIStackView(arrangedSubviews: [nameLabel, typeLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2
        topRow.addArrangedSubview(medal)
        topRow.addArrangedSubview(nameStack)

        // Indicator pills
        let pillsStack = UIStackView()
        pillsStack.axis = .horizontal
        pillsStack.spacing = 6
        pillsStack.alignment = .center

        // Best result twist value
        let twistVal = puzzle.twistIndicators.first(where: { $0.companyId == data.bestCompany.id })?.displayValue ?? ""
        let pillTexts = ["\(data.twistIndicatorName): \(twistVal)", "Return: \(data.bestResult.returnPercent)%"]
        for text in pillTexts {
            pillsStack.addArrangedSubview(makePill(text: text, bg: .white, fg: UIColor(red:0.42,green:0.29,blue:0,alpha:1), size: 11, border: C.gold))
        }

        // Scrollable pill row
        let pillScroll = UIScrollView()
        pillScroll.showsHorizontalScrollIndicator = false
        pillScroll.translatesAutoresizingMaskIntoConstraints = false
        pillsStack.translatesAutoresizingMaskIntoConstraints = false
        pillScroll.addSubview(pillsStack)
        NSLayoutConstraint.activate([
            pillsStack.topAnchor.constraint(equalTo: pillScroll.topAnchor),
            pillsStack.leadingAnchor.constraint(equalTo: pillScroll.leadingAnchor),
            pillsStack.trailingAnchor.constraint(equalTo: pillScroll.trailingAnchor),
            pillsStack.bottomAnchor.constraint(equalTo: pillScroll.bottomAnchor),
            pillsStack.heightAnchor.constraint(equalTo: pillScroll.heightAnchor),
            pillScroll.heightAnchor.constraint(equalToConstant: 30),
        ])

        // Reasons
        let reasonsStack = UIStackView()
        reasonsStack.axis = .vertical
        reasonsStack.spacing = 9

        for (i, reason) in data.bestReasons.enumerated() {
            reasonsStack.addArrangedSubview(makeReasonRow(num: i + 1, text: reason))
        }

        let vstack = UIStackView(arrangedSubviews: [topRow, pillScroll, reasonsStack])
        vstack.axis = .vertical
        vstack.spacing = 14
        vstack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(vstack)

        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            vstack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 18),
            vstack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -18),
            vstack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])
        return card
    }

    private func makeReasonRow(num: Int, text: String) -> UIView {
        let numCircle = UIView()
        numCircle.backgroundColor = C.gold
        numCircle.layer.cornerRadius = 10
        numCircle.translatesAutoresizingMaskIntoConstraints = false
        numCircle.widthAnchor.constraint(equalToConstant: 20).isActive = true
        numCircle.heightAnchor.constraint(equalToConstant: 20).isActive = true

        let numLabel = UILabel()
        numLabel.text = "\(num)"
        numLabel.font = .systemFont(ofSize: 10.5, weight: .heavy)
        numLabel.textColor = UIColor(red: 0.35, green: 0.24, blue: 0, alpha: 1)
        numLabel.textAlignment = .center
        numLabel.translatesAutoresizingMaskIntoConstraints = false
        numCircle.addSubview(numLabel)
        NSLayoutConstraint.activate([
            numLabel.centerXAnchor.constraint(equalTo: numCircle.centerXAnchor),
            numLabel.centerYAnchor.constraint(equalTo: numCircle.centerYAnchor),
        ])

        let textLabel = UILabel()
        textLabel.text = text
        textLabel.font = .systemFont(ofSize: 13, weight: .regular)
        textLabel.textColor = C.text
        textLabel.numberOfLines = 0

        let row = UIStackView(arrangedSubviews: [numCircle, textLabel])
        row.axis = .horizontal
        row.spacing = 9
        row.alignment = .top
        return row
    }

    // ── 6. Rankings Table ───────────────────────────────────────────────────

    private func makeRankTable() -> UIView {
        let card = UIView()
        card.backgroundColor = C.cardBg
        card.layer.cornerRadius = 18
        card.clipsToBounds = true

        let vstack = UIStackView()
        vstack.axis = .vertical
        vstack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(vstack)

        NSLayoutConstraint.activate([
            vstack.topAnchor.constraint(equalTo: card.topAnchor),
            vstack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            vstack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            vstack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
        ])

        for (i, entry) in data.rankedResults.enumerated() {
            let row = makeRankRow(entry: entry)
            vstack.addArrangedSubview(row)

            // Separator (except after last)
            if i < data.rankedResults.count - 1 {
                let sep = UIView()
                sep.backgroundColor = C.border
                sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
                vstack.addArrangedSubview(sep)
            }
        }
        return card
    }

    private func makeRankRow(entry: RankedEntry) -> UIView {
        let row = UIView()
        row.backgroundColor = entry.isUserPick
            ? (data.isCorrect ? C.greenLight : C.redLight)
            : (entry.isBest ? C.goldLight : .clear)

        let medals  = ["🥇","🥈","🥉","4️⃣","5️⃣"]
        let medalLbl = makeLabel(medals[safe: entry.rank - 1] ?? "\(entry.rank)", size: 18, weight: .regular, color: .label)
        medalLbl.translatesAutoresizingMaskIntoConstraints = false
        medalLbl.widthAnchor.constraint(equalToConstant: 26).isActive = true

        let nameLbl = UILabel()
        // Append YOU tag inline if user pick
        if entry.isUserPick {
            let base = NSMutableAttributedString(
                string: entry.company.name + "  ",
                attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: C.text]
            )
            let tag = NSAttributedString(
                string: " YOU ",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 9, weight: .heavy),
                    .foregroundColor: UIColor.white,
                    .backgroundColor: data.isCorrect ? C.green : C.red
                ]
            )
            base.append(tag)
            nameLbl.attributedText = base
        } else {
            nameLbl.text = entry.company.name
            nameLbl.font = .systemFont(ofSize: 14, weight: .bold)
            nameLbl.textColor = C.text
        }

        let descLbl = makeLabel(entry.company.description, size: 11.5, weight: .regular, color: C.subtext)

        let leftStack = UIStackView(arrangedSubviews: [nameLbl, descLbl])
        leftStack.axis = .vertical
        leftStack.spacing = 2

        // Twist value colored
        let twistColor: UIColor
        switch entry.rank {
        case 1:    twistColor = C.green
        case 2, 3: twistColor = C.orange
        default:   twistColor = C.red
        }
        let cagrLbl = makeLabel(entry.twistValue, size: 14, weight: .heavy, color: twistColor)
        cagrLbl.textAlignment = .right
        let cagrSub = makeLabel(data.twistIndicatorName, size: 10, weight: .regular, color: C.subtext)
        cagrSub.textAlignment = .right
        let rightStack = UIStackView(arrangedSubviews: [cagrLbl, cagrSub])
        rightStack.axis = .vertical
        rightStack.spacing = 1
        rightStack.translatesAutoresizingMaskIntoConstraints = false
        rightStack.widthAnchor.constraint(equalToConstant: 60).isActive = true

        let hstack = UIStackView(arrangedSubviews: [medalLbl, leftStack, rightStack])
        hstack.axis = .horizontal
        hstack.spacing = 12
        hstack.alignment = .center
        hstack.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(hstack)

        NSLayoutConstraint.activate([
            hstack.topAnchor.constraint(equalTo: row.topAnchor, constant: 13),
            hstack.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            hstack.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
            hstack.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -13),
        ])
        return row
    }

    // ── 7. CTA Buttons ──────────────────────────────────────────────────────

    private func makeCTAs() -> UIView {
        let nextBtn = makeButton(title: "▶   Try Next Round", bg: C.green, fg: .white)
        nextBtn.addTarget(self, action: #selector(nextRoundTapped), for: .touchUpInside)

        let homeBtn = makeButton(title: "🏠   Return to Home", bg: C.cardBg, fg: C.text)
        homeBtn.addTarget(self, action: #selector(homeTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [nextBtn, homeBtn])
        stack.axis = .vertical
        stack.spacing = 10
        return stack
    }

    // MARK: – Reusable UI builders

    private func sectionLabel(_ text: String) -> UIView {
        let wrapper = UIView()
        let lbl = UILabel()
        lbl.text = text
        lbl.font = .systemFont(ofSize: 10.5, weight: .bold)
        lbl.textColor = C.subtext
        lbl.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 20),
            lbl.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 20),
            lbl.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -20),
            lbl.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -8),
        ])
        return wrapper
    }

    private func makeLabel(_ text: String, size: CGFloat, weight: UIFont.Weight, color: UIColor) -> UILabel {
        let l = UILabel()
        l.text = text
        l.font = .systemFont(ofSize: size, weight: weight)
        l.textColor = color
        l.numberOfLines = 0
        return l
    }

    private func makePill(text: String, bg: UIColor, fg: UIColor, size: CGFloat, border: UIColor? = nil) -> UIView {
        let pill = UILabel()
        pill.text = "  \(text)  "
        pill.font = .systemFont(ofSize: size, weight: .bold)
        pill.textColor = fg
        pill.backgroundColor = bg
        pill.layer.cornerRadius = 10
        pill.clipsToBounds = true
        if let b = border {
            pill.layer.borderWidth = 1.5
            pill.layer.borderColor = b.cgColor
        }
        return pill
    }

    private func makeButton(title: String, bg: UIColor, fg: UIColor) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(fg, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        btn.backgroundColor = bg
        btn.layer.cornerRadius = 16
        btn.heightAnchor.constraint(equalToConstant: 52).isActive = true
        if bg == C.green {
            btn.layer.shadowColor  = C.green.cgColor
            btn.layer.shadowOffset = CGSize(width: 0, height: 6)
            btn.layer.shadowRadius = 12
            btn.layer.shadowOpacity = 0.35
        }
        return btn
    }

    private func padded(_ view: UIView, h: CGFloat, v: CGFloat) -> UIView {
        let wrapper = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        wrapper.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: v),
            view.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: h),
            view.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -h),
            view.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -v),
        ])
        return wrapper
    }

    // MARK: – Dot pattern for banner overlay

    private func dotPatternImage() -> UIImage {
        let size = CGSize(width: 20, height: 20)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.white.setFill()
        UIBezierPath(ovalIn: CGRect(x: 8, y: 8, width: 3, height: 3)).fill()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return img
    }

    // MARK: – Correlation descriptions

    private func correlationDescription(for indicatorName: String) -> String {
        let twist = data.twistIndicatorName
        switch indicatorName {
        case "EPS Growth (YoY)":
            return "\(twist) compounds EPS growth over 5 years. A high \(twist) validates consistent EPS expansion — not a single lucky quarter."
        case "Net Profit Margin":
            return "Sustained \(twist) forces operational efficiency. Companies scaling fast without margin expansion eventually hit a wall."
        case "P/E Ratio":
            return "Higher \(twist) justifies a premium P/E — investors pay more for proven compounders. But watch for overvaluation."
        case "Debt-to-Equity":
            return "High-\(twist) companies fund growth internally, reducing reliance on debt. A rising D/E alongside low CAGR is a red flag."
        default:
            return "\(twist) is directly correlated with \(indicatorName). Both move together as the company's fundamental quality improves."
        }
    }

    // MARK: – Ordinal suffix

    private func ordinalSuffix(_ n: Int) -> String {
        switch n {
        case 1: return "st"
        case 2: return "nd"
        case 3: return "rd"
        default: return "th"
        }
    }

    // MARK: – Entrance animation

    private func animateEntrance() {
        contentView.alpha = 0
        contentView.transform = CGAffineTransform(translationX: 0, y: 30)
        UIView.animate(withDuration: 0.5, delay: 0.05, usingSpringWithDamping: 0.85, initialSpringVelocity: 0, options: .curveEaseOut) {
            self.contentView.alpha = 1
            self.contentView.transform = .identity
        }
    }

    // MARK: – Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func nextRoundTapped() {
        // Pop to root (or navigate to next puzzle — adjust as needed)
        navigationController?.popToRootViewController(animated: true)
    }

    @objc private func homeTapped() {
        navigationController?.popToRootViewController(animated: true)
    }
}

// MARK: – Safe array subscript

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}













//import UIKit
//
//final class ResultViewController: UIViewController {
//
//    var puzzle: DailyPuzzle!
//    var selectedCompanyId: String!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        let bestId = puzzle.bestCompanyId()
//
//            if selectedCompanyId == bestId {
//                print("User chose correctly ✅")
//            } else {
//                print("User chose wrong ❌")
//            }
//
//     //   showResult()
//    }
//
////    private func showResult() {
////        guard
////            let result = puzzle.results.first(where: { $0.companyId == selectedCompanyId })
////        else { return }
////
////        print("Return:", result.returnPercent)
////        print("Explanation:", result.explanation)
////    }
//}
