//
//  ETRSSService.swift
//  Grp1-iOS
//
//  Created by SDC-USER on 05/03/26.
//




import Foundation

// MARK: - ET RSS Parser

final class ETRSSParser: NSObject, XMLParserDelegate {

    private var items: [RSSItem] = []
    private var currentItem: RSSItem?
    private var currentElement = ""
    private var buffer = ""

    func parse(data: Data) -> [RSSItem] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName
        buffer = ""

        if elementName == "item" {
            currentItem = RSSItem()
        }

        // ET images come via <enclosure url="...cms" type="image/jpeg" />
        if elementName == "enclosure",
           let url = attributeDict["url"],
           currentItem?.imageURL.isEmpty == true {
            currentItem?.imageURL = url
        }

        // Some ET feeds also use <media:content url="..." />
        if elementName == "media:content",
           let url = attributeDict["url"],
           currentItem?.imageURL.isEmpty == true {
            currentItem?.imageURL = url
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        buffer += string
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        guard currentItem != nil else { return }
        let value = buffer.trimmingCharacters(in: .whitespacesAndNewlines)

        switch elementName {
        case "title":
            currentItem?.title += value

        case "description":
            currentItem?.description += value.stripHTML()

        case "link":
            // ET <link> nodes can emit the channel URL before any item starts.
            // Only accept it when it actually looks like an article (.cms suffix).
            if value.lowercased().hasSuffix(".cms") {
                currentItem?.link += value
            }

        case "pubDate":
            currentItem?.pubDate += value

        case "item":
            if let item = currentItem, !item.link.isEmpty {
                items.append(item)
            }
            currentItem = nil

        default:
            break
        }
    }
}

// MARK: - ET RSS Service

final class ETRSSService {

    static let shared = ETRSSService()
    private init() {}

    private let etRSSURL =
        "https://economictimes.indiatimes.com/markets/stocks/rssfeeds/2146842.cms"

    func fetchETNews(completion: @escaping ([RSSItem]) -> Void) {

        guard let url = URL(string: etRSSURL) else {
            completion([])
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion([])
                return
            }

            let parser = ETRSSParser()
            let items = parser.parse(data: data)

            DispatchQueue.main.async {
                completion(items)
            }
        }.resume()
    }
}

// MARK: - ET HTML Article Body Extractor
//
// ET runs on the exact same Bennett Coleman CMS as TOI.
// Both use data-articlebody as the article wrapper in HTML.
// So we just call extractTOIArticleBody() — no duplication needed.

extension String {
    func extractETArticleBody(minWords: Int = 12) -> String {
        return self.extractTOIArticleBody(minWords: minWords)
    }
}

