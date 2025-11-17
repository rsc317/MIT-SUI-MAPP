//
//  LocationManager.swift
//  MIS
//
//  Created by Emircan Duman on 09.11.25.
//

import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {    
    // MARK: - Internal

    static let shared = LocationManager()

    func requestCurrentLocation(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        locationHandler = completion
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
    }

    func locationManager(_: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationHandler?(locations.first?.coordinate)
        locationHandler = nil
    }

    func locationManager(_: CLLocationManager, didFailWithError error: Error) {
        locationHandler?(nil)
        locationHandler = nil
    }

    func requestCurrentLocationAsync() async -> CLLocationCoordinate2D? {
        await withCheckedContinuation { continuation in
            self.requestCurrentLocation { coordinate in
                continuation.resume(returning: coordinate)
            }
        }
    }

    // MARK: - Private

    private let manager = CLLocationManager()
    private var locationHandler: ((CLLocationCoordinate2D?) -> Void)?
}
