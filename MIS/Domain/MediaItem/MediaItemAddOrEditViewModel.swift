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
//@MainActor
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
            // Wenn wir im Edit-Mode sind, lade die Daten
            if let item = mediaItemViewModel.currentItem {
                print("✏️ Edit-Mode: Lade Item-Daten für \(item.title)")
                title = item.title
                desc = item.desc ?? ""
                file = item.mediaFile.file
                mediaItemViewModel.selectedImageData = await mediaItemViewModel.getImageData(for: item)
            } else {
                // Im Add-Mode: Stelle sicher dass alles leer ist
                print("➕ Add-Mode: Reset aller Felder")
                title = ""
                desc = ""
                file = ""
                mediaItemViewModel.selectedImageData = nil
                mediaItemViewModel.currentItem = nil
            }
            
            // Proaktiv Standort im Hintergrund aktualisieren
            if LocationManager.shared.getCachedLocation() == nil {
                print("🔄 Aktualisiere Standort proaktiv beim Öffnen...")
                Task.detached(priority: .utility) {
                    _ = await LocationManager.shared.requestCurrentLocationAsync(timeout: 3)
                }
            }
        }
    }

    func onDisappearAction() {
        print("🧹 Cleanup: onDisappearAction aufgerufen")
        error = nil
        title = ""
        file = ""
        desc = ""
        // Cleanup vom MediaItemViewModel NACH unseren Feldern
        mediaItemViewModel.onDisappearAction()
    }

    func prepareMediaItem(_ data: Data?, _ ext: String) {
        guard let data else { return }

        mediaItemViewModel.selectedImageData = data
        title.isEmpty ? title = "media_\(UUID().uuidString.prefix(8))" : ()
        file.isEmpty ? file = "\(title).\(ext)" : ()
    }

    func saveItem(_ local: Bool = true) async {
        do {
            let startTime = Date()
            guard let data = mediaItemViewModel.selectedImageData else {
                print("❌ Fehler: Kein Bild ausgewählt!")
                self.error = .repositoryFailure("Kein Bild ausgewählt")
                return
            }

            print("💾 Speichere Item: '\(title)', lokal: \(local)")
            let saveStartTime = Date()
            let model = try await repository.save(shouldSaveLocal: local, data: data, title: title, desc: desc, file: file)
            let saveElapsed = Date().timeIntervalSince(saveStartTime)
            print("✅ Item in Datenbank gespeichert: \(model.uuid) (\(String(format: "%.2f", saveElapsed))s)")

            // GPS-Koordinaten asynchron abrufen, aber mit Timeout
            print("📍 Ermittle GPS-Koordinaten...")
            let gpsStartTime = Date()
            
            // Verwende Task mit Timeout für schnelleres Response
            let coordinate: CLLocationCoordinate2D? = await withTaskGroup(of: CLLocationCoordinate2D?.self) { group in
                group.addTask {
                    await self.mediaItemViewModel.extractGPSMetadataOrCurrentLocation(from: data)
                }
                
                // Warte auf Ergebnis
                if let result = await group.next() {
                    return result
                }
                return nil
            }
            
            let gpsElapsed = Date().timeIntervalSince(gpsStartTime)
            
            if let fileGPSCoordinate = coordinate {
                print("✅ GPS-Koordinaten ermittelt in \(String(format: "%.2f", gpsElapsed))s: \(fileGPSCoordinate.latitude), \(fileGPSCoordinate.longitude)")
                
                let item = MediaItemDTO(from: model, fileGPSCoordinate: fileGPSCoordinate)
                
                if !mediaItemViewModel.items.contains(where: { $0.id == item.id }) {
                    mediaItemViewModel.items.append(item)
                    print("✅ Item zur Liste hinzugefügt: \(item.id)")
                } else {
                    print("⚠️ Item mit ID \(item.id) existiert bereits, wird nicht doppelt hinzugefügt")
                }
            } else {
                print("⚠️ Konnte keine GPS-Koordinaten ermitteln (Versuch dauerte \(String(format: "%.2f", gpsElapsed))s)")
            }
            
            let totalElapsed = Date().timeIntervalSince(startTime)
            print("✅ Speichern erfolgreich abgeschlossen! (Gesamt: \(String(format: "%.2f", totalElapsed))s)")
        } catch {
            print("❌ Fehler beim Speichern: \(error.localizedDescription)")
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
