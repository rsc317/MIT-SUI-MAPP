//
//  MediaItemAddOrEditViewModel.swift
//  MIS
//
//  Created by Emircan Duman on 23.11.25.
//

import Combine
import Foundation
import ImageIO
import MapKit

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
            } else {
                title = ""
                desc = ""
                file = ""
                mediaItemViewModel.selectedImageData = nil
                mediaItemViewModel.currentItem = nil
            }

            if LocationManager.shared.getCachedLocation() == nil {
                Task.detached(priority: .utility) {
                    _ = await LocationManager.shared.requestCurrentLocationAsync(timeout: 3)
                }
            }
        }
    }

    func onDisappearAction() {
        error = nil
        title = ""
        file = ""
        desc = ""
        mediaItemViewModel.onDisappearAction()
    }

    func prepareMediaItem(_ data: Data?, _: String, _ originalFilename: String? = nil) {
        guard let data else { return }
        guard let jpgData = ImageConverter.convertToJPG(data: data, compressionQuality: 0.85) else {
            error = .repositoryFailure("Bild konnte nicht konvertiert werden")
            return
        }

        mediaItemViewModel.selectedImageData = jpgData

        if let originalFilename, !originalFilename.isEmpty {
            let nameWithoutExt = (originalFilename as NSString).deletingPathExtension
            title.isEmpty ? title = nameWithoutExt : ()
            file.isEmpty ? file = nameWithoutExt : ()
        } else {
            title.isEmpty ? title = "media_\(UUID().uuidString.prefix(8))" : ()
            file.isEmpty ? file = title : ()
        }
    }

    func saveItem(_ local: Bool = true) async {
        do {
            guard let data = mediaItemViewModel.selectedImageData else {
                error = .repositoryFailure("Kein Bild ausgewählt")
                return
            }

            let model = try await repository.save(shouldSaveLocal: local, data: data, title: title, desc: desc, file: file)
            let coordinate: CLLocationCoordinate2D? = await withTaskGroup(of: CLLocationCoordinate2D?.self) { group in
                group.addTask {
                    await self.mediaItemViewModel.extractGPSMetadataOrCurrentLocation(from: data)
                }

                if let result = await group.next() {
                    return result
                }
                return nil
            }

            if let fileGPSCoordinate = coordinate {
                let item = MediaItemDTO(from: model, fileGPSCoordinate: fileGPSCoordinate)

                if !mediaItemViewModel.items.contains(where: { $0.id == item.id }) {
                    mediaItemViewModel.items.append(item)
                }
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
