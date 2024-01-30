import SwiftUI

struct MainView: View {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject private var mainVM: MainViewModel
    @State private var selectedItemId: Int?
    
    private let columns = [
        GridItem(.adaptive(minimum: 120, maximum: 120), spacing: 1)
    ]
    
    init(mainVM: MainViewModel) {
        self.mainVM = mainVM
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                ScrollView(.vertical) {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(0..<mainVM.pictures.count, id: \.self) { index in
                            if let image = mainVM.pictures[index].image,
                               let preview = image.resize(to: CGSize(width: 50, height: 50)) {
                                Image(uiImage: preview)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .border(
                                        colorScheme == .dark
                                        ? Color.white.opacity(0.3)
                                        : Color.purple.opacity(0.3),
                                        width: 1
                                    )
                                    .cornerRadius(3)
                                    .onTapGesture {
                                        withAnimation {
                                            selectedItemId = index
                                        }
                                    }
                            } else {
                                ZStack {
                                    ProgressView()
                                        .frame(width: 45, height: 45)
                                }
                                .frame(width: 120, height: 120)
                                .background(Color.purple.opacity(0.2))
                            }
                        }
                    }
                }
                .navigationTitle("Pictures")
            }
            .navigationViewStyle(.stack)
            
            if let selectedItemId = selectedItemId {
                if let image = mainVM.pictures[selectedItemId].image {
                    DetailView(
                        selectedItemId: $selectedItemId,
                        image: image
                    )
                }
            }
        }
        .alert(isPresented: $mainVM.alertIsPresented) {
            Alert(
                title: Text(mainVM.alertTitle),
                message: Text(mainVM.alertMessage)
            )
        }
    }
}

#Preview {
    let viewModel = MainViewModel()
    viewModel.fetchData()
    return MainView(mainVM: viewModel)
}
