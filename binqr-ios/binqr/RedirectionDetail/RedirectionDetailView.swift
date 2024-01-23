import ComposableArchitecture
import SwiftUI
import QRCode

struct RedirectionDetailView: View {
    let store: StoreOf<RedirectionDetailFeature>

    var body: some View {
        WithViewStore(self.store, observe: \.redirection) { viewStore in
            VStack {
                HStack(alignment: .top) {
                    QRCodeDocumentUIView(document: viewStore.fullSize)
                }
                .padding()
                .aspectRatio(contentMode: .fit)
                .onLongPressGesture {
                    viewStore.fullSize.addToPasteboard(CGSize(width: 1024, height: 1024), dpi: 300)
                    UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                }
                
                HStack {
                    Link(destination: viewStore.url) {
                        Image(systemName: "link")
                            .foregroundColor(.blue)
                        Text(viewStore.redirectTo)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()

                HStack {
                    CustomShareLink(photo: Photo(
                        image: Image(uiImage: viewStore.fullSize.uiImage(dimension: 1024, dpi: 300)!),
                        caption: viewStore.name))

                    Button {
                        viewStore.send(.customizeButtonTapped)
                    } label: {
                        Label("Customize", systemImage: "pencil")
                            .frame(maxWidth: .infinity)
                            .frame(height: 22)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()

                Spacer()
                    .frame(height: 5)
            }
            .background(.thinMaterial)
            .navigationTitle(viewStore.name)
            .navigationBarTitleDisplayMode(.inline)
        }
        .toolbar {
            ToolbarItem {
                Button {
                    self.store.send(.editButtonTapped)
                } label: {
                    Text("Edit")
                }
            }
        }
        .task {
            await self.store.send(.loadRedirection).finish()
        }
        .sheet(
            store: self.store.scope(state: \.$destination, action: { .destination($0) }),
            state: /RedirectionDetailFeature.Destination.State.editRedirection,
            action: RedirectionDetailFeature.Destination.Action.editRedirection
        ) { editRedirectionStore in
            NavigationStack {
                RedirectionFormView(store: editRedirectionStore)
            }
        }
        .sheet(
            store: self.store.scope(state: \.$destination, action: { .destination($0) }),
            state: /RedirectionDetailFeature.Destination.State.customizeRedirection,
            action: RedirectionDetailFeature.Destination.Action.customizeRedirection
        ) { customizeRedirectionStore in
            NavigationStack {
                RedirectionCustomizeView(store: customizeRedirectionStore)
            }
        }
    }
}

struct Photo: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
            .suggestedFileName { data in
                "\(data.caption).png"
            }
    }

    var image: Image
    var caption: String
}

struct CustomShareLink: View {
    let photo: Photo
    
    var body: some View {
        ShareLink(item: photo, preview: SharePreview(photo.caption,  image: photo.image)) {
            Label("Share", systemImage: "square.and.arrow.up")
                .frame(maxWidth: .infinity)
                .frame(height: 22)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }
}


#Preview {
    RedirectionDetailView(
        store: Store(initialState: RedirectionDetailFeature.State(
            redirection: RedirectionModel(
                id: UUID.init(),
                name: "Personal Website",
                slug: UUID.init(),
                redirectTo: "https://google.com",
                configuration: RedirectionConfigurationModel()
            )
        )) {
            RedirectionDetailFeature()
        }
    )
}
