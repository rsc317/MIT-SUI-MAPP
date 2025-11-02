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

    // MARK: - Init

    init(persistence: PersistenceController) {
        context = persistence.context
    }

    // MARK: - Internal

    // MARK: - Public Methods

    func fetchAll() async throws -> [MediaItemDTO] {
        let descriptor = FetchDescriptor<MediaItem>()
        let models = try context.fetch(descriptor)
        return models.map { MediaItemDTO(from: $0) }
    }

    func fetch(byId id: PersistentIdentifier) async throws -> MediaItemDTO? {
        let descriptor = FetchDescriptor<MediaItem>(predicate: #Predicate { $0.id == id })
        return try context.fetch(descriptor)
            .first
            .map { MediaItemDTO(from: $0) }
    }

    func add(_ dto: MediaItemDTO) async throws {
        _ = MediaItem.from(dto: dto, in: context)
        try context.save()
    }

    func update(_ dto: MediaItemDTO) async throws {
        guard let item = try await fetch(byUUID: dto.id) else { return }

        item.title = dto.title
        item.desc = dto.desc
        item.fileSrc = dto.fileSrc
        item.createDate = dto.createDate
        item.type = dto.type
        try context.save()
    }

    func delete(byUUID id: UUID) async throws {
        guard let item = try await fetch(byUUID: id) else { return }

        context.delete(item)
        try context.save()
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

    private let context: ModelContext
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

    private func fetch(byUUID id: UUID) async throws -> MediaItem? {
        let descriptor = FetchDescriptor<MediaItem>(
            predicate: #Predicate { $0.uuid == id }
        )

        return try context.fetch(descriptor).first
    }
}
