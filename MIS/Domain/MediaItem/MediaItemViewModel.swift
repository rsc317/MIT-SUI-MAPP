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
        Task {
            do {
                if let item = currentItem {
                    title = item.title
                    desc = item.desc ?? ""
                    file = item.file
                    selectedImageData = try await repository.getImage(item)
                }
            } catch {}
        }
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
        self.currentItem = nil
    }

    func saveNewItem(_ local: Bool = true) async {
        do {
            guard let data = selectedImageData else { return }
            let item = try await repository.save(toLocalStore: local, data: data, title: title, desc: desc, file: file)
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

            try repository.update(currentItem, data: selectedImageData)
            if let idx = items.firstIndex(where: { $0.id == currentItem.id }) {
                items[idx] = currentItem
            }
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
        }
    }

    func getImageData(for item: MediaItemDTO) async throws -> Data? {
        do {
            return try await repository.getImage(item)
        } catch {
            return nil
        }
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
