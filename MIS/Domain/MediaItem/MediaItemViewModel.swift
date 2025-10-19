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

    private(set) var items = [MediaItemDataForm]()
    var selectedItem: MediaItemDataForm?

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

    func addItem(from data: MediaItemDataForm) async {
        let item = MediaItem(
            uuid: data.id,
            title: data.title,
            desc: data.desc,
            src: data.src,
            createDate: data.createDate,
            type: data.type
        )

        do {
            try await repository.add(item)
            items.append(data)
        } catch let caughtError {
            self.error = MediaItemError.repositoryFailure(caughtError.localizedDescription)
        }
    }

    // MARK: - Private

    private let repository: MediaItemRepositoryProtocol

    private func mapModelToDataForm(_ item: MediaItem) -> MediaItemDataForm {
        MediaItemDataForm(
            id: item.uuid,
            title: item.title,
            desc: item.desc,
            src: item.src,
            createDate: item.createDate,
            type: item.type
        )
    }
}
