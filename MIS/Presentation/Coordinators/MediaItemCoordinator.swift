//
//  MediaItemCoordinator.swift
//  MIS
//
//  Created by Emircan Duman on 22.11.25.
//

import Observation
import SwiftUI

// MARK: - MediaItemCoordinator

@MainActor
@Observable final class MediaItemCoordinator {
    // MARK: - Lifecycle
    
    init(container: DependencyContainerProtocol, mediaViewModel: MediaItemViewModel) {
        self.container = container
        self.mediaViewModel = mediaViewModel
    }
    
    // MARK: - Internal
    
    var path = NavigationPath()
    var sheet: Sheet?
    var fullScreenCover: FullScreenCover?
    
    private(set) var mediaViewModel: MediaItemViewModel
    
    // MARK: - Navigation
    
    func push(route: MediaItemRoute) {
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
    
    // MARK: - View Building
    
    @ViewBuilder func build(route: MediaItemRoute) -> some View {
        switch route {
        case .list:
            MediaItemListView(viewModel: mediaViewModel)
        case .detail:
            MediaItemDetailView(viewModel: mediaViewModel)
        }
    }
    
    func buildSheet(sheet: Sheet) -> some View {
        switch sheet {
        case .addOrEditNewItem:
            let viewModel = container.makeMediaItemAddOrEditViewModel(mediaViewModel)
            return MediaItemAddOrEditView(viewModel: viewModel)
        }
    }
    
    @ViewBuilder func buildCover(cover: FullScreenCover) -> some View {
        switch cover {
        case .itemDetail:
            MediaItemDetailCoverView(viewModel: mediaViewModel)
        }
    }
    
    // MARK: - Private
    
    private let container: DependencyContainerProtocol
}
