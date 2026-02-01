//
//  SharedMediaDataStore.swift
//  MIS
//
//  Created by Emircan Duman on 01.02.26.
//

import Combine
import CoreLocation
import Foundation
import ImageIO

@Observable final class SharedMediaDataStore {
    // MARK: - Lifecycle

    init(_ repository: MediaItemRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Internal

    var items = [MediaItemDTO]()
    var isLoading: Bool = false
    var error: MediaItemError?

    func loadItems(force: Bool = false) async {
        guard force || items.isEmpty else { return }
        guard !isLoading else { return }

        do {
            isLoading = true
            let models = try await repository.fetchAll()
            var loadedItems = [MediaItemDTO]()

            for model in models {
                if let fileData = try await repository.getImage(model.uuid),
                   let fileGPSCoordinate = await extractGPSMetadataOrCurrentLocation(from: fileData) {
                    let item = MediaItemDTO(from: model, fileGPSCoordinate: fileGPSCoordinate)
                    loadedItems.append(item)
                }
            }

            items = loadedItems
            isLoading = false
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
            isLoading = false
        }
    }

    func deleteItem(_ item: MediaItemDTO) async throws {
        try await repository.delete(byUUID: item.id)
        items.removeAll { $0.id == item.id }
    }

    func addItem(_ item: MediaItemDTO) {
        if !items.contains(where: { $0.id == item.id }) {
            items.append(item)
        }
    }

    func updateItem(_ item: MediaItemDTO) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
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

    // MARK: - Private

    private let repository: MediaItemRepositoryProtocol

    private func extractGPSMetadataOrCurrentLocation(from imageData: Data) async -> CLLocationCoordinate2D? {
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

        if let cached = LocationManager.shared.getCachedLocation() {
            return cached
        }

        let location = await LocationManager.shared.requestCurrentLocationAsync(timeout: 3)

        if let location {
            return location
        } else {
            return CLLocationCoordinate2D(latitude: 52.520008, longitude: 13.404954)
        }
    }
}
