//
//  InvestGameHomeViewController.swift
//  evaluateTheCompany
//
//  Created by SDC-USER on 05/02/26.
//
 
import UIKit
 
class InvestGameHomeViewController: UIViewController {
 
    // ── Storyboard outlets ───────────────────────────────────
    @IBOutlet weak var sectorLabel: UILabel!
    @IBOutlet weak var startEvaluationButton: UIButton!
 
    private var puzzle: DailyPuzzle!
    private var collectionView: UICollectionView!
    private var flippedCards = Set<Int>()
 
    // MARK: - Lifecycle
 
    override func viewDidLoad() {
        super.viewDidLoad()
        puzzle = DailyPuzzleLoader.loadDailyPuzzle()
        setupBackground()
 //       setupTitleArea()
        setupCollectionView()
        setupHintLabel()
        styleStartButton()
    }
 
    // MARK: - Background
 
    private func setupBackground() {
        // Warm off-white — matches preview
        view.backgroundColor = UIColor(red: 0.961, green: 0.957, blue: 0.945, alpha: 1)
    }
 
    // MARK: - Title area
    // The large "Evaluate The Company" title and sector subtitle
    // are added programmatically above the collection view
    // because the storyboard scene only has a plain sector label.
 
//    private func setupTitleArea() {
//        // Style the existing storyboard sector label
//        sectorLabel?.text      = "Sector — \(puzzle.sector)"
//        sectorLabel?.font      = UIFont.systemFont(ofSize: 15, weight: .regular)
//        sectorLabel?.textColor = .secondaryLabel
//        sectorLabel?.textAlignment = .center
// 
//        // Inject the big serif title above the sector label
//        let titleLabel = UILabel()
//        titleLabel.text          = "Evaluate The\nCompany"
//        titleLabel.font          = UIFont(name: "Georgia-Bold", size: 28)
//            ?? UIFont.systemFont(ofSize: 28, weight: .bold)
//        titleLabel.textColor     = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
//        titleLabel.textAlignment = .center
//        titleLabel.numberOfLines = 2
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(titleLabel)
// 
//        guard let sector = sectorLabel else { return }
//        NSLayoutConstraint.activate([
//            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            titleLabel.bottomAnchor.constraint(equalTo: sector.topAnchor, constant: -6),
//            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
//        ])
//    }
 
    // MARK: - Collection view
 
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 14
        layout.minimumLineSpacing      = 14
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
 
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor              = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate   = self
        collectionView.register(
            UINib(nibName: "CompanyCardCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: "CompanyCardCollectionViewCell"
        )
 
        view.addSubview(collectionView)
 
        // Sits below the sector label, above the start button
        let topAnchor = sectorLabel?.bottomAnchor ?? view.safeAreaLayoutGuide.topAnchor
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90)
        ])
    }
 
    // MARK: - Hint label (below cards, above button)
 
    private func setupHintLabel() {
        // Dot icon
        let dotLabel = UILabel()
        dotLabel.text      = "↔"
        dotLabel.font      = UIFont.systemFont(ofSize: 11)
        dotLabel.textColor = .tertiaryLabel
 
        let dotBg = UIView()
        dotBg.backgroundColor    = UIColor.systemGray5
        dotBg.layer.cornerRadius = 10
        dotBg.translatesAutoresizingMaskIntoConstraints = false
        dotBg.widthAnchor.constraint(equalToConstant: 20).isActive  = true
        dotBg.heightAnchor.constraint(equalToConstant: 20).isActive = true
        dotLabel.translatesAutoresizingMaskIntoConstraints = false
        dotBg.addSubview(dotLabel)
        NSLayoutConstraint.activate([
            dotLabel.centerXAnchor.constraint(equalTo: dotBg.centerXAnchor),
            dotLabel.centerYAnchor.constraint(equalTo: dotBg.centerYAnchor)
        ])
 
        // Text
        let hintLabel = UILabel()
        hintLabel.text      = "Flip all cards to start evaluation"
        hintLabel.font      = UIFont.systemFont(ofSize: 12, weight: .regular)
        hintLabel.textColor = .tertiaryLabel
 
        // Row
        let row = UIStackView(arrangedSubviews: [dotBg, hintLabel])
        row.axis      = .horizontal
        row.spacing   = 6
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
 
        view.addSubview(row)
        NSLayoutConstraint.activate([
            row.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            row.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }
 
    // MARK: - Start button styling
 
    private func styleStartButton() {
        // Dark, locked state
        startEvaluationButton?.setTitle("Start Evaluation  →", for: .normal)
        startEvaluationButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        startEvaluationButton?.backgroundColor  = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 1)
        startEvaluationButton?.setTitleColor(.white, for: .normal)
        startEvaluationButton?.layer.cornerRadius = 16
        startEvaluationButton?.alpha = 0.4
 
        startEvaluationButton?.layer.shadowColor   = UIColor.black.cgColor
        startEvaluationButton?.layer.shadowOpacity = 0.15
        startEvaluationButton?.layer.shadowOffset  = CGSize(width: 0, height: 4)
        startEvaluationButton?.layer.shadowRadius  = 10
    }
 
    // MARK: - Segue
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showTwist",
           let vc = segue.destination as? TwistViewController {
            vc.puzzle = puzzle
        }
    }
 
    // MARK: - Start button action (connect Touch Up Inside in storyboard)
 
    @IBAction func startEvaluationTapped(_ sender: UIButton) {
        guard flippedCards.count >= puzzle.companies.count else {
            shakeButton(sender)
            return
        }
        performSegue(withIdentifier: "showTwist", sender: nil)
    }
 
    // MARK: - Flip tracking
 
    private func cardFlipped(at index: Int) {
        flippedCards.insert(index)
        guard flippedCards.count >= puzzle.companies.count else { return }
        unlockStartButton()
    }
 
    private func unlockStartButton() {
        UIView.animate(
            withDuration: 0.35, delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.5
        ) {
            self.startEvaluationButton?.alpha           = 1.0
            self.startEvaluationButton?.backgroundColor = UIColor(red: 0.18, green: 0.62, blue: 0.37, alpha: 1)
            self.startEvaluationButton?.transform       = CGAffineTransform(scaleX: 1.04, y: 1.04)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.startEvaluationButton?.transform = .identity
            }
        }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
 
    private func shakeButton(_ btn: UIButton) {
        let anim = CAKeyframeAnimation(keyPath: "transform.translation.x")
        anim.timingFunction = CAMediaTimingFunction(name: .linear)
        anim.duration       = 0.4
        anim.values         = [-8, 8, -6, 6, -4, 4, 0]
        btn.layer.add(anim, forKey: "shake")
    }
}
 
// MARK: - UICollectionViewDataSource
 
extension InvestGameHomeViewController: UICollectionViewDataSource {
 
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        puzzle.companies.count
    }
 
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CompanyCardCollectionViewCell",
            for: indexPath
        ) as? CompanyCardCollectionViewCell else {
            return UICollectionViewCell()
        }
        let company    = puzzle.companies[indexPath.item]
        let indicators = puzzle.visibleIndicators.filter { $0.companyId == company.id }
        cell.configureFront(company: company)
        cell.configureBack(indicators: indicators)
        return cell
    }
}
 
// MARK: - UICollectionViewDelegateFlowLayout
 
extension InvestGameHomeViewController: UICollectionViewDelegateFlowLayout {
 
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 20 + 20 + 14   // left inset + right inset + interitem
        let width = (collectionView.bounds.width - spacing) / 2
        return CGSize(width: width, height: width * 1.35)
    }
 
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath)
                as? CompanyCardCollectionViewCell else { return }
        cell.flip()
        cardFlipped(at: indexPath.item)
    }
}
 
