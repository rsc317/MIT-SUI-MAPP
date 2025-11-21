//
//  MediaItemViewModel.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Combine
import CoreLocation
import Foundation
import ImageIO
import Observation
import SwiftData

@MainActor
@Observable final class MediaItemViewModel {
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
                    file = item.mediaFile.file
                    selectedImageData = try await repository.getImage(item.id)
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

    func loadItems() async {
        do {
            let models = try await repository.fetchAll()
            var loadedItems: [MediaItemDTO] = []
            
            for model in models {
                if let fileData = try await repository.getImage(model.uuid),
                   let fileGPSCoordinate = await extractGPSMetadataOrCurrentLocation(from: fileData) {
                    let item = MediaItemDTO(from: model, fileGPSCoordinate: fileGPSCoordinate)
                    loadedItems.append(item)
                }
            }
            
            items = loadedItems
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
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

    func saveItem(_ local: Bool = true) async {
        do {
            guard let data = selectedImageData else { return }

            let model = try await repository.save(shouldSaveLocal: local, data: data, title: title, desc: desc, file: file)
            
            if let fileGPSCoordinate = await extractGPSMetadataOrCurrentLocation(from: data) {
                let item = MediaItemDTO(from: model, fileGPSCoordinate: fileGPSCoordinate)
                items.append(item)
            }
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
        }
    }

    func updateItem() async {
        do {
            self.currentItem?.title = title
            self.currentItem?.desc = desc
            self.currentItem?.fileUpdateToken = UUID()

            guard let currentItem, let selectedImageData else { return }

            try await repository.update(byUUID: currentItem.id, data: selectedImageData, title: title, desc: desc)
            if let idx = items.firstIndex(where: { $0.id == currentItem.id }) {
                items[idx] = currentItem
            }
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
        }
    }

    func getImageData(for item: MediaItemDTO) async -> Data? {
        do {
            return try await repository.getImage(item.id)
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
            return nil
        }
    }

    func prepareMediaItem(_ data: Data?, _ ext: String) {
        guard let data else { return }

        selectedImageData = data
        title.isEmpty ? title = "media_\(UUID().uuidString.prefix(8))" : ()
        file.isEmpty ? file = "\(title).\(ext)" : ()
    }

    func extractGPSMetadataOrCurrentLocation(from imageData: Data) async -> CLLocationCoordinate2D? {
        if let source = CGImageSourceCreateWithData(imageData as CFData, nil),
           let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
           let gpsDict = metadata[kCGImagePropertyGPSDictionary] as? [CFString: Any],
           let latitude = gpsDict[kCGImagePropertyGPSLatitude] as? Double,
           let longitude = gpsDict[kCGImagePropertyGPSLongitude] as? Double,
           let latRef = gpsDict[kCGImagePropertyGPSLatitudeRef] as? String,
           let lonRef = gpsDict[kCGImagePropertyGPSLongitudeRef] as? String {
            let lat = latRef == "S" ? -latitude : latitude
            let lon = lonRef == "W" ? -longitude : longitude
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        return await LocationManager.shared.requestCurrentLocationAsync()
    }

    // MARK: - Private

    private let repository: MediaItemRepositoryProtocol
}
