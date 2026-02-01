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
import SwiftData

@Observable final class MediaItemViewModel {
    // MARK: - Lifecycle

    init(_ repository: MediaItemRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Internal

    var items = [MediaItemDTO]()
    var error: MediaItemError?
    var selectedItemID: UUID?
    var currentItem: MediaItemDTO?
    var selectedImageData: Data?
    var isLoading: Bool = false

    var currentItemTitle: String {
        currentItem?.title ?? ""
    }

    func loadItems() async {
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

    func deleteItem(_ item: MediaItemDTO) async {
        do {
            try await repository.delete(byUUID: item.id)
            items.removeAll { $0.id == item.id }

        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
        }
    }

    func deleteCurrentItem() async {
        guard let currentItem else {
            return
        }

        await deleteItem(currentItem)
        self.currentItem = nil
    }

    func getImageData(for item: MediaItemDTO) async -> Data? {
        do {
            return try await repository.getImage(item.id)
        } catch {
            self.error = .repositoryFailure(error.localizedDescription)
            return nil
        }
    }

    func getImageData() async throws -> Data? {
        do {
            guard let id = currentItem?.id else { return nil }

            return try await repository.getImage(id)
        } catch {
            return nil
        }
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
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            return coordinate
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

    func onDisappearAction() {
        error = nil
        selectedImageData = nil
    }
    
    func prepareForNewItem() {
        currentItem = nil
        selectedImageData = nil
        error = nil
    }

    // MARK: - Private

    private let repository: MediaItemRepositoryProtocol
}
