//
//  MapsView.swift
//  MIS
//
//  Created by Emircan Duman on 18.10.25.
//

import MapKit
import SwiftUI

struct MapsView: View {
    // MARK: - Internal

    var body: some View {
        Map(position: $position) {
            Marker("Berlin", coordinate: CLLocationCoordinate2D(latitude: 52.52, longitude: 13.405))
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapPitchToggle()
        }
        .ignoresSafeArea()
    }

    // MARK: - Private

    @State private var position = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.52, longitude: 13.405),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )
}
