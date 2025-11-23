//
//  MediaItemAddOrEditViewModel.swift
//  MIS
//
//  Created by Emircan Duman on 23.11.25.
//

import Combine
import Foundation
import ImageIO

@MainActor
@Observable final class MediaItemAddOrEditViewModel {
    // MARK: - Lifecycle

    init(_ repository: MediaItemRepository, _ mediaItemViewModel: MediaItemViewModel) {
        self.repository = repository
        self.mediaItemViewModel = mediaItemViewModel
    }

    // MARK: - Internal

    var error: MediaItemError?
    var title = ""
    var file = ""
    var desc = ""

    private(set) var mediaItemViewModel: MediaItemViewModel

    var isEditMode: Bool {
        mediaItemViewModel.currentItem != nil
    }

    var emptyImage: Bool {
        mediaItemViewModel.selectedImageData == nil
    }

    var emptyTitle: Bool {
        title.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func onAppearAction() {
        Task {
            if let item = mediaItemViewModel.currentItem {
                title = item.title
                desc = item.desc ?? ""
                file = item.mediaFile.file
                mediaItemViewModel.selectedImageData = await mediaItemViewModel.getImageData(for: item)
            }
        }
    }

    func onDisappearAction() {
        mediaItemViewModel.onDisappearAction()
        error = nil
        title = ""
        file = ""
        desc = ""
    }

    func prepareMediaItem(_ data: Data?, _ ext: String) {
        guard let data else { return }

        mediaItemViewModel.selectedImageData = data
        title.isEmpty ? title = "media_\(UUID().uuidString.prefix(8))" : ()
        file.isEmpty ? file = "\(title).\(ext)" : ()
    }

    func saveItem(_ local: Bool = true) async {
        do {
            guard let data = mediaItemViewModel.selectedImageData else { return }

            let model = try await repository.save(shouldSaveLocal: local, data: data, title: title, desc: desc, file: file)

            if let fileGPSCoordinate = await mediaItemViewModel.extractGPSMetadataOrCurrentLocation(from: data) {
                let item = MediaItemDTO(from: model, fileGPSCoordinate: fileGPSCoordinate)
                mediaItemViewModel.items.append(item)
            }
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
        }
    }

    func updateItem() async {
        do {
            mediaItemViewModel.currentItem?.title = title
            mediaItemViewModel.currentItem?.desc = desc
            mediaItemViewModel.currentItem?.fileUpdateToken = UUID()

            guard let currentItem = mediaItemViewModel.currentItem,
                  let selectedImageData = mediaItemViewModel.selectedImageData else { return }

            try await repository.update(byUUID: currentItem.id, data: selectedImageData, title: title, desc: desc)
            if let idx = mediaItemViewModel.items.firstIndex(where: { $0.id == currentItem.id }) {
                mediaItemViewModel.items[idx] = currentItem
            }
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
        }
    }

    // MARK: - Private

    private let repository: MediaItemRepositoryProtocol
}
