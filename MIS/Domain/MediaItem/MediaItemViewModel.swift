//
//  MediaItemViewModel.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Foundation
import Combine
import SwiftData

@MainActor
final class MediaItemViewModel: ObservableObject {
    @Published private(set) var items: [MediaItem] = []
    @Published var error: MediaItemError?

    private let repository: MediaItemRepositoryProtocol

    init(_ repository: MediaItemRepositoryProtocol) {
        self.repository = repository
    }

    func loadItems() {
        Task {
            do {
                items = try await repository.fetchAll()
            } catch let caughtError {
                self.error = MediaItemError.repositoryFailure(caughtError.localizedDescription)
            }
        }
    }

    func deleteItem(_ item: MediaItem) async {
        do {
            try await repository.delete(item)
            items = try await repository.fetchAll()
        } catch let caughtError {
            self.error = MediaItemError.repositoryFailure(caughtError.localizedDescription)
        }
    }
    
    func addItem(from data: MediaItemFormData) async {
        let item = MediaItem(
            title: data.title,
            desc: data.description,
            src: data.src,
            createDate: data.createDate,
            type: data.type
        )

        do {
            try await repository.add(item)
            loadItems()
        } catch let caughtError {
            self.error = MediaItemError.repositoryFailure(caughtError.localizedDescription)
        }
    }
}
