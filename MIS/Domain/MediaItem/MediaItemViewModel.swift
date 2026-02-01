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

    init(_ repository: MediaItemRepositoryProtocol, sharedDataStore: SharedMediaDataStore) {
        self.repository = repository
        self.sharedDataStore = sharedDataStore
    }

    // MARK: - Internal

    var error: MediaItemError?
    var selectedItemID: UUID?
    var currentItem: MediaItemDTO?
    var selectedImageData: Data?
    
    // Zugriff auf die gemeinsamen Daten
    var items: [MediaItemDTO] {
        sharedDataStore.items
    }
    
    var isLoading: Bool {
        sharedDataStore.isLoading
    }

    var currentItemTitle: String {
        currentItem?.title ?? ""
    }

    func loadItems() async {
        await sharedDataStore.loadItems()
    }

    func deleteItem(_ item: MediaItemDTO) async {
        do {
            try await sharedDataStore.deleteItem(item)
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
        await sharedDataStore.getImageData(for: item)
    }

    func getImageData() async throws -> Data? {
        guard let item = currentItem else { return nil }
        return await sharedDataStore.getImageData(for: item)
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
    
    func addItem(_ item: MediaItemDTO) {
        sharedDataStore.addItem(item)
    }
    
    func updateItem(_ item: MediaItemDTO) {
        sharedDataStore.updateItem(item)
    }

    // MARK: - Private

    private let repository: MediaItemRepositoryProtocol
    private let sharedDataStore: SharedMediaDataStore
}
