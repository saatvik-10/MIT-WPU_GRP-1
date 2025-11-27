import UIKit

class ExploreCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pickLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    private var gradientLayer: CAGradientLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 7
        contentView.layer.masksToBounds = true
        
        contentView.clipsToBounds = true
        
        newsImageView.contentMode = .scaleAspectFill
        newsImageView.layer.cornerRadius = 7
        newsImageView.layer.masksToBounds = true
        newsImageView.clipsToBounds = true
        
        // LABELS STYLE
        pickLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        pickLabel.textColor = .systemGray

        headlineLabel.numberOfLines = 2
        headlineLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        headlineLabel.textColor = .black
        
        timeLabel.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        timeLabel.textColor = .systemGray
        
        // LABEL SHADOW FOR BETTER VISIBILITY
//        headlineLabel.layer.shadowColor = UIColor.black.cgColor
//        headlineLabel.layer.shadowOpacity = 0.6
//        headlineLabel.layer.shadowRadius = 4
//        headlineLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    
    func configureCell(with article: NewsArticle) {
        
        newsImageView.image = UIImage(named: article.imageName)
        
        
        pickLabel.text = article.source
        headlineLabel.text = article.title
        timeLabel.text = article.date
    }
    @IBAction func moreButtonTapped(_ sender: UIButton) {
        let recommendAction = UIAction(title: "Recommend this article more",
                                           image: UIImage(systemName: "hand.thumbsup")) { _ in
                print("Recommended!")
            }

            let lensAction = UIAction(title: "Article Lens",
                                      image: UIImage(systemName: "circle.dotted.circle")) { _ in
                print("Article Lens launched!")
            }

            let menu = UIMenu(title: "", options: .displayInline, children: [recommendAction, lensAction])

            sender.menu = menu
            sender.showsMenuAsPrimaryAction = true
        
    }
}
