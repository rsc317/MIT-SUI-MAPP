//
//  EnviormentValue+Extension.swift
//  MIS
//
//  Created by Emircan Duman on 16.11.25.
//

import SwiftUI

// MARK: - Child Coordinator Environment Keys

extension EnvironmentValues {
    var mediaItemCoordinator: MediaItemCoordinator {
        get { self[MediaItemCoordinatorKey.self] }
        set { self[MediaItemCoordinatorKey.self] = newValue }
    }

    var mapCoordinator: MapCoordinator {
        get { self[MapCoordinatorKey.self] }
        set { self[MapCoordinatorKey.self] = newValue }
    }

    var settingsCoordinator: SettingsCoordinator {
        get { self[SettingsCoordinatorKey.self] }
        set { self[SettingsCoordinatorKey.self] = newValue }
    }
}
