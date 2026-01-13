import UIKit

class OnboardingContentViewController: UIViewController {

    @IBOutlet weak var stepHeaderLabel: UILabel!
    @IBOutlet weak var beginnerButton: UIButton!
    @IBOutlet weak var intermediateButton: UIButton!
    @IBOutlet weak var advancedButton: UIButton!

    @IBOutlet weak var nextButton: UIButton!
    // callback to parent (page controller)
    var onOptionSelected: ((String) -> Void)?
    var onNextTapped: (() -> Void)?
    
    var selectedButton : UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        disableNextButton()
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
                    button?.backgroundColor = .white
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
        // Reset everything first
        resetAllOptionButtons()

        // Apply selected style
        applySelectedStyle(to: sender)

        selectedButton = sender
        enableNextButton()

        guard let selectedText = sender.titleLabel?.text else { return }
        onOptionSelected?(selectedText)
    }
    
    func updateNextButtonState() {
        let isSelected = selectedButton != nil
        nextButton.isEnabled = isSelected
        nextButton.alpha = isSelected ? 1.0 : 0.5
    }
    func enableNextButton() {
            nextButton.isEnabled = true
            nextButton.alpha = 1.0
    }
    func disableNextButton() {
            nextButton.isEnabled = false
            nextButton.alpha = 0.5
    }
    func resetAllOptionButtons() {
        let buttons = [beginnerButton, intermediateButton, advancedButton]

        buttons.forEach { button in
            button?.layer.borderColor = UIColor.secondaryLabel.cgColor
            button?.layer.borderWidth = 1
            button?.backgroundColor = UIColor.white
        }
    }

    func applySelectedStyle(to button: UIButton) {
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 2
        button.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.08)
    }
    @IBAction func nextTapped(_ sender: UIButton) {
            onNextTapped?()
        }
    
}

