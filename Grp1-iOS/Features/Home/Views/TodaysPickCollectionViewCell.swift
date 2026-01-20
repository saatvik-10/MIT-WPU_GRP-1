import UIKit

class TodaysPickCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var pickLabel: UILabel!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var newsImageView: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    
    private var gradientLayer: CAGradientLayer?

    override func awakeFromNib() {
        super.awakeFromNib()
//        pageControl.numberOfPages = NewsDataStore.shared.getAllNews().count
//        pageControl.currentPage = 0
        
        contentView.clipsToBounds = true
        
        newsImageView.contentMode = .scaleAspectFill
        newsImageView.clipsToBounds = true
        pickLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        
        sourceLabel.textColor = UIColor.white.withAlphaComponent(0.85)

        headlineLabel.numberOfLines = 2
        headlineLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        headlineLabel.textColor = .white
        
        // LABEL SHADOW FOR BETTER VISIBILITY
        headlineLabel.layer.shadowColor = UIColor.black.cgColor
        headlineLabel.layer.shadowOpacity = 0.6
        headlineLabel.layer.shadowRadius = 4
        headlineLabel.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
    
    
    // MARK: - Dominant Color
    func dominantColor(from image: UIImage) -> UIColor? {
        guard let inputImage = CIImage(image: image) else { return nil }
        
        let extent = inputImage.extent
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        
        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: inputImage,
                                                 kCIInputExtentKey: CIVector(cgRect: extent)]) else { return nil }
        
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: 1)
    }
    
    
    // MARK: - Apply Gradient
    private func applyGradient(using color: UIColor) {
        
        gradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.frame = contentView.bounds
        
        gradient.colors = [
            UIColor.clear.cgColor,
            color.withAlphaComponent(0.55).cgColor,
            color.withAlphaComponent(1.0).cgColor
        ]
        
        gradient.locations = [0.0, 0.50, 1.0]
        
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint   = CGPoint(x: 0.5, y: 1)
        
        // BELOW LABELS BUT ABOVE IMAGE
        contentView.layer.insertSublayer(gradient, above: newsImageView.layer)
        
        self.gradientLayer = gradient
    }
    
    
    // MARK: - Layout Subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = contentView.bounds
    }
    
    
    // MARK: - Configure Cell
    func configureCell(with article: NewsArticle) {
        
        newsImageView.image = UIImage(named: article.imageName)
        
        if let img = newsImageView.image,
           let color = dominantColor(from: img) {
            applyGradient(using: color)
        }
        
        pickLabel.text = "Today's Pick"
        headlineLabel.text = article.title
        sourceLabel.text = article.source
    }
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        let page = Int(scrollView.contentOffset.x / scrollView.frame.width)
//        pageControl.currentPage = page
//    }
    
}
