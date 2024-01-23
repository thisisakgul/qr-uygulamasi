import ComposableArchitecture
import SwiftUI

struct ProfileView: View {
    let store: StoreOf<ProfileFeature>

    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
                HStack {
                        Text("EA")
                             .font (.title)
                             .fontWeight(.semibold)
                             .foregroundColor(.white)
                             .frame(width: 72, height: 72)
                             .background (Color(.systemGray3))
                             .clipShape (Circle())
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Emir AKGÜL")
                            .font (.subheadline)
                            .fontWeight(.semibold)
                            .padding(.top, 4)
                        Text(viewStore.email)
                            .font (.footnote)
                            .accentColor(.gray)
                    }
                    }
                Section(header: Text("Action")) {
                    Button("Logout", role: .destructive) {
                        viewStore.send(.logoutButtonTapped)
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    ProfileView(store: StoreOf<ProfileFeature>(initialState: ProfileFeature.State()) {
        ProfileFeature()
    })
}
