//
//  AppCoordinator.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import SwiftUI
import Combine


@MainActor
final class AppCoordinator: ObservableObject {
    private let container: DependencyContainerProtocol
    @Published var path = NavigationPath()
    @Published var sheet: Sheet?
    @Published var fullScreenCover: FullScreenCover?
        
    init(container: DependencyContainerProtocol? = nil) {
        self.container = container ?? DependencyContainer()
    }

    
    @ViewBuilder
    func build(route: Route) -> some View {
        switch route {
        case .itemList:
            MediaItemListView(viewModel: self.container.makeMediaItemViewModel())
        case .itemDetail(let formData):
            MediaItemDetailView(formData: formData)
        }
    }
    
    @ViewBuilder
    func buildSheet(sheet: Sheet) -> some View {
        switch sheet {
        case .addNewItem(let viewModel):
            MediaItemAddView(viewModel: viewModel)
        }
    }
    
    @ViewBuilder
    func buildCover(cover: FullScreenCover) -> some View {
        switch cover {
        case .editItem: EmptyView()
        }
    }
}

//MARK: Navigation Functions
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
        self.fullScreenCover = cover
    }
    
    func dismissSheet() {
        self.sheet = nil
    }
    
    func dismissCover() {
        self.fullScreenCover = nil
    }
}

