//
//  MediaItemRepository.swift
//  MIS
//
//  Created by Emircan Duman on 17.10.25.
//

import Foundation
import SwiftData

final class MediaItemRepository: MediaItemRepositoryProtocol {
    // MARK: - Lifecycle

    init(persistence: PersistenceController) {
        context = persistence.makeBackgroundContext()
        baseRepository = Repository(persistence)
    }

    // MARK: - Internal

    func fetchAll() async throws -> [MediaItem] {
        try await baseRepository.fetchAll()
    }

    func add(_ model: MediaItem) async throws {
        try await baseRepository.add(model)
    }

    func delete(_ model: MediaItem) async throws {
        try await baseRepository.delete(model)
    }

    func delete(byUUID uuid: UUID) async throws {
        let descriptor = FetchDescriptor<MediaItem>(
            predicate: #Predicate { $0.uuid == uuid }
        )

        if let item = try context.fetch(descriptor).first {
            context.delete(item)
            try context.save()
        }
    }

    func fetch(byId id: PersistentIdentifier) async throws -> MediaItem? {
        try await baseRepository.fetch(byId: id)
    }

    // MARK: - Private

    private let baseRepository: Repository<MediaItem>
    private let context: ModelContext
}
