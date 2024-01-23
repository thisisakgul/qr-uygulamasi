import ComposableArchitecture
import SwiftUI

struct RedirectionFormView: View {
    let store: StoreOf<RedirectionFormFeature>
    @FocusState var focusedField: RedirectionFormFeature.State.Field?

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
                Section(header: Text("QR Code")) {
                    TextField("Name", text: viewStore.$name)
                        .focused($focusedField, equals: .name)
                        .disabled(viewStore.loading)

                    TextField("URL", text: viewStore.$redirectTo)
                        .focused($focusedField, equals: .redirectTo)
                        .keyboardType(.URL)
                        .textInputAutocapitalization(.never)
                        .disabled(viewStore.loading)
                }

                if (viewStore.redirection.id != nil) {
                    Section(header: Text("Action")) {
                        Button("Delete", role: .destructive) {
                            viewStore.send(.deleteButtonTapped)
                        }
                    }
                }

            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewStore.send(.cancelButtonTapped)
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text(viewStore.redirection.id == nil ? "Add QR Code" : "Update QR Code")
                        .fontWeight(.bold)
                        .accessibilityAddTraits(.isHeader)
                }

                ToolbarItem(placement: .confirmationAction) {
                    if viewStore.loading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .accent))
                    } else {
                        Button(viewStore.redirection.id == nil ? "Save" : "Update") {
                            viewStore.send(.saveButtonTapped)
                        }
                    }
                }
            }
        }
        .alert(
            store: self.store.scope(
                state: \.$alert,
                action: { .alert($0) }
            )
        )
    }
}

#Preview {
    RedirectionFormView(store: Store(initialState: RedirectionFormFeature.State(redirection: RedirectionModel(id: UUID.init(), name: "Personal Website", slug: UUID.init(), redirectTo: "https://google.com")) ) {
        RedirectionFormFeature()
    })
}
