//
//  MapViewModel.swift
//  MIS
//
//  Created by Emircan Duman on 22.11.25.
//

import Combine
import Foundation

@MainActor
@Observable final class MapViewModel {
    // MARK: - Lifecycle

    init(_ items: [MediaItemDTO], _ repository: MediaItemRepositoryProtocol) {
        self.repository = repository
        self.items = items
    }

    // MARK: - Internal

    var items: [MediaItemDTO]
    var selectedItemID: UUID?

    // MARK: - Private

    private let repository: MediaItemRepositoryProtocol
}
