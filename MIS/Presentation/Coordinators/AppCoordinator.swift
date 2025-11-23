//
//  AppCoordinator.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Observation
import SwiftUI

// MARK: - AppCoordinator

@MainActor
@Observable final class AppCoordinator {
    // MARK: - Lifecycle

    init(container: DependencyContainerProtocol? = nil) {
        let resolvedContainer = container ?? DependencyContainer()
        self.container = resolvedContainer
        let sharedMediaViewModel = resolvedContainer.makeMediaItemViewModel()
        
        mediaItemCoordinator = MediaItemCoordinator(
            container: resolvedContainer,
            mediaViewModel: sharedMediaViewModel
        )
        mapCoordinator = MapCoordinator(
            container: resolvedContainer,
            mediaViewModel: sharedMediaViewModel
        )
        settingsCoordinator = SettingsCoordinator(container: resolvedContainer)
    }

    // MARK: - Internal
    
    var mediaItemCoordinator: MediaItemCoordinator
    var mapCoordinator: MapCoordinator
    var settingsCoordinator: SettingsCoordinator
    
    // MARK: - Private

    private let container: DependencyContainerProtocol
}
