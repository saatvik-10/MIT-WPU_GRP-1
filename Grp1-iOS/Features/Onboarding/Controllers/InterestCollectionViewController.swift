import UIKit

class InterestCollectionViewController: UIViewController {
    var onBackTapped: (() -> Void)?
    var onFinishTapped: (() -> Void)?

    @IBOutlet weak var interestCollectionView: UICollectionView!

    private let selectedBlue = UIColor.systemBlue
    private let screenBackground = UIColor(red: 0.96, green: 0.98, blue: 1.0, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
    }

    private func setupUI() {
        view.subviews.forEach { $0.removeFromSuperview() }
        view.backgroundColor = screenBackground

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "What are you interested\nin?"
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontForContentSizeCategory = true

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = "Pick the topics you'd like to track. We'll\ncustomize your investment feed based on these\nselections."
        subtitleLabel.font = .systemFont(ofSize: 18, weight: .regular)
        subtitleLabel.textColor = UIColor(red: 0.34, green: 0.40, blue: 0.51, alpha: 1.0)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 3
        subtitleLabel.lineBreakMode = .byWordWrapping

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 16

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)

        let footerView = UIView()
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.backgroundColor = screenBackground

        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setTitle("  Back", for: .normal)
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = UIColor(red: 0.34, green: 0.40, blue: 0.51, alpha: 1.0)
        backButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)

        let finishButton = UIButton(type: .system)
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.setTitle("Finish  ", for: .normal)
        finishButton.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        finishButton.semanticContentAttribute = .forceRightToLeft
        finishButton.tintColor = .white
        finishButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        finishButton.backgroundColor = selectedBlue
        finishButton.layer.cornerRadius = 22
        finishButton.layer.shadowColor = selectedBlue.cgColor
        finishButton.layer.shadowOpacity = 0.24
        finishButton.layer.shadowOffset = CGSize(width: 0, height: 8)
        finishButton.layer.shadowRadius = 16
        finishButton.addTarget(self, action: #selector(finishButtonTapped(_:)), for: .touchUpInside)

        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(collectionView)
        view.addSubview(footerView)
        footerView.addSubview(backButton)
        footerView.addSubview(finishButton)

        interestCollectionView = collectionView

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 26),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 38),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -38),

            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 120),

            collectionView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 48),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            collectionView.bottomAnchor.constraint(equalTo: footerView.topAnchor, constant: -24),

            backButton.leadingAnchor.constraint(equalTo: footerView.leadingAnchor, constant: 38),
            backButton.topAnchor.constraint(equalTo: footerView.topAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 108),
            backButton.heightAnchor.constraint(equalToConstant: 56),

            finishButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 16),
            finishButton.trailingAnchor.constraint(equalTo: footerView.trailingAnchor, constant: -38),
            finishButton.topAnchor.constraint(equalTo: backButton.topAnchor),
            finishButton.heightAnchor.constraint(equalTo: backButton.heightAnchor)
        ])
    }

    private func setupCollectionView() {
        interestCollectionView.delegate = self
        interestCollectionView.dataSource = self
        interestCollectionView.register(
            InterestCollectionViewCell.self,
            forCellWithReuseIdentifier: "InterestCollectionViewCell"
        )

        DispatchQueue.main.async { [weak self] in
            [1, 3].forEach { item in
                let indexPath = IndexPath(item: item, section: 0)
                self?.interestCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
                self?.interestCollectionView.cellForItem(at: indexPath)?.isSelected = true
            }
        }
    }

    @IBAction func backButtonTapped(_ sender: UIButton) {
        onBackTapped?()
    }

    @IBAction func finishButtonTapped(_ sender: UIButton) {
        onFinishTapped?()
    }
}

extension InterestCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        preferences.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "InterestCollectionViewCell",
            for: indexPath
        ) as! InterestCollectionViewCell
        cell.configure(preferences[indexPath.item])
        cell.isSelected = collectionView.indexPathsForSelectedItems?.contains(indexPath) == true
        return cell
    }
}

extension InterestCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let width = (collectionView.bounds.width - 16) / 2
        return CGSize(width: width, height: 156)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        20
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        16
    }
}
