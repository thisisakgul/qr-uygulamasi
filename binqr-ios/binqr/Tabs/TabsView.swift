import SwiftUI

import ComposableArchitecture
 import SwiftUI

 struct TabsView: View {
     let store: StoreOf<TabsFeature>

     var body: some View {
         WithViewStore(self.store, observe: \.selectedTab) { viewStore in
             TabView(selection: viewStore.binding(send: TabsFeature.Action.tabSelected)) {
                 HomeView(store: self.store.scope(state: \.home, action: TabsFeature.Action.home))
                     .tabItem {
                         Label("QRs", systemImage: "qrcode")
                     }
                     .tag(TabsFeature.Tab.home)

                 SettingsView(store: self.store.scope(state: \.settings, action: TabsFeature.Action.settings))
                     .tabItem {
                         Label("Settings", systemImage: "gear")
                     }
                     .tag(TabsFeature.Tab.settings)

                 ProfileView(store: self.store.scope(state: \.profile, action: TabsFeature.Action.profile))
                     .tabItem {
                         Label("Profile", systemImage: "person.crop.circle")
                     }
                     .tag(TabsFeature.Tab.profile)
             }
         }
    }
 }

 #Preview {
     TabsView(store: StoreOf<TabsFeature>(initialState: TabsFeature.State()) {
         TabsFeature()
     })
 }
