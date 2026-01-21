//
//  LocationManager.swift
//  MIS
//

import CoreLocation
import Foundation
import Observation

// MARK: - LocationManager -

@MainActor
@Observable final class LocationManager: NSObject {
    // MARK: - Lifecycle

    // MARK: - Init

    override private init() {
        authorizationStatus = CLLocationManager().authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    // MARK: - Internal

    // MARK: - Singleton

    static let shared = LocationManager()

    var authorizationStatus: CLAuthorizationStatus
    private(set) var lastKnownLocation: CLLocationCoordinate2D?
    private var lastLocationUpdate: Date?
    
    // MARK: - Public Methods

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }
    
    /// Startet kontinuierliche Standort-Updates im Hintergrund
    func startMonitoringLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways else {
            print("⚠️ Standortberechtigung nicht erteilt")
            return
        }
        
        print("📍 Starte kontinuierliche Standort-Überwachung")
        manager.startUpdatingLocation()
    }
    
    /// Stoppt kontinuierliche Standort-Updates
    func stopMonitoringLocation() {
        print("📍 Stoppe Standort-Überwachung")
        manager.stopUpdatingLocation()
    }
    
    /// Gibt den gecachten Standort zurück (sofort verfügbar!)
    func getCachedLocation() -> CLLocationCoordinate2D? {
        // Wenn der gecachte Standort weniger als 5 Minuten alt ist, verwende ihn
        if let lastUpdate = lastLocationUpdate,
           Date().timeIntervalSince(lastUpdate) < 300, // 5 Minuten
           let cached = lastKnownLocation {
            print("✅ Verwende gecachten Standort: \(cached.latitude), \(cached.longitude)")
            return cached
        }
        return nil
    }

    func requestCurrentLocationAsync(timeout: TimeInterval = 10) async -> CLLocationCoordinate2D? {
        guard authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways else {
            print("⚠️ Keine Standortberechtigung, verwende Default-Standort")
            return getDefaultLocation()
        }

        // Wenn wir einen frischen gecachten Standort haben, verwende ihn sofort
        if let cached = getCachedLocation() {
            return cached
        }

        // Falls bereits eine Anfrage läuft, warte kurz und verwende dann Default
        if activeContinuation != nil {
            print("⚠️ Standortanfrage läuft bereits, verwende gecachten oder Default-Standort")
            try? await Task.sleep(for: .milliseconds(100))
            return lastKnownLocation ?? getDefaultLocation()
        }

        print("📍 Fordere aktuellen Standort an (Timeout: \(timeout)s)...")
        return await withCheckedContinuation { continuation in
            self.activeContinuation = continuation

            self.timeoutTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(timeout))
                await self?.finishRequest(with: nil, reason: "Timeout nach \(timeout)s")
            }

            self.manager.requestLocation()
        }
    }

    // MARK: - Private

    private let manager = CLLocationManager()
    private var activeContinuation: CheckedContinuation<CLLocationCoordinate2D?, Never>?
    private var timeoutTask: Task<Void, Never>?

    // MARK: - Private Methods

    private func finishRequest(with coordinate: CLLocationCoordinate2D?, reason: String) {
        guard let continuation = activeContinuation else {
            return
        }

        activeContinuation = nil
        timeoutTask?.cancel()
        timeoutTask = nil

        continuation.resume(returning: coordinate ?? getDefaultLocation())
    }

    private func getDefaultLocation() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: 52.520008, longitude: 13.404954)
    }
}

// MARK: - CLLocationManagerDelegate -

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.first, location.horizontalAccuracy >= 0 else {
                finishRequest(with: nil, reason: "Invalid location")
                return
            }

            // Cache den Standort für spätere Verwendung
            lastKnownLocation = location.coordinate
            lastLocationUpdate = Date()
            print("📍 Standort aktualisiert: \(location.coordinate.latitude), \(location.coordinate.longitude) (Genauigkeit: \(location.horizontalAccuracy)m)")

            finishRequest(with: location.coordinate, reason: "Success")
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            finishRequest(with: nil, reason: error.localizedDescription)
        }
    }
}
