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
        let model = MediaItem(title: title, desc: desc, file: file)
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

    func update(_ dto: MediaItemDTO, data: Data) throws {
        guard let model = try fetch(byUUID: dto.id) else { return }

        model.title = dto.title
        model.desc = dto.desc
        model.file = MediaFile(dto.dbID, dto.file)

        Task {
            if dto.isFileOnLocalStorage {
                try updateImageLocal(data: data, file: model.file.file)
            } else if let id = dto.dbID {
                try await updateImageExtern(data: data, dbID: id, fileURL: model.file.url)
            }
        }
        
        try context.save()
    }

    func delete(byUUID id: UUID) async throws {
        guard let item = try fetch(byUUID: id) else { return }

        item.file.location == .local ? try await deleteImageLocal(fileName: item.file.file) : try await deleteImageExtern(dbID: item.file.dbID)
        context.delete(item)
        try context.save()
    }

    func getImage(_ dto: MediaItemDTO) async throws -> Data? {
        if dto.isFileOnLocalStorage {
            let fileURL = documentsURL.appending(path: dto.file, directoryHint: .notDirectory)
            return try? Data(contentsOf: fileURL)
        } else {
            guard let dbID = dto.dbID, let id = Int(dbID) else { return nil }
            return try await service.downloadMedia(id: id)
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

        try await service.updateMedia(mediaID: id, fileData: data, fileURL: fileURL)
    }

    private func updateImageLocal(data: Data, file: String) throws {
        let fileURL = documentsURL.appending(path: file, directoryHint: .notDirectory)
        try data.write(to: fileURL, options: .atomic)
    }

    private func deleteImageExtern(dbID: String?) async throws {}

    private func deleteImageLocal(fileName: String) async throws {
        let fileURL = documentsURL.appending(path: fileName, directoryHint: .notDirectory)
        try FileManager.default.removeItem(at: fileURL)
    }
}
