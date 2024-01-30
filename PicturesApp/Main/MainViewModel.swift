import Foundation

final class MainViewModel: ObservableObject {
    @Published var pictures: [Picture] = []
    @Published var alertIsPresented = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    func fetchData() {
        NetworkManager.shared.downloadURLs { [weak self] result in
            switch result {
            case .success(let urls): self?.handleSuccessDownloadURLs(urls)
            case .failure(let error): self?.handleFailureDownloadURLs(error)
            }
        }
    }
    
    private func handleSuccessDownloadURLs(_ urls: [URL]) {
        for url in urls {
            DispatchQueue.main.async { [weak self] in
                self?.pictures.append(Picture(url: url, image: nil))
            }
            ImageProvider.shared.fetchImage(from: url) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    var notFetchedIds: [Int] = []
                    for (index, picture) in self.pictures.enumerated() {
                        if picture.url == url {
                            switch result {
                            case .success(let image):
                                self.pictures[index].image = image
                            case .failure(let error):
                                notFetchedIds.append(index)
                            }
                        }
                    }
                    notFetchedIds.forEach {
                        if self.pictures.indices.contains($0) {
                            self.pictures.remove(at: $0)
                        }
                    }
                }
            }
        }
    }
    
    private func handleFailureDownloadURLs(_ error: NetworkError) {
        switch error {
        case .other(let description):
            self.showAlert(title: "Downloading URLs error", message: description)
        default:
            self.showAlert(title: "Downloading URLs error", message: "\(error)")
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !self.alertIsPresented {
                self.alertTitle = title
                self.alertMessage = message
                self.alertIsPresented = true
            }
        }
    }
}
