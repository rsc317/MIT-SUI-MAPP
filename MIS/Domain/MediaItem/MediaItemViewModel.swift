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
    // MARK: - Init

    init(_ repository: MediaItemRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Internal

    var items = [MediaItemDTO]()
    var selectedItem: MediaItemDTO?
    var newItem: MediaItemDTO?
    var selectedImageData: Data?
    var error: MediaItemError?

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

    func deleteSelectedItem() async {
        guard let selectedItem else { return }

        await deleteItem(selectedItem)
        self.selectedItem = nil
    }

    func saveItem() async {
        guard let newItem else { return }

        do {
            try await repository.add(newItem)
            items.append(newItem)
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
        }
    }

    func addImageToLocal(_ name: String) async -> String {
        var filename = "defaultPicture"

        do {
            if let selectedImageData {
                filename = try repository.saveImageLocally(selectedImageData, with: name)
            }
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
        }

        return filename
    }

    func editItem() async {
        guard var selectedItem else { return }

        do {
            if let selectedImageData {
                selectedItem.fileSrc = try repository.saveImageLocally(
                    selectedImageData,
                    with: UUID().uuidString + ".jpg"
                )
            }

            try await repository.update(selectedItem)

            if let index = items.firstIndex(where: { $0.id == selectedItem.id }) {
                items[index] = selectedItem
            }

            self.selectedItem = selectedItem
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
        }
    }
    
    func createNewItem(_ title: String, _ desc: String) async -> String {
        if newItem == nil {
            let id = UUID()
            let newTitle = title.isEmpty ? id.uuidString : title
            let fileSrc = await addImageToLocal(id.uuidString + ".jpg")
            self.newItem = MediaItemDTO(id: id, title: newTitle, desc: desc, fileSrc: fileSrc, createDate: Date(), type: .picture)
        }
        
        return newItem?.title ?? ""
    }
    
    func disappear() {
        selectedItem = nil
        newItem = nil
        selectedImageData = nil
        error = nil
    }

    func getImageURL(_ fileSrc: String?) -> URL? {
        guard let fileSrc else { return nil }
        return repository.getImageURL(for: fileSrc)
    }

    // MARK: - Private

    private let repository: MediaItemRepositoryProtocol
}
