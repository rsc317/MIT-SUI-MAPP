//
//  AppRootView.swift
//  MIS
//
//  Created by Emircan Duman on 17.10.25.
//

import SwiftUI

struct RootView: View {
    // MARK: - Lifecycle

    init(container: DependencyContainerProtocol = DependencyContainer()) {
        _coordinator = StateObject(wrappedValue: AppCoordinator(container: container))
    }

    // MARK: - Internal

    var body: some View {
        TabView {
            NavigationStack(path: $coordinator.path) {
                coordinator.build(route: .itemList)
                    .navigationDestination(for: Route.self) { route in
                        coordinator.build(route: route)
                    }
                    .sheet(item: $coordinator.sheet) { sheet in
                        coordinator.buildSheet(sheet: sheet)
                    }
                    .fullScreenCover(item: $coordinator.fullScreenCover) { cover in
                        coordinator.buildCover(cover: cover)
                    }
            }
            .tabItem {
                Label(MediaItemLK.NAV_TITLE.localized, systemImage: "list.bullet.rectangle")
            }

            MapsView()
                .tabItem {
                    Label("Karte", systemImage: "map")
                }
        }
        .environmentObject(coordinator)
    }

    // MARK: - Private

    @StateObject private var coordinator: AppCoordinator
}
