import UIKit

extension UIImageView {

    static let imageCache = NSCache<NSString, UIImage>()

    func setSmartImage(from imageNameOrURL: String) {

        if imageNameOrURL.lowercased().hasSuffix(".cms"),
           let url = URL(string: imageNameOrURL) {

            loadImageFromURL(url)
            return
        }

        self.image = UIImage(named: imageNameOrURL)
    }

    private func loadImageFromURL(_ url: URL) {

        if let cached = UIImageView.imageCache.object(
            forKey: url.absoluteString as NSString
        ) {
            self.image = cached
            return
        }

        self.image = UIImage(named: "placeholder")

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard
                let self = self,
                let data = data,
                let image = UIImage(data: data)
            else { return }

            UIImageView.imageCache.setObject(
                image,
                forKey: url.absoluteString as NSString
            )

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
