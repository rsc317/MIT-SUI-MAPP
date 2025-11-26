//
//  MISApp.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import SwiftData
import SwiftUI
import CoreLocation

@main struct MISApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .task {
                    if LocationManager.shared.authorizationStatus == .notDetermined {
                        LocationManager.shared.requestAuthorization()
                    }
                }
        }
    }
}
