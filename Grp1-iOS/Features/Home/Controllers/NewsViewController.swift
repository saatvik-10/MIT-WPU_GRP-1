import UIKit

class NewsViewController: UIViewController {


//    @IBOutlet weak var topImageView: UIImageView!
//    @IBOutlet weak var gradientImageView: UIImageView!
    @IBOutlet weak var gradientImageView: UIImageView!
    
    @IBOutlet weak var overviewTextLabel: UILabel!
    @IBOutlet weak var overviewView: UIView!
    @IBOutlet weak var topImageView: UIImageView!
    var article: NewsArticle?
    private var gradientApplied = false

    override func viewDidLoad() {
        super.viewDidLoad()
        overviewTextLabel.numberOfLines = 0
                overviewTextLabel.attributedText = bulletPointList(strings: [
                    "The market continued its upward move on Friday, with Nifty gaining 103 points and closing near the day’s high, showing strong buying interest throughout the session.",
                    "Bullish patterns on the daily and weekly charts indicate that the ongoing uptrend is healthy and likely to continue in the coming week.",
                    "Nifty may face resistance around the 25,400–25,550 zone, while strong support near 25,150 suggests that any pullback could be short-lived.",
                    "Overall sentiment remains positive, and dips are expected to attract fresh buying Overall sentiment remains positive, and dips are expected to attract fresh buying, keeping the market biased toward further upside."
                ])
        view.backgroundColor = .white
        overviewView.layer.cornerRadius = 25   // adjust your preferred radius
        overviewView.layer.masksToBounds = true
        setupUI()
    }
    
    func bulletPointList(strings: [String]) -> NSAttributedString {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.headIndent = 15
            paragraphStyle.firstLineHeadIndent = 0
            paragraphStyle.paragraphSpacing = 8

            let bullet = "•  "
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 17, weight: .regular),
                .paragraphStyle: paragraphStyle
            ]
            
            let string = strings.map { "\(bullet)\($0)" }.joined(separator: "\n")
            return NSAttributedString(string: string, attributes: attributes)
        }

    private func setupUI() {
        guard let article = article else { return }

        if let image = UIImage(named: article.imageName) {
            topImageView.image = image
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if !gradientApplied,
           let img = topImageView.image,
           let color = dominantColor(from: img) {

            let gradientImg = createGradientImage(
                color: color,
                size: gradientImageView.bounds.size
            )

            gradientImageView.image = gradientImg
            gradientApplied = true
        }
    }

    // MARK: - Create Smooth Gradient Image
    func createGradientImage(color: UIColor, size: CGSize) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(origin: .zero, size: size)

        gradientLayer.colors = [
            UIColor.clear.cgColor,                         // 0% - clear
            color.withAlphaComponent(0.60).cgColor,        // 45% - soft tint
            color.withAlphaComponent(1.0).cgColor,        // 60% - extended soft
            color.withAlphaComponent(1.0).cgColor,        // 80% - strong tint
            color.withAlphaComponent(0.9).cgColor,
            UIColor.white.cgColor                          // 100% - fade to white
        ]

        gradientLayer.locations = [
            0.0,   // clear
            0.25,  // soft begin
            0.50,  // extend soft
            0.65,  // strong begin
            0.70,
            1.0    // end white fade
        ]

        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint   = CGPoint(x: 0.5, y: 1.0)

        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return gradientImage
    }

    // MARK: - Dominant Color Extraction
    func dominantColor(from image: UIImage) -> UIColor? {
        guard let inputImage = CIImage(image: image) else { return nil }

        let extent = inputImage.extent
        let context = CIContext(options: [.workingColorSpace: kCFNull!])

        guard let filter = CIFilter(
            name: "CIAreaAverage",
            parameters: [
                kCIInputImageKey: inputImage,
                kCIInputExtentKey: CIVector(cgRect: extent)
            ]) else { return nil }

        guard let outputImage = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)

        context.render(
            outputImage,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: nil
        )

        return UIColor(
            red: CGFloat(bitmap[0]) / 255,
            green: CGFloat(bitmap[1]) / 255,
            blue: CGFloat(bitmap[2]) / 255,
            alpha: 1
        )
    }
}
