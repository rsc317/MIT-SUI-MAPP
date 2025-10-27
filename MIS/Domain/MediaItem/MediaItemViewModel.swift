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

    var items = [MediaItemDataForm]()
    var selectedItem: MediaItemDataForm?
    var newItem: MediaItemDataForm?
    var selectedImageData: Data?
    var error: MediaItemError?

    func loadItems() {
        Task {
            do {
                let fetched = try await repository.fetchAll()
                self.items = fetched.map { self.mapModelToDataForm($0) }
            } catch let caughtError {
                self.error = MediaItemError.repositoryFailure(caughtError.localizedDescription)
            }
        }
    }

    func deleteItem(_ formData: MediaItemDataForm) async {
        do {
            try await repository.delete(byUUID: formData.id)
            items.removeAll { $0.id == formData.id }
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
                uuid: newItem.id,
                title: newItem.title,
                desc: newItem.desc,
                fileSrc: newItem.fileSrc,
                createDate: newItem.createDate,
                type: newItem.type
            )
            try await repository.add(item)
            items.append(newItem)
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
            if let model = try await repository.fetch(byUUID: selectedItem.id),
               let selectedImageData {
                let src = try repository.saveImageLocally(selectedImageData, with: selectedItem.id.uuidString + ".jpg")
                model.title = selectedItem.title
                model.desc = selectedItem.desc
                model.fileSrc = src
                model.type = selectedItem.type
                try await repository.update(model)
                if let idx = items.firstIndex(where: { $0.id == selectedItem.id }) {
                    items[idx] = mapModelToDataForm(model)
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

    private func mapModelToDataForm(_ item: MediaItem) -> MediaItemDataForm {
        return MediaItemDataForm(
            id: item.uuid,
            title: item.title,
            desc: item.desc,
            fileSrc: item.fileSrc,
            createDate: item.createDate,
            type: item.type
        )
    }
}
