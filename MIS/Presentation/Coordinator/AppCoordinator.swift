//
//  AppCoordinator.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Combine
import Observation
import SwiftUI

// MARK: - AppCoordinator -

@MainActor
@Observable final class AppCoordinator {
    // MARK: - Lifecycle

    init(container: DependencyContainerProtocol? = nil) {
        self.container = container ?? DependencyContainer()
        mediaViewModel = self.container.makeMediaItemViewModel()
    }

    // MARK: - Internal

    var path = NavigationPath()
    var sheet: Sheet?
    var fullScreenCover: FullScreenCover?

    private(set) var mediaViewModel: MediaItemViewModel

    @ViewBuilder func build(route: Route) -> some View {
        switch route {
        case .itemList:
            MediaItemListView(viewModel: mediaViewModel)
        case let .itemDetail:
            MediaItemDetailView(viewModel: mediaViewModel)
        case .map:
            MapsView(viewModel: mediaViewModel)
        case .settings:
            SettingsView()
        }
    }

    @ViewBuilder func buildSheet(sheet: Sheet) -> some View {
        switch sheet {
        case let .addOrEditNewItem:
            MediaItemAddOrEditView(viewModel: mediaViewModel)
        }
    }

    @ViewBuilder func buildCover(cover: FullScreenCover) -> some View {
        switch cover {
        case let .itemDetail:
            MediaItemDetailSheet(viewModel: mediaViewModel)
        }
    }

    // MARK: - Private

    private let container: DependencyContainerProtocol
}

// MARK: Navigation Functions

extension AppCoordinator {
    func push(route: Route) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }

        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }

    func presentSheet(_ sheet: Sheet) {
        self.sheet = sheet
    }

    func presentFullScreenCover(_ cover: FullScreenCover) {
        fullScreenCover = cover
    }

    func dismissSheet() {
        sheet = nil
    }

    func dismissCover() {
        fullScreenCover = nil
    }
}
