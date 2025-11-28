import UIKit

class ProfileOptionViewCell: UICollectionViewCell {

    @IBOutlet weak var optionButton: UIButton!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    func configure(title: String, level: Int, progress: Float) {
        var config = optionButton.configuration ?? .plain()
        config.title = "\(title))"
        optionButton.configuration = config

        progressView.progress = progress
    }
}
