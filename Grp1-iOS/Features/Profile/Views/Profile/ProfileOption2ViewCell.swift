import UIKit

// MARK: - Protocol (for the Delegate pattern)
protocol ProfileOptionCellDelegate: AnyObject {
    func didTapOption(for cell: ProfileOption2ViewCell)
}

class ProfileOption2ViewCell: UICollectionViewCell {
    
    weak var delegate: ProfileOptionCellDelegate?
    
    @IBOutlet weak var optionBtnSubtitle: UILabel!
    @IBOutlet weak var optionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        optionButton.removeTarget(nil, action: nil, for: .allEvents)
        optionButton.addTarget(self, action: #selector(optionButtonTapped), for: .touchUpInside)
    }

    @objc func optionButtonTapped() {
        delegate?.didTapOption(for: self)
    }
    
    // MARK: - Configure Function (Dynamically sets the button content)
    func configure(title: String, subTitle: String, isDestructive: Bool) {
        var config = optionButton.configuration ?? .plain()
        
        config.title = title
        optionBtnSubtitle.text = subTitle

        config.baseForegroundColor = isDestructive ? .systemRed : .label
        
        if isDestructive {
            config.image = nil
        } else {
            let chevronImage = UIImage(
                systemName: "chevron.right",
                withConfiguration: UIImage.SymbolConfiguration(scale: .small)
            )
            config.image = chevronImage
            config.imagePlacement = .trailing
            config.imagePadding = 8
        }

        optionButton.configuration = config
        optionButton.isUserInteractionEnabled = true
    }
}
