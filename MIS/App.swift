//
//  MISApp.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import CoreLocation
import Photos
import SwiftData
import SwiftUI

@main struct MISApp: App {
    // MARK: - Internal

    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    if LocationManager.shared.authorizationStatus == .notDetermined {
                        LocationManager.shared.requestAuthorization()
                    }

                    if LocationManager.shared.authorizationStatus == .authorizedWhenInUse ||
                        LocationManager.shared.authorizationStatus == .authorizedAlways {
                        LocationManager.shared.startMonitoringLocation()
                    }

                    await requestPhotoLibraryAccess()
                }
        }
    }

    // MARK: - Private

    // MARK: - Private Methods

    private func requestPhotoLibraryAccess() async {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        guard status == .notDetermined else {
            return
        }

        await PHPhotoLibrary.requestAuthorization(for: .readWrite)
    }
}
