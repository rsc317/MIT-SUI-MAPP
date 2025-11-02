//
//  MediaItemViewModel.swift
//  MIS
//
//  Created by Emircan Duman on 19.10.25.
//

import Combine
import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class MediaItemDetailViewModel {
    // MARK: - Lifecycle

    init(_ item: MediaItem, _ repository: MediaItemRepositoryProtocol) {
        self.repository = repository
        self.item = item
    }

    // MARK: - Internal

    var error: MediaItemError?
    var item: MediaItem

    func deleteItem(_ item: MediaItem) async {
        do {
            try await repository.delete(item)
        } catch let caughtError {
            self.error = MediaItemError.repositoryFailure(caughtError.localizedDescription)
        }
    }

    func getImageURL(_ fileSrc: String?) -> URL? {
        guard let fileSrc else { return nil }

        return repository.getImageURL(for: fileSrc)
    }

    // MARK: - Private

    private let repository: MediaItemRepositoryProtocol
}
