//
//  DependencyKey.swift
//  MIS
//
//  Created by Emircan Duman on 16.11.25.
//
import SwiftUI

// MARK: - Child Coordinator Keys

struct MediaItemCoordinatorKey: EnvironmentKey {
    static let defaultValue: MediaItemCoordinator = {
        let container = DependencyContainer()
        let viewModel = container.makeMediaItemViewModel()
        return MediaItemCoordinator(container: container, mediaViewModel: viewModel)
    }()
}

struct MapCoordinatorKey: EnvironmentKey {
    static let defaultValue: MapCoordinator = {
        let container = DependencyContainer()
        let viewModel = container.makeMediaItemViewModel()
        return MapCoordinator(container: container, mediaViewModel: viewModel)
    }()
}

struct SettingsCoordinatorKey: EnvironmentKey {
    static let defaultValue: SettingsCoordinator = {
        let container = DependencyContainer()
        return SettingsCoordinator(container: container)
    }()
}
