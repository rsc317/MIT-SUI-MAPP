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

    func fetch(byUUID uuid: UUID) async throws -> MediaItem? {
        let descriptor = FetchDescriptor<MediaItem>(
            predicate: #Predicate { $0.uuid == uuid }
        )

        return try context.fetch(descriptor).first
    }

    func fetch(byId id: PersistentIdentifier) async throws -> MediaItem? {
        try await baseRepository.fetch(byId: id)
    }

    func update(_ model: MediaItem) async throws {
        guard let ctx = model.modelContext else { return }

        try ctx.save()
    }

    func saveImageLocally(_ data: Data, with fileName: String) throws -> String {
        let fileURL = documentsURL.appending(path: fileName, directoryHint: .notDirectory)
        try data.write(to: fileURL)
        return fileName
    }

    func getImageURL(for fileName: String) -> URL {
        documentsURL.appending(path: fileName, directoryHint: .notDirectory)
    }

    // MARK: - Private

    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    private let baseRepository: Repository<MediaItem>
    private let context: ModelContext
}
