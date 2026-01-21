//
//  MISApp.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import CoreLocation
import SwiftData
import SwiftUI

@main struct MISApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    // Fordere Standortberechtigung an wenn nötig
                    if LocationManager.shared.authorizationStatus == .notDetermined {
                        LocationManager.shared.requestAuthorization()
                    }

                    // Starte proaktives Standort-Monitoring im Hintergrund
                    if LocationManager.shared.authorizationStatus == .authorizedWhenInUse ||
                        LocationManager.shared.authorizationStatus == .authorizedAlways {
                        LocationManager.shared.startMonitoringLocation()
                        print("✅ Standort-Monitoring gestartet beim App-Start")
                    }
                }
        }
    }
}
