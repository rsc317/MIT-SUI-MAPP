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

    init(_ item: MediaItemDTO, _ repository: MediaItemRepositoryProtocol) {
        self.repository = repository
        self.item = item
    }

    // MARK: - Internal

    var error: MediaItemError?
    var item: MediaItemDTO

    func deleteItem() async {
        do {
            try await repository.delete(byUUID: item.id)
        } catch let caughtError {
            self.error = MediaItemError.repositoryFailure(caughtError.localizedDescription)
        }
    }

    func getImage() async throws -> Data? {
        do {
            return try await repository.getImage(item)
        } catch {
            return nil
        }
    }

    // MARK: - Private

    private let repository: MediaItemRepositoryProtocol
}
