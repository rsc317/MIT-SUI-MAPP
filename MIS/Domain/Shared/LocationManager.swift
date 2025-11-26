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

    // MARK: - Public Methods

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func requestCurrentLocationAsync(timeout: TimeInterval = 10) async -> CLLocationCoordinate2D? {
        // Prüfe Berechtigungen
        guard authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways else {
            print("⚠️ No location permission")
            return getDefaultLocation()
        }

        // Wenn bereits ein Request läuft, warte kurz und gib Default zurück
        if activeContinuation != nil {
            print("⚠️ Location request already in progress")
            try? await Task.sleep(for: .milliseconds(100))
            return getDefaultLocation()
        }

        return await withCheckedContinuation { continuation in
            self.activeContinuation = continuation

            self.timeoutTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(timeout))
                self?.finishRequest(with: nil, reason: "Timeout")
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
        // Hole und lösche Continuation atomar
        guard let continuation = activeContinuation else {
            return
        }

        activeContinuation = nil

        // Cancel Timeout
        timeoutTask?.cancel()
        timeoutTask = nil

        // Log
        if let coordinate {
            print("✅ Location: \(coordinate.latitude), \(coordinate.longitude)")
        } else {
            print("⚠️ Failed: \(reason) - using default")
        }

        // Resume mit Fallback
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

            finishRequest(with: location.coordinate, reason: "Success")
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            finishRequest(with: nil, reason: error.localizedDescription)
        }
    }
}
