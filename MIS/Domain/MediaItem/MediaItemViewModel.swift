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

//@MainActor
@Observable final class MediaItemViewModel {
    init(_ repository: MediaItemRepositoryProtocol) {
        self.repository = repository
    }

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
            print("🗑️ Lösche Item: \(item.id) - \(item.title)")
            try await repository.delete(byUUID: item.id)
            items.removeAll { $0.id == item.id }
            print("✅ Item aus Liste entfernt")
        } catch {
            print("❌ Fehler beim Löschen: \(error.localizedDescription)")
            self.error = .repositoryFailure(error.localizedDescription)
        }
    }

    func deleteCurrentItem() async {
        guard let currentItem else {
            print("⚠️ Kein currentItem zum Löschen vorhanden")
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
        print("📸 Prüfe Bild-Metadaten auf GPS-Daten...")
        if let source = CGImageSourceCreateWithData(imageData as CFData, nil),
           let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
           let gpsDict = metadata[kCGImagePropertyGPSDictionary] as? [CFString: Any],
           let latitude = gpsDict[kCGImagePropertyGPSLatitude] as? Double,
           let longitude = gpsDict[kCGImagePropertyGPSLongitude] as? Double,
           let latRef = gpsDict[kCGImagePropertyGPSLatitudeRef] as? String,
           let lonRef = gpsDict[kCGImagePropertyGPSLongitudeRef] as? String {
            let lat = latRef == "S" ? -latitude : latitude
            let lon = lonRef == "W" ? -longitude : longitude
            print("✅ GPS-Daten aus Bild-Metadaten gefunden: \(lat), \(lon)")
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }

        // Versuche zuerst gecachten Standort zu verwenden (SOFORT verfügbar!)
        if let cached = LocationManager.shared.getCachedLocation() {
            print("✅ Verwende gecachten Standort (0.00s)")
            return cached
        }

        // Falls kein Cache, fordere neuen Standort an
        print("📍 Keine GPS-Daten in Metadaten, fordere aktuellen Standort an (Timeout: 3s)...")
        let locationStart = Date()
        let location = await LocationManager.shared.requestCurrentLocationAsync(timeout: 3)
        let locationElapsed = Date().timeIntervalSince(locationStart)
        
        if let location {
            print("✅ Standort erhalten in \(String(format: "%.2f", locationElapsed))s: \(location.latitude), \(location.longitude)")
            return location
        } else {
            print("❌ Standortanfrage fehlgeschlagen nach \(String(format: "%.2f", locationElapsed))s, verwende Fallback")
            // Fallback auf Default-Koordinaten (Berlin)
            return CLLocationCoordinate2D(latitude: 52.520008, longitude: 13.404954)
        }
    }

    func onDisappearAction() {
        error = nil
        currentItem = nil
        selectedImageData = nil
    }

    // MARK: - Private

    private let repository: MediaItemRepositoryProtocol
}
