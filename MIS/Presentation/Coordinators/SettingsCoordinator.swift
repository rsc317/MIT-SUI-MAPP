//
//  SettingsCoordinator.swift
//  MIS
//
//  Created by Emircan Duman on 22.11.25.
//

import Observation
import SwiftUI

// MARK: - SettingsCoordinator

@MainActor
@Observable final class SettingsCoordinator {
    // MARK: - Lifecycle
    
    init(container: DependencyContainerProtocol) {
        self.container = container
    }
    
    // MARK: - Internal
    
    var path = NavigationPath()
    
    // MARK: - Navigation
    
    func push(route: SettingsRoute) {
        path.append(route)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    // MARK: - View Building
    
    @ViewBuilder func build(route: SettingsRoute) -> some View {
        switch route {
        case .main:
            SettingsView(viewModel: container.makeSettingsViewModel())
        }
    }
    
    // MARK: - Private
    
    private let container: DependencyContainerProtocol
}
