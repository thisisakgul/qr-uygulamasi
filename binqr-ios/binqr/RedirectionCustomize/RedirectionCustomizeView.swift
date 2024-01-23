import ComposableArchitecture
import SwiftUI
import QRCode

struct RedirectionCustomizeView: View {
    let store: StoreOf<RedirectionCustomizeFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                TabView(selection: viewStore.$selectedConfigOption) {
                    DesignShapeEyeView(
                        selectedShapeEye: viewStore.$selectedShapeEye,
                        shapeOnPixels: viewStore.selectedShapeOnPixels,
                        redirection: viewStore.redirection)
                    .tabItem {
                        Label("Eye shape", systemImage: "eye.square")
                    }
                    .tag(RedirectionConfigurationModel.ConfigOptions.shapeEye)

                    DesignShapeOnPixelsView(
                        selectedShapeOnPixels: viewStore.$selectedShapeOnPixels,
                        shapeEye: viewStore.selectedShapeEye,
                        redirection: viewStore.redirection)
                    .tabItem {
                        Label("Pixels", systemImage: "square.grid.3x3.square")
                    }
                    .tag(RedirectionConfigurationModel.ConfigOptions.shapeOnPixels)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewStore.send(.cancelButtonTapped)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Customize QR Code")
                        .fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)
                }

                ToolbarItem(placement: .confirmationAction) {
                    if viewStore.loading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .accent))
                    } else {
                        Button("Update") {
                            viewStore.send(.saveButtonTapped)
                        }
                    }
                }
            }
        }
    }
}

struct DesignShapeEyeView: View {
    @Binding var selectedShapeEye: RedirectionConfigurationModel.QRCodeEyeShapes
    var shapeOnPixels: RedirectionConfigurationModel.QRCodePixelShapes
    var redirection: RedirectionModel

    var body: some View {
        TabView(selection: $selectedShapeEye) {
            ForEach(RedirectionConfigurationModel.QRCodeEyeShapes.allCases, id: \.self) { value in
                QRCodeDocumentUIView(
                    document: redirection.updateDesign(
                        shapeEye: value,
                        shapeOnPixels: shapeOnPixels))
                .aspectRatio(contentMode: .fit)
                .padding()
                .tag(value)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(.thinMaterial)
    }
}

struct DesignShapeOnPixelsView: View {
    @Binding var selectedShapeOnPixels: RedirectionConfigurationModel.QRCodePixelShapes
    var shapeEye: RedirectionConfigurationModel.QRCodeEyeShapes
    var redirection: RedirectionModel

    var body: some View {
        TabView(selection: $selectedShapeOnPixels) {
            ForEach(RedirectionConfigurationModel.QRCodePixelShapes.allCases, id: \.self) { value in
                QRCodeDocumentUIView(
                    document: redirection.updateDesign(
                        shapeEye: shapeEye,
                        shapeOnPixels: value))
                    .aspectRatio(contentMode: .fit)
                    .padding()
                    .tag(value)
            }
        }
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .background(.thinMaterial)
    }
}

#Preview {
    RedirectionCustomizeView(
        store: Store(initialState: RedirectionCustomizeFeature.State(
            redirection: RedirectionModel(
                id: UUID.init(),
                name: "Personal Website",
                slug: UUID.init(),
                redirectTo: "https://google.com",
                configuration: RedirectionConfigurationModel()
            )
        )) {
            RedirectionCustomizeFeature()
        }
    )
}
