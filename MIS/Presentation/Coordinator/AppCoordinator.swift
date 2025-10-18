//
//  AppCoordinator.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Combine
import SwiftUI
import Observation
// MARK: - AppCoordinator -

@MainActor
@Observable
final class AppCoordinator {
    // MARK: - Lifecycle

    init(container: DependencyContainerProtocol? = nil) {
        self.container = container ?? DependencyContainer()
    }

    // MARK: - Internal

    var path = NavigationPath()
    var sheet: Sheet?
    var fullScreenCover: FullScreenCover?

    @ViewBuilder
    func build(route: Route) -> some View {
        switch route {
        case .itemList:
            MediaItemListView(viewModel: self.container.makeMediaItemViewModel())
        case .itemDetail:
            EmptyView()
        }
    }

    @ViewBuilder
    func buildSheet(sheet: Sheet) -> some View {
        switch sheet {
        case let .addNewItem(viewModel):
            MediaItemAddView(viewModel: viewModel)
        }
    }

    @ViewBuilder
    func buildCover(cover: FullScreenCover) -> some View {
        switch cover {
        case .editItem: EmptyView()
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
