import UIKit

// MARK: - EvaluateViewController

final class EvaluateViewController: UIViewController {

    // ── Storyboard outlets (keep exactly as wired) ──
    @IBOutlet weak var twistButton: UIButton!
    @IBOutlet weak var contentContainerView: UIView!

    var puzzle: DailyPuzzle!

    // Track flipped cards to unlock Start button
    private var flippedCount = 0
    private weak var startButton: UIButton?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.961, green: 0.957, blue: 0.945, alpha: 1)
        setupUI()
    }

    // MARK: Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTwist",
           let vc = segue.destination as? TwistViewController {
            vc.puzzle = puzzle
        }
    }

    @IBAction func didtappedTwistButton(_ sender: Any) {
        // wired in storyboard
    }

    // MARK: - UI Setup

    private func setupUI() {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let contentStack = UIStackView()
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentStack.addArrangedSubview(makeHeader())
        contentStack.addArrangedSubview(makeCardsGrid())

        let hint = UILabel()
        hint.text = "Flip all cards to start evaluation"
        hint.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        hint.textColor = .tertiaryLabel
        hint.textAlignment = .center
        contentStack.addArrangedSubview(hint)

        // Bottom spacer so content clears the floating button
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 84).isActive = true
        contentStack.addArrangedSubview(spacer)

        scrollView.addSubview(contentStack)
        contentContainerView.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: contentContainerView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor),

            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        setupStartButton()
    }

    private func makeHeader() -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5
        stack.alignment = .center

        let title = UILabel()
        title.text = "Evaluate The Company"
        title.font = UIFont(name: "Georgia-Bold", size: 26)
            ?? UIFont.systemFont(ofSize: 26, weight: .bold)
        title.textAlignment = .center
        title.numberOfLines = 2
        title.textColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)

        let sector = UILabel()
        sector.text = "Sector — \(puzzle.sector)"
        sector.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        sector.textColor = .secondaryLabel
        sector.textAlignment = .center

        stack.addArrangedSubview(title)
        stack.addArrangedSubview(sector)
        return stack
    }

    private func makeCardsGrid() -> UIView {
        let outerStack = UIStackView()
        outerStack.axis = .vertical
        outerStack.spacing = 14

        let companies = puzzle.companies
        var index = 0

        while index < companies.count {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 14
            rowStack.distribution = .fillEqually

            for col in 0..<2 {
                if index + col < companies.count {
                    let company = companies[index + col]
                    let indicators = puzzle.visibleIndicators.filter { $0.companyId == company.id }
                    let card = FlipCardView(company: company, indicators: indicators)
                    card.heightAnchor.constraint(equalToConstant: 195).isActive = true
                    card.onFlip = { [weak self] in
                        self?.cardWasFlipped()
                    }
                    rowStack.addArrangedSubview(card)
                } else {
                    // Invisible filler to keep last row balanced
                    let filler = UIView()
                    filler.isHidden = true
                    rowStack.addArrangedSubview(filler)
                }
            }

            outerStack.addArrangedSubview(rowStack)
            index += 2
        }

        return outerStack
    }

    private func setupStartButton() {
        let btn = UIButton(type: .system)
        btn.setTitle("Start Evaluation  →", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 16
        btn.alpha = 0.4
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(startEvalTapped), for: .touchUpInside)

        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowOpacity = 0.15
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowRadius = 10

        contentContainerView.addSubview(btn)
        startButton = btn

        NSLayoutConstraint.activate([
            btn.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: 20),
            btn.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -20),
            btn.bottomAnchor.constraint(equalTo: contentContainerView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            btn.heightAnchor.constraint(equalToConstant: 54)
        ])
    }

    // MARK: - Card flip callback

    private func cardWasFlipped() {
        flippedCount += 1
        if flippedCount >= puzzle.companies.count {
            UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
                self.startButton?.alpha = 1.0
                self.startButton?.backgroundColor = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)
                self.startButton?.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
            } completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.startButton?.transform = .identity
                }
            }
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    @objc private func startEvalTapped() {
        guard flippedCount >= puzzle.companies.count else {
            shakeButton(startButton)
            return
        }
        performSegue(withIdentifier: "showTwist", sender: nil)
    }

    private func shakeButton(_ btn: UIButton?) {
        guard let btn = btn else { return }
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.duration = 0.4
        anim.values = [-8, 8, -6, 6, -4, 4, 0]
        btn.layer.add(anim, forKey: "shake")
    }
}


// MARK: - FlipCardView

final class FlipCardView: UIView {

    /// Fires once when the card is first flipped to back side
    var onFlip: (() -> Void)?

    private let frontView = UIView()
    private let backView  = UIView()
    private var isFlipped      = false
    private var hasCalledOnFlip = false

    // MARK: Init

    init(company: Company, indicators: [IndicatorValue]) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        buildCard(company: company, indicators: indicators)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: Build

    private func buildCard(company: Company, indicators: [IndicatorValue]) {
        layer.cornerRadius  = 18
        layer.shadowColor   = UIColor.black.cgColor
        layer.shadowOpacity = 0.08
        layer.shadowOffset  = CGSize(width: 0, height: 5)
        layer.shadowRadius  = 14

        buildFront(company: company)
        buildBack(company: company, indicators: indicators)

        backView.layer.transform = CATransform3DMakeRotation(.pi, 0, 1, 0)
        backView.isHidden = true

        for sub in [backView, frontView] {
            sub.translatesAutoresizingMaskIntoConstraints = false
            addSubview(sub)
            NSLayoutConstraint.activate([
                sub.leadingAnchor.constraint(equalTo: leadingAnchor),
                sub.trailingAnchor.constraint(equalTo: trailingAnchor),
                sub.topAnchor.constraint(equalTo: topAnchor),
                sub.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }

        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    // MARK: Front face

    private func buildFront(company: Company) {
        frontView.backgroundColor  = .systemBackground
        frontView.layer.cornerRadius = 18
        frontView.clipsToBounds    = true

        let stack = UIStackView()
        stack.axis    = .vertical
        stack.spacing = 7
        stack.translatesAutoresizingMaskIntoConstraints = false

        let nameLabel = UILabel()
        nameLabel.text          = company.name
        nameLabel.font          = UIFont(name: "Georgia-Bold", size: 16) ?? UIFont.systemFont(ofSize: 16, weight: .semibold)
        nameLabel.numberOfLines = 2
        nameLabel.textColor     = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)

        let descLabel = UILabel()
        descLabel.text          = company.description
        descLabel.font          = UIFont.systemFont(ofSize: 12, weight: .regular)
        descLabel.textColor     = .secondaryLabel
        descLabel.numberOfLines = 3

        let spacer = UIView()
        spacer.setContentHuggingPriority(.defaultLow, for: .vertical)

        let pill = makePill()

        stack.addArrangedSubview(nameLabel)
        stack.addArrangedSubview(descLabel)
        stack.addArrangedSubview(spacer)
        stack.addArrangedSubview(pill)

        frontView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: frontView.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: frontView.trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: frontView.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: frontView.bottomAnchor, constant: -14)
        ])
    }

    private func makePill() -> UIView {
        let green = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)

        let dot = UIView()
        dot.backgroundColor   = green
        dot.layer.cornerRadius = 3
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 6).isActive  = true
        dot.heightAnchor.constraint(equalToConstant: 6).isActive = true

        let lbl = UILabel()
        lbl.text      = "Tap to reveal"
        lbl.font      = UIFont.systemFont(ofSize: 11, weight: .medium)
        lbl.textColor = green

        let row = UIStackView(arrangedSubviews: [dot, lbl])
        row.axis      = .horizontal
        row.spacing   = 5
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false

        let bg = UIView()
        bg.backgroundColor    = green.withAlphaComponent(0.1)
        bg.layer.cornerRadius = 10
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: bg.leadingAnchor, constant: 9),
            row.trailingAnchor.constraint(equalTo: bg.trailingAnchor, constant: -9),
            row.topAnchor.constraint(equalTo: bg.topAnchor, constant: 5),
            row.bottomAnchor.constraint(equalTo: bg.bottomAnchor, constant: -5)
        ])
        return bg
    }

    // MARK: Back face

    private func buildBack(company: Company, indicators: [IndicatorValue]) {
        backView.backgroundColor   = UIColor(red: 0.09, green: 0.09, blue: 0.09, alpha: 1)
        backView.layer.cornerRadius = 18
        backView.clipsToBounds     = true

        let stack = UIStackView()
        stack.axis    = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false

        // Small company name header
        let nameLabel = UILabel()
        let attrs: [NSAttributedString.Key: Any] = [
            .kern: CGFloat(1.2),
            .font: UIFont.systemFont(ofSize: 9.5, weight: .semibold),
            .foregroundColor: UIColor(white: 0.4, alpha: 1)
        ]
        nameLabel.attributedText = NSAttributedString(string: company.name.uppercased(), attributes: attrs)

        let divider = UIView()
        divider.backgroundColor = UIColor(white: 0.18, alpha: 1)
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        stack.addArrangedSubview(nameLabel)
        stack.setCustomSpacing(8, after: nameLabel)
        stack.addArrangedSubview(divider)
        stack.setCustomSpacing(10, after: divider)

        for ind in indicators {
            let row = makeIndicatorRow(ind)
            stack.addArrangedSubview(row)
            stack.setCustomSpacing(8, after: row)
        }

        let flexSpacer = UIView()
        flexSpacer.setContentHuggingPriority(.defaultLow, for: .vertical)
        stack.addArrangedSubview(flexSpacer)

        let backHint = UILabel()
        backHint.text          = "tap to flip back  ↩"
        backHint.font          = UIFont.systemFont(ofSize: 9.5, weight: .regular)
        backHint.textColor     = UIColor(white: 0.28, alpha: 1)
        backHint.textAlignment = .right
        stack.addArrangedSubview(backHint)

        backView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -14),
            stack.topAnchor.constraint(equalTo: backView.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: backView.bottomAnchor, constant: -14)
        ])
    }

    private func makeIndicatorRow(_ ind: IndicatorValue) -> UIView {
        let container = UIStackView()
        container.axis    = .vertical
        container.spacing = 4

        // Label row
        let row = UIStackView()
        row.axis         = .horizontal
        row.distribution = .fill

        let nameLabel = UILabel()
        nameLabel.text      = ind.indicatorName
        nameLabel.font      = UIFont.systemFont(ofSize: 10.5, weight: .regular)
        nameLabel.textColor = UIColor(white: 0.5, alpha: 1)
        nameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let valueLabel = UILabel()
        valueLabel.text          = ind.displayValue
        valueLabel.font          = UIFont.systemFont(ofSize: 12, weight: .semibold)
        valueLabel.textColor     = UIColor(red: 0.75, green: 0.95, blue: 0.82, alpha: 1)
        valueLabel.textAlignment = .right
        valueLabel.setContentHuggingPriority(.required, for: .horizontal)

        row.addArrangedSubview(nameLabel)
        row.addArrangedSubview(valueLabel)

        // Progress bar
        let barBg = UIView()
        barBg.backgroundColor   = UIColor(white: 0.18, alpha: 1)
        barBg.layer.cornerRadius = 1.5
        barBg.heightAnchor.constraint(equalToConstant: 3).isActive = true

        let barFill = UIView()
        barFill.backgroundColor   = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)
        barFill.layer.cornerRadius = 1.5
        barFill.translatesAutoresizingMaskIntoConstraints = false
        barBg.addSubview(barFill)

        let ratio = CGFloat(numericRatio(from: ind.displayValue))
        NSLayoutConstraint.activate([
            barFill.leadingAnchor.constraint(equalTo: barBg.leadingAnchor),
            barFill.topAnchor.constraint(equalTo: barBg.topAnchor),
            barFill.bottomAnchor.constraint(equalTo: barBg.bottomAnchor),
            barFill.widthAnchor.constraint(equalTo: barBg.widthAnchor, multiplier: ratio)
        ])

        container.addArrangedSubview(row)
        container.addArrangedSubview(barBg)
        return container
    }

    // MARK: - Helpers

    /// Maps a displayValue string to a 0.04–1.0 fill ratio for the bar
    private func numericRatio(from value: String) -> Double {
        let cleaned = value
            .replacingOccurrences(of: "%", with: "")
            .replacingOccurrences(of: "₹", with: "")
            .replacingOccurrences(of: "x", with: "")
            .trimmingCharacters(in: .whitespaces)
        let num = Double(cleaned) ?? 0
        return min(max(num / 50.0, 0.04), 1.0)
    }

    // MARK: - Flip

    @objc private func handleTap() {
        let fromView = isFlipped ? backView  : frontView
        let toView   = isFlipped ? frontView : backView
        let angle    = isFlipped ? CGFloat.pi : -CGFloat.pi

        var t    = CATransform3DIdentity
        t.m34    = -1.0 / 700          // perspective depth

        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseIn) {
            fromView.layer.transform = CATransform3DRotate(t, angle / 2, 0, 1, 0)
        } completion: { _ in
            fromView.isHidden        = true
            toView.layer.transform   = CATransform3DRotate(t, -angle / 2, 0, 1, 0)
            toView.isHidden          = false

            UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseOut) {
                toView.layer.transform = CATransform3DIdentity
            }
        }

        isFlipped.toggle()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()

        if isFlipped && !hasCalledOnFlip {
            hasCalledOnFlip = true
            onFlip?()
        }
    }
}
