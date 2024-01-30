import UIKit

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case other(String)
}

final class NetworkManager {
    static let shared = NetworkManager()
    private let txtFileURL = URL(string: "https://files.apkcdn.com/images.txt")
    private init() {}
    
    func downloadURLs(completion: @escaping(Result<[URL], NetworkError>) -> Void) {
        guard let url = txtFileURL else {
            completion(.failure(.invalidURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.other(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299) ~= httpResponse.statusCode
            else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data,
                  let stringWithURLs = String(data: data, encoding: .utf8)
            else {
                completion(.failure(.noData))
                return
            }
            
            let extractedUrls = stringWithURLs.extractURLs()
            
            if extractedUrls.isEmpty {
                completion(.failure(.noData))
            } else {
                print("✅ Successfully download URLs")
                completion(.success(extractedUrls))
            }
        }.resume()
    }
    
    func downloadImage(from url: URL, completion: @escaping(Result<Data, NetworkError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.other(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                      (200...299) ~= httpResponse.statusCode,
                      url == httpResponse.url
            else {
                completion(.failure(.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            
            DispatchQueue.main.async {
                completion(.success(data))
            }
        }.resume()
    }
}
