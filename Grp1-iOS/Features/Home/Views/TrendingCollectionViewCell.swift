import UIKit

class TrendingCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    private var gradientLayer: CAGradientLayer?
    var onArticleLensTapped: (() -> Void)?
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        contentView.clipsToBounds = true
        
        newsImageView.contentMode = .scaleAspectFill
        newsImageView.clipsToBounds = true
        
        // LABELS STYLE
        sourceLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        sourceLabel.textColor = .systemGray
        timeLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        timeLabel.textColor = .systemGray

        headlineLabel.numberOfLines = 2
        headlineLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        headlineLabel.textColor = .black
        
        // LABEL SHADOW FOR BETTER VISIBILITY
//        headlineLabel.layer.shadowColor = UIColor.black.cgColor
//        headlineLabel.layer.shadowOpacity = 0.6
//        headlineLabel.layer.shadowRadius = 4
//        headlineLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    
    func configureCell(with article: NewsArticle) {
        
        newsImageView.image = UIImage(named: article.imageName)
        
        sourceLabel.text = article.source
        headlineLabel.text = article.title
        timeLabel.text = article.date
    }
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        let recommendAction = UIAction(title: "Recommend this article more",
                                       image: UIImage(systemName: "hand.thumbsup")) { _ in
            print("Recommended!")
        }

        let lensAction = UIAction(title: "Article Lens",
                                  image: UIImage(systemName: "eye")) { [weak self] _ in
            self?.onArticleLensTapped?()      // <<< call the closure
        }

        let menu = UIMenu(title: "", options: .displayInline, children: [recommendAction, lensAction])
        sender.menu = menu
        sender.showsMenuAsPrimaryAction = true
    }
}
