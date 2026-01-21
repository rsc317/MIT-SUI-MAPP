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
        _coordinator = State(initialValue: AppCoordinator(container: container))
    }

    // MARK: - Internal

    // MARK: - Body

    var body: some View {
        TabView {
            NavigationStack(path: $coordinator.mediaItemCoordinator.path) {
                coordinator.mediaItemCoordinator.build(route: .list)
                    .navigationDestination(for: MediaItemRoute.self) { route in
                        coordinator.mediaItemCoordinator.build(route: route)
                    }
                    .sheet(item: $coordinator.mediaItemCoordinator.sheet) { sheet in
                        coordinator.mediaItemCoordinator.buildSheet(sheet: sheet)
                    }
                    .fullScreenCover(item: $coordinator.mediaItemCoordinator.fullScreenCover) { cover in
                        coordinator.mediaItemCoordinator.buildCover(cover: cover)
                    }
            }
            .tabItem {
                Label(MediaItemLK.NAV_TITLE.localized, systemImage: "list.bullet.rectangle")
            }
            .environment(\.mediaItemCoordinator, coordinator.mediaItemCoordinator)

            NavigationStack(path: $coordinator.mapCoordinator.path) {
                coordinator.mapCoordinator.build(route: .map)
                    .navigationDestination(for: MapRoute.self) { route in
                        coordinator.mapCoordinator.build(route: route)
                    }
                    .fullScreenCover(item: $coordinator.mapCoordinator.fullScreenCover) { cover in
                        coordinator.mapCoordinator.buildCover(cover: cover)
                    }
            }
            .tabItem {
                Label("Karte", systemImage: "map")
            }
            .environment(\.mapCoordinator, coordinator.mapCoordinator)

            NavigationStack(path: $coordinator.settingsCoordinator.path) {
                coordinator.settingsCoordinator.build(route: .main)
                    .navigationDestination(for: SettingsRoute.self) { route in
                        coordinator.settingsCoordinator.build(route: route)
                    }
            }
            .tabItem {
                Label("Einstellungen", systemImage: "gearshape")
            }
            .environment(\.settingsCoordinator, coordinator.settingsCoordinator)
        }
    }

    // MARK: - Private

    @State private var coordinator: AppCoordinator
}
