//
//  MapsView.swift
//  MIS
//
//  Created by Emircan Duman on 18.10.25.
//

import SwiftUI
import MapKit

struct MapsView: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.52, longitude: 13.405),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    )

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
}
