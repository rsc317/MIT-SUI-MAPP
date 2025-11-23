//
//  MapCoordinator.swift
//  MIS
//
//  Created by Emircan Duman on 22.11.25.
//

import Observation
import SwiftUI

// MARK: - MapCoordinator

@MainActor
@Observable final class MapCoordinator {
    // MARK: - Lifecycle
    
    init(container: DependencyContainerProtocol, mediaViewModel: MediaItemViewModel) {
        self.container = container
        self.mediaViewModel = mediaViewModel
    }
    
    // MARK: - Internal
    
    var path = NavigationPath()
    var fullScreenCover: FullScreenCover?
    
    private(set) var mediaViewModel: MediaItemViewModel
    
    // MARK: - Navigation
    
    func push(route: MapRoute) {
        path.append(route)
    }
    
    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    func presentFullScreenCover(_ cover: FullScreenCover) {
        fullScreenCover = cover
    }
    
    func dismissCover() {
        fullScreenCover = nil
    }
    
    // MARK: - View Building
    
    @ViewBuilder func build(route: MapRoute) -> some View {
        switch route {
        case .map:
            MapsView(viewModel: mediaViewModel)
        case .detail:
            MediaItemDetailView(viewModel: mediaViewModel)
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
