import SwiftUI

struct DetailView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var selectedItemId: Int?
    
    @State private var isStatusBarHidden = false
    @State private var backgroundColor: UIColor = .white
    @State private var currentScale: CGFloat = 1.0
    @State private var finalScale: CGFloat = 1.0
    @State private var position: CGSize = .zero
    
    let image: UIImage
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(uiColor: backgroundColor)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(finalScale * currentScale)
                    .offset(position)
                    .gesture(
                        MagnificationGesture()
                            .onChanged { newScale in
                                currentScale = newScale
                            }
                            .onEnded { scale in
                                finalScale *= scale
                                currentScale = 1.0
                                if finalScale < currentScale {
                                    finalScale = currentScale
                                }
                            }
                    )
                    .simultaneousGesture(
                        DragGesture()
                            .onChanged { value in
                                position = value.translation
                            }
                            .onEnded { value in
                                if abs(position.height) > 200 {
                                    selectedItemId = nil
                                } else {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                        position = .zero
                                    }
                                }
                            }
                    )
            }
            .onTapGesture {
                withAnimation {
                    isStatusBarHidden.toggle()
                    if colorScheme == .light {
                        backgroundColor = isStatusBarHidden == true ? .black : .white
                    }
                }
            }
            .navigationBarItems(
                leading:
                    Button {
                        selectedItemId = nil
                    } label: {
                        if !isStatusBarHidden {
                            Image(systemName: "chevron.left")
                                .resizable()
                                .imageScale(.large)
                        }
                    }
            )
        }
        .navigationViewStyle(.stack)
        .statusBarHidden(isStatusBarHidden)
        .onChange(of: colorScheme) { color in
            backgroundColor = color == .dark ? .black : .white
        }
        .onAppear {
            backgroundColor = colorScheme == .dark ? .black : .white
        }
        .onDisappear {
            position = .zero
            currentScale = 1.0
            finalScale = 1.0
            isStatusBarHidden = false
            backgroundColor = colorScheme == .dark ? .black : .white
        }
        .opacity(
            self.selectedItemId == nil
            ? 0
            : min(1, max(0, 1 - abs(Double(position.height) / 800)))
        )
    }
}

#Preview {
    let image = UIImage(systemName: "photo.on.rectangle.angled") ?? UIImage()
    return DetailView(
        selectedItemId: .constant(0),
        image: image
    )
}
