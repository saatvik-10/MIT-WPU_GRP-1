import UIKit

class ExploreCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pickLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    
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
        
        // LABEL SHADOW FOR BETTER VISIBILITY
//        headlineLabel.layer.shadowColor = UIColor.black.cgColor
//        headlineLabel.layer.shadowOpacity = 0.6
//        headlineLabel.layer.shadowRadius = 4
//        headlineLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    
    func configureCell(with article: NewsArticle) {
        
        newsImageView.image = UIImage(named: article.imageName)
        
        
        pickLabel.text = "Today's Pick"
        headlineLabel.text = article.title
    }
}
