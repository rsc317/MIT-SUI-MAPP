//
//  MediaItemRepository.swift
//  MIS
//
//  Created by Emircan Duman on 17.10.25.
//

import SwiftData

final class MediaItemRepository: MediaItemRepositoryProtocol {
    private let baseRepository: Repository<MediaItem>

    init(persistence: PersistenceController) {
        self.baseRepository = Repository(persistence)
    }

    func fetchAll() async throws -> [MediaItem] {
        try await baseRepository.fetchAll()
    }

    func add(_ model: MediaItem) async throws {
        try await baseRepository.add(model)
    }

    func delete(_ model: MediaItem) async throws {
        try await baseRepository.delete(model)
    }

    func fetch(byId id: PersistentIdentifier) async throws -> MediaItem? {
        try await baseRepository.fetch(byId: id)
    }
}
