import UIKit

class ProfileOption2ViewCell: UICollectionViewCell {

    
    @IBOutlet weak var optionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }


    func configure(title: String, isDestructive: Bool) {
        var config = optionButton.configuration ?? .plain()
        config.title = title

        // apply red text if destructive
        config.baseForegroundColor = isDestructive ? .systemRed : .label

        // hide arrow icon for logout
        if isDestructive {
            config.image = nil
        }

        optionButton.configuration = config
    }
}
