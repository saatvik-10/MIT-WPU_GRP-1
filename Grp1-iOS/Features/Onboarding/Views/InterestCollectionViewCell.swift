import UIKit

final class InterestCollectionViewCell: UICollectionViewCell {
    private let iconCircleView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let checkmarkView = UIImageView()

    private let selectedBlue = UIColor.systemBlue
    private let paleGray = UIColor(red: 0.93, green: 0.95, blue: 0.98, alpha: 1.0)

    override var isSelected: Bool {
        didSet {
            updateSelectionUI()
        }
    }

    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12) {
                self.contentView.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.96, y: 0.96) : .identity
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.transform = .identity
    }

    private func setupUI() {
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 18
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor(red: 0.88, green: 0.90, blue: 0.94, alpha: 1.0).cgColor
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.03
        contentView.layer.shadowOffset = CGSize(width: 0, height: 4)
        contentView.layer.shadowRadius = 12
        contentView.clipsToBounds = false

        iconCircleView.translatesAutoresizingMaskIntoConstraints = false
        iconCircleView.layer.cornerRadius = 25
        iconCircleView.backgroundColor = paleGray
        iconCircleView.isUserInteractionEnabled = false

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor(red: 0.30, green: 0.35, blue: 0.43, alpha: 1.0)
        iconImageView.isUserInteractionEnabled = false

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 17, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.isUserInteractionEnabled = false

        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        checkmarkView.image = UIImage(systemName: "checkmark.circle.fill")
        checkmarkView.tintColor = selectedBlue
        checkmarkView.isHidden = true
        checkmarkView.isUserInteractionEnabled = false

        iconCircleView.addSubview(iconImageView)
        contentView.addSubview(iconCircleView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkView)

        NSLayoutConstraint.activate([
            iconCircleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconCircleView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            iconCircleView.widthAnchor.constraint(equalToConstant: 64),
            iconCircleView.heightAnchor.constraint(equalToConstant: 64),

            iconImageView.centerXAnchor.constraint(equalTo: iconCircleView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconCircleView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),

            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(equalTo: iconCircleView.bottomAnchor, constant: 18),
            titleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -14),

            checkmarkView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 18),
            checkmarkView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            checkmarkView.widthAnchor.constraint(equalToConstant: 28),
            checkmarkView.heightAnchor.constraint(equalToConstant: 28)
        ])
    }

    func configure(_ model: OnboardingInterestModel) {
        titleLabel.text = model.title
        iconImageView.image = UIImage(systemName: model.icon ?? "circle")
        accessibilityLabel = model.title
        updateSelectionUI()
    }

    private func updateSelectionUI() {
        contentView.layer.borderWidth = isSelected ? 2.5 : 1
        contentView.layer.borderColor = isSelected
            ? selectedBlue.cgColor
            : UIColor(red: 0.88, green: 0.90, blue: 0.94, alpha: 1.0).cgColor
        iconCircleView.backgroundColor = isSelected ? selectedBlue : paleGray
        iconImageView.tintColor = isSelected ? .white : UIColor(red: 0.30, green: 0.35, blue: 0.43, alpha: 1.0)
        titleLabel.textColor = isSelected ? selectedBlue : .label
        checkmarkView.isHidden = !isSelected
    }
}
