import UIKit

class OnboardingContentViewController: UIViewController {

    @IBOutlet weak var stepHeaderLabel: UILabel!
    @IBOutlet weak var beginnerButton: UIButton!
    @IBOutlet weak var intermediateButton: UIButton!
    @IBOutlet weak var advancedButton: UIButton!

    // callback to parent (page controller)
    var onOptionSelected: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Setup
    func setupUI() {
        // header styling
        stepHeaderLabel.layer.cornerRadius = 12
        stepHeaderLabel.layer.masksToBounds = true

        // prepare a default configuration to apply to all buttons
        let buttons = [beginnerButton, intermediateButton, advancedButton]

                buttons.forEach { button in
                    button?.layer.cornerRadius = 12
                    button?.contentHorizontalAlignment = .left
                    button?.titleLabel?.numberOfLines = 0
                    button?.layer.borderWidth = 0.5
                    button?.layer.borderColor = UIColor.secondaryLabel.cgColor
                }
    }
    
    func setButtonText(
        button: UIButton,
        title: String,
        subtitle: String
    ) {
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold),
            .foregroundColor: button.tintColor ?? UIColor.label
        ]

        let subtitleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.secondaryLabel
        ]

        let attributedText = NSMutableAttributedString(
            string: title + "\n",
            attributes: titleAttributes
        )

        attributedText.append(
            NSAttributedString(
                string: subtitle,
                attributes: subtitleAttributes
            )
        )

        button.setAttributedTitle(attributedText, for: .normal)
    }

    // MARK: - Configure with model
    func configure(with page: OnboardingPage) {
        print("OPTIONS COUNT:", page.options.count)

        guard page.options.count >= 3 else { return }

        setButtonText(
            button: beginnerButton,
            title: page.options[0].title,
            subtitle: page.options[0].subtitle
        )

        setButtonText(
            button: intermediateButton,
            title: page.options[1].title,
            subtitle: page.options[1].subtitle
        )

        setButtonText(
            button: advancedButton,
            title: page.options[2].title,
            subtitle: page.options[2].subtitle
        )
    }

    // MARK: - Actions
    @IBAction func optionTapped(_ sender: UIButton) {
        // prefer configuration.title (works with UIButton.Configuration)
        guard let selected = sender.configuration?.title else { return }
        print("Selected Option: \(selected)")
        onOptionSelected?(selected)
    }
}

