import SwiftUI

@main
struct PicturesApp: App {
    @StateObject private var mainVM = MainViewModel()
    
    var body: some Scene {
        WindowGroup {
            MainView(mainVM: mainVM)
                .task {
                    mainVM.fetchData()
                }
        }
    }
}
