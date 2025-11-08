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

    init(persistence: PersistenceController, service: MediaServiceProtocol = MediaService.shared) {
        context = persistence.context
        self.service = service
    }

    // MARK: - Internal

    // MARK: - Public Methods

    func fetchAll() async throws -> [MediaItemDTO] {
        let descriptor = FetchDescriptor<MediaItem>()
        let models = try context.fetch(descriptor)
        return models.map { MediaItemDTO(from: $0) }
    }

    func save(toLocalStore: Bool, data: Data, title: String, desc: String, file: String) async throws -> MediaItemDTO {
        let model = MediaItem(title:title, desc: desc, file: file)
        if toLocalStore {
            let fileURL = documentsURL.appending(path: model.file.file, directoryHint: .notDirectory)
            try data.write(to: fileURL)
        } else {
            let dbID = try await service.uploadMedia(data: data, fileURL: model.file.url)
            model.file.dbID = String(dbID)
        }
        context.insert(model)
        try context.save()
        return MediaItemDTO(from: model)
    }

    func update(_ dto: MediaItemDTO) throws {
        guard let item = try fetch(byUUID: dto.id) else { return }

        item.title = dto.title
        item.desc = dto.desc
        item.file = MediaFile(dto.dbID, dto.file)

        try context.save()
    }

    func delete(byUUID id: UUID) async throws {
        guard let item = try fetch(byUUID: id) else { return }

        item.file.location == .local ? try await deleteImageLocal(fileName: item.file.file) : try await deleteImageExtern(dbID: item.file.dbID)
        context.delete(item)
        try context.save()
    }

    func getExternImage(dbID: String) throws -> Data? {
        nil
    }

    func getLocalImage(file: String) -> Data? {
        let fileURL = documentsURL.appending(path: file, directoryHint: .notDirectory)
        return try? Data(contentsOf: fileURL)
    }

    func updateImageExtern(data: Data, dbID: String) throws {}

    func updateImageLocal(data: Data, file: String) throws {
        let fileURL = documentsURL.appending(path: file, directoryHint: .notDirectory)
        try data.write(to: fileURL, options: .atomic)
    }

    func fetch(byUUID id: UUID) throws -> MediaItem? {
        let descriptor = FetchDescriptor<MediaItem>(
            predicate: #Predicate { $0.uuid == id }
        )

        return try context.fetch(descriptor).first
    }

    // MARK: - Private

    private let context: ModelContext
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let service: MediaServiceProtocol

    private func deleteImageExtern(dbID: String?) async throws {}

    private func deleteImageLocal(fileName: String) async throws {
        let fileURL = documentsURL.appending(path: fileName, directoryHint: .notDirectory)
        try FileManager.default.removeItem(at: fileURL)
    }
}
