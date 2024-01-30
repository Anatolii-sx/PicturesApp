import UIKit

final class ImageProvider {
    static let shared = ImageProvider()
    private let cacheDirectory: URL?
    private let dictionaryKey = "cachedFiles"

    private init() {
        defer {
            print("📂 CacheDirectory" + String(describing: self.cacheDirectory))
        }
        
        // Получаем директорию для кэширования изображений на диск
        guard let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            print("⛔️ Failed to get cache directory ⛔️")
            self.cacheDirectory = nil
            return
        }
        
        // Расширяем url, указывая доп директорию
        self.cacheDirectory = cacheDirectory.appendingPathComponent("image_cache")
        
        // Создаем директорию для кэширования, если её не существует
        do {
            guard let cacheDirectory = self.cacheDirectory else { return }
            try FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Failed to create cache directory: \(error)")
        }
    }
    
    func fetchImage(from url: URL, completion: @escaping(Result<UIImage, Error>) -> Void) {
        // Используем изображение из кэша, если оно там есть
        if let cachedImage = getCachedImageFromDisk(by: url) {
            DispatchQueue.main.async {
                completion(.success(cachedImage))
            }
            print("⬅️ Image from cache with url: \(url)")
            return
        }

        // Если изображения нет, то грузим его из сети
        NetworkManager.shared.downloadImage(from: url) { [weak self] result in
            switch result {
            case .success(let data):
                    if let image = UIImage(data: data) {
                        print("✅ Successfully downloaded image by url: \(url)")
                        self?.saveDataToDisk(with: data, for: url)
                        completion(.success(image))
                    } else {
                        print("⛔️ Failed decoding downloaded data to UIImage by url: \(url)")
                        completion(.failure(NetworkError.noData))
                    }
            case .failure(let error):
                print("⛔️ Failed download image by url: \(url), ⁉️ reason: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    private func saveDataToDisk(with data: Data, for url: URL) {
        // Создаем уникальное имя файла
        let uniqueFileName = UUID().uuidString
        guard let filePath = cacheDirectory?.appendingPathComponent(uniqueFileName) else { return }
        // Сохраняем данные в файл
        do {
            try data.write(to: filePath)
            // Сохраняем имя файла в UserDefaults по ключу URL
            var cachedFilesDict = UserDefaults.standard.dictionary(forKey: dictionaryKey) ?? [String: String]()
            cachedFilesDict[url.absoluteString] = uniqueFileName
            UserDefaults.standard.set(cachedFilesDict, forKey: dictionaryKey)
            print("📝 SAVED IMAGE TO CACHE, path: \(filePath)")
        } catch {
            print("⛔️ Failed to save image to cache: \(error)")
        }
    }

    private func getCachedImageFromDisk(by url: URL) -> UIImage? {
        // Получаем уникальное имя файла из UserDefaults по ключу URL
        guard let cachedFilesDict = UserDefaults.standard.dictionary(forKey: dictionaryKey) as? [String: String],
              let uniqueFileName = cachedFilesDict[url.absoluteString],
              let filePath = cacheDirectory?.appendingPathComponent(uniqueFileName)
        else { return nil }
        // Проверяем существование файла
        if FileManager.default.fileExists(atPath: filePath.path) {
            // Пытаемся загрузить данные из файла
            if let data = try? Data(contentsOf: filePath) {
               return UIImage(data: data)
            }
        }
        return nil
    }
}
