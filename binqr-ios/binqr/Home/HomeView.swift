import ComposableArchitecture
import SwiftUI
import QRCode

struct HomeView: View {
    let store: StoreOf<HomeFeature>

    var body: some View {
        NavigationStackStore(self.store.scope(state: \.path, action: { .path($0) })) {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                List {
                    ForEach(viewStore.sortedRedirects) { redirection in
                        NavigationLink(state: RedirectionDetailFeature.State(redirection: redirection)) {
                            HStack {
                                VStack {
                                    QRCodeDocumentUIView(document: redirection.thumbnail)
                                }
                                .frame(width: 50, height: 50, alignment: .center)
                                .cornerRadius(3)

                                VStack(alignment: .leading) {
                                    Text(redirection.name)
                                        .font(.headline)
                                        .fontWeight(.bold)

                                    Text(redirection.redirectTo)
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                            }
                        }
                        .swipeActions {
                            Button("Delete") {
                                viewStore.send(.deleteButtonTapped(redirection.id))
                            }
                            .tint(.red)
                        }
                    }
                }
                .searchable(
                    text: viewStore.$query,
                    placement: .navigationBarDrawer(displayMode: .automatic),
                    prompt: "Search QR Codes..."
                )
                .overlay {
                    if viewStore.loading {
                        ProgressView("Loading...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .accent))
                    } else if viewStore.sortedRedirects.isEmpty {
                        if viewStore.query.isEmpty {
                            ContentUnavailableView {
                                Label("No QR Code", systemImage: "qrcode.viewfinder")
                            } description: {
                                Text("Your QR Codes will list here.")
                            } actions: {
                                Button("Add QR Code") {
                                    viewStore.send(.addButtonTapped)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        } else {
                            ContentUnavailableView.search(text: viewStore.query)
                        }
                    }
                }
                .refreshable {
                    await self.store.send(.loadRedirects).finish()
                }
                .navigationTitle("My QR Codes")
                .toolbar {
                    ToolbarItem {
                        Button {
                            viewStore.send(.addButtonTapped)
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .task {
                    await self.store.send(.loadRedirects).finish()
                }
            }
            .sheet(
                store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                state: /HomeFeature.Destination.State.saveRedirection,
                action: HomeFeature.Destination.Action.saveRedirection
            ) { redirectionStore in
                NavigationStack {
                    RedirectionFormView(store: redirectionStore)
                }
            }
            .alert(
                store: self.store.scope(state: \.$destination, action: { .destination($0) }),
                state: /HomeFeature.Destination.State.alert,
                action: HomeFeature.Destination.Action.alert
            )
        } destination: { store in
            RedirectionDetailView(store: store)
        }
    }
}

#Preview {
    HomeView(
        store: StoreOf<HomeFeature>(
            initialState: HomeFeature.State(redirects: [
                RedirectionModel(
                    id: UUID.init(),
                    name: "Personal Website",
                    slug: UUID.init(),
                    redirectTo: "https://google.com"
                )
            ])
        ) {
        HomeFeature()
    })
}
