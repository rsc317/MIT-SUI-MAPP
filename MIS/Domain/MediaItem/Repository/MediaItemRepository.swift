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
    @MainActor
    func fetchAll() async throws -> [MediaItem] {
        let descriptor = FetchDescriptor<MediaItem>()
        return try context.fetch(descriptor)
    }
    
    @MainActor
    func save(shouldSaveLocal: Bool, data: Data, title: String, desc: String, file: String) async throws -> MediaItem {
        let model = MediaItem(title: title, desc: desc, file: file)
        if shouldSaveLocal {
            let fileURL = documentsURL.appending(path: model.file.file, directoryHint: .notDirectory)
            try data.write(to: fileURL)
        } else {
            let dbID = try await service.uploadMedia(data: data, fileURL: model.file.url)
            model.file.dbID = String(dbID)
        }
        ImageMemoryCache.shared.set(data, for: model.file.cacheKey)

        context.insert(model)
        try context.save()
        return model
    }

    func update(byUUID id: UUID, data: Data, title: String, desc: String) async throws {
        guard let model = try fetch(byUUID: id) else {
            throw MediaItemError.repositoryFailure("Could not fetch MediaItem with ID: \(id)")
        }

        model.title = title
        model.desc = desc

        if model.file.isLocalStorage {
            try updateImageLocal(data: data, file: model.file.file)
        } else if let id = model.file.dbID {
            try await updateImageExtern(data: data, dbID: id, fileURL: model.file.url)
        }

        try context.save()
    }

    func delete(byUUID id: UUID) async throws {
        guard let model = try fetch(byUUID: id) else {
            throw MediaItemError.repositoryFailure("Could not delete MediaItem with ID: \(id)")
        }

        model.file.location == .local ? try await deleteImageLocal(fileName: model.file.file) : try await deleteImageExtern(dbID: model.file.dbID)
        context.delete(model)
        try context.save()
    }

    func getImage(_ id: UUID) async throws -> Data? {
        do {
            guard let model = try fetch(byUUID: id) else { return nil }

            let cacheKey = model.file.cacheKey
            if let cached = ImageMemoryCache.shared.get(for: cacheKey) {
                return cached
            }
            var data: Data?
            if model.file.location == .local {
                let fileURL = documentsURL.appending(path: model.file.file, directoryHint: .notDirectory)
                data = try? Data(contentsOf: fileURL)
            } else {
                guard let dbID = model.file.dbID, let id = Int(dbID) else { return nil }

                data = try await service.downloadMedia(id: id)
            }
            if let data {
                ImageMemoryCache.shared.set(data, for: cacheKey)
            }
            return data
        } catch {
            return nil
        }
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

    private func updateImageExtern(data: Data, dbID: String, fileURL: URL) async throws {
        guard let id = Int(dbID) else { return }

        ImageMemoryCache.shared.set(data, for: dbID)
        try await service.updateMedia(mediaID: id, fileData: data, fileURL: fileURL)
    }

    private func updateImageLocal(data: Data, file: String) throws {
        let fileURL = documentsURL.appending(path: file, directoryHint: .notDirectory)
        ImageMemoryCache.shared.set(data, for: file)
        try data.write(to: fileURL, options: .atomic)
    }

    private func deleteImageExtern(dbID: String?) async throws {}

    private func deleteImageLocal(fileName: String) async throws {
        let fileURL = documentsURL.appending(path: fileName, directoryHint: .notDirectory)
        try FileManager.default.removeItem(at: fileURL)
    }
}
