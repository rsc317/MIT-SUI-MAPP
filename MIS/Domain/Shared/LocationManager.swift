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

    // MARK: - Public Methods

    func requestAuthorization() {
        manager.requestWhenInUseAuthorization()
    }

    func startMonitoringLocation() {
        guard authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways else {
            return
        }

        manager.startUpdatingLocation()
    }

    func stopMonitoringLocation() {
        manager.stopUpdatingLocation()
    }

    func getCachedLocation() -> CLLocationCoordinate2D? {
        if let lastUpdate = lastLocationUpdate,
           Date().timeIntervalSince(lastUpdate) < 300,
           let cached = lastKnownLocation {
            return cached
        }
        return nil
    }

    func requestCurrentLocationAsync(timeout: TimeInterval = 10) async -> CLLocationCoordinate2D? {
        guard authorizationStatus == .authorizedWhenInUse ||
            authorizationStatus == .authorizedAlways else {
            return getDefaultLocation()
        }

        if let cached = getCachedLocation() {
            return cached
        }

        if activeContinuation != nil {
            try? await Task.sleep(for: .milliseconds(100))
            return lastKnownLocation ?? getDefaultLocation()
        }

        return await withCheckedContinuation { continuation in
            self.activeContinuation = continuation

            self.timeoutTask = Task { [weak self] in
                try? await Task.sleep(for: .seconds(timeout))
                self?.finishRequest(with: nil, reason: "Timeout nach \(timeout)s")
            }

            self.manager.requestLocation()
        }
    }

    // MARK: - Private

    private var lastLocationUpdate: Date?

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

            lastKnownLocation = location.coordinate
            lastLocationUpdate = Date()

            finishRequest(with: location.coordinate, reason: "Success")
        }
    }

    nonisolated func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            finishRequest(with: nil, reason: error.localizedDescription)
        }
    }
}
