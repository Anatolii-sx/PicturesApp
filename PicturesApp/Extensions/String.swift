import Foundation

extension String {
    func extractURLs() -> [URL] {
        var urls: [URL] = []
        do {
            let detector = try NSDataDetector(
                types: NSTextCheckingResult.CheckingType.link.rawValue
            )
            let matches = detector.matches(
                in: self,
                options: [],
                range: NSRange(location: 0, length: self.utf16.count)
            )

            for match in matches {
                guard let range = Range(match.range, in: self) else { continue }
                let url = self[range]
                guard let url = URL(string: String(url)) else { continue }
                urls.append(url)
            }
        } catch {
            print("Error creating link detector: \(error.localizedDescription)")
        }
        return urls
    }
}
