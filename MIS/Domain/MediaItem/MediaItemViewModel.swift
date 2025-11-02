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

    init(_ repository: MediaItemRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Internal

    var items = [MediaItem]()
    var selectedItem: MediaItem?
    var newItem: MediaItem?
    var selectedImageData: Data?
    var error: MediaItemError?

    func loadItems() {
        Task {
            do {
                self.items = try await repository.fetchAll()
            } catch let caughtError {
                self.error = MediaItemError.repositoryFailure(caughtError.localizedDescription)
            }
        }
    }

    func deleteItem(_ item: MediaItem) async {
        do {
            try await repository.delete(item)
            items.removeAll { $0.id == item.id }
        } catch let caughtError {
            self.error = MediaItemError.repositoryFailure(caughtError.localizedDescription)
        }
    }

    func deleteSelectedItem() async {
        guard let selectedItem else { return }

        await deleteItem(selectedItem)
        self.selectedItem = nil
    }

    func addItem() async {
        guard let newItem else { return }

        do {
            let item = MediaItem(
                title: newItem.title,
                desc: newItem.desc,
                fileSrc: newItem.fileSrc,
                createDate: newItem.createDate,
                type: newItem.type
            )
            try await repository.add(item)
            items.append(item)
        } catch let caughtError {
            self.error = MediaItemError.repositoryFailure(caughtError.localizedDescription)
        }
    }

    func addImageToLocal(_ name: String) async -> String {
        var defaultUrl = URL(fileURLWithPath: "defaultPicture").lastPathComponent
        do {
            if let selectedImageData {
                defaultUrl = try repository.saveImageLocally(selectedImageData, with: name)
            }
        } catch let caughtError {
            self.error = MediaItemError.repositoryFailure(caughtError.localizedDescription)
            return defaultUrl
        }
        return defaultUrl
    }

    func editItem() async {
        guard let selectedItem else { return }

        do {
            if let selectedImageData {
                selectedItem.fileSrc = try repository.saveImageLocally(selectedImageData, with: selectedItem.uuid.uuidString + ".jpg")
                try await repository.update(selectedItem)
                
                if let idx = items.firstIndex(where: { $0.id == selectedItem.id }) {
                    items[idx] = selectedItem
                }
            }
        } catch let caughtError {
            self.error = MediaItemError.repositoryFailure(caughtError.localizedDescription)
        }
    }

    func disappear() {
        selectedItem = nil
        error = nil
        newItem = nil
        selectedImageData = nil
    }
    
    func getImageURL(_ fileSrc: String?) -> URL? {
        guard let fileSrc else { return nil }
        return self.repository.getImageURL(for: fileSrc)
    }
    // MARK: - Private

    private let repository: MediaItemRepositoryProtocol
}
