//
//  MediaItemViewModel.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Combine
import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class MediaItemViewModel {
    // MARK: - Lifecycle

    // MARK: - Init

    init(_ repository: MediaItemRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Internal

    var items = [MediaItemDTO]()
    var error: MediaItemError?

    var currentItem: MediaItemDTO?
    var selectedImageData: Data?
    var title = ""
    var file = ""
    var desc = ""

    func onAppearAction() {
        do {
            if let item = currentItem {
                title = item.title
                desc = item.desc ?? ""
                file = item.file
                if item.isFileOnLocalStorage {
                    selectedImageData = try repository.getLocalImage(fileName: item.file)
                } else if let id = item.dbID {
                    selectedImageData = try repository.getExternImage(dbID: id)
                }
            }
        } catch {}
    }

    func onDisappearAction() {
        error = nil
        currentItem = nil
        selectedImageData = nil
        title = ""
        file = ""
    }

    func loadItems() {
        Task {
            do {
                self.items = try await repository.fetchAll()
            } catch {
                self.error = .repositoryFailure(error.localizedDescription)
            }
        }
    }

    func deleteItem(_ item: MediaItemDTO) async {
        do {
            try await repository.delete(byUUID: item.id)
            items.removeAll { $0.id == item.id }
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
        }
    }

    func deleteCurrentItem() async {
        guard let currentItem else { return }

        await deleteItem(currentItem)
        await deleteImage(item: currentItem)
        self.currentItem = nil
    }

    func saveNewItem(_ local: Bool = true) async {
        do {
            guard let data = selectedImageData else { return }

            if local {
                try await repository.saveImageLocal(data: data, fileName: file)
            }

            let item = MediaItemDTO(id: UUID(), dbID: nil, createDate: Date(), location: .local, title: title, desc: desc, file: file)
            try await repository.save(item)
            items.append(item)
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
        }
    }

    func updateItem() {
        do {
            self.currentItem?.title = title
            self.currentItem?.desc = desc
            guard let currentItem, let selectedImageData else { return }
            
            if currentItem.isFileOnLocalStorage {
                try repository.updateImageLocal(data: selectedImageData, fileName: file)
            } else if let id = currentItem.dbID {
                try repository.updateImageExtern(data: selectedImageData, dbID: id)
            }

            try repository.update(currentItem)
            if let idx = items.firstIndex(where: { $0.id == currentItem.id }) {
                items[idx] = currentItem
            }
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
        }
    }

    func getImageData(for item: MediaItemDTO) -> Data? {
        do {
            if item.isFileOnLocalStorage {
                return try repository.getLocalImage(fileName: item.file)
            } else if let id = item.dbID {
                return try repository.getExternImage(dbID: id)
            }
            return nil
        } catch {
            return nil
        }
    }

    func updateImage(_ data: Data, item: MediaItemDTO) {
        do {
            if item.isFileOnLocalStorage {
                try repository.updateImageLocal(data: data, fileName: item.file)
            } else if let id = item.dbID {
                try repository.updateImageExtern(data: data, dbID: id)
            }
        } catch {}
    }

    func deleteImage(item: MediaItemDTO) async {
        do {
            if item.isFileOnLocalStorage {
                try await repository.deleteImageLocal(fileName: item.file)
            } else if let id = item.dbID {
                try await repository.deleteImageExtern(dbID: id)
            }
        } catch {}
    }

    func prepareMediaItem(_ data: Data?, _ ext: String) {
        Task {
            guard let data else { return }

            selectedImageData = data
            title.isEmpty ? title = "media_\(UUID().uuidString.prefix(8))" : ()
            file.isEmpty ? file = "\(title).\(ext)" : ()
        }
    }

    // MARK: - Private

    private let repository: MediaItemRepositoryProtocol
}
