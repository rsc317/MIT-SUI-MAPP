//
//  DetailMapView.swift
//  MIS
//
//  Created by Emircan Duman on 01.02.26.
//

import SwiftUI
import MapKit

// MARK: - DetailMapView -

struct DetailMapView: View {
    let coordinate: CLLocationCoordinate2D
    let title: String
    let location: FileLocation
    
    @State private var position: MapCameraPosition
    
    init(coordinate: CLLocationCoordinate2D, title: String, location: FileLocation) {
        self.coordinate = coordinate
        self.title = title
        self.location = location
        
        _position = State(initialValue: .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        ))
    }
    
    var body: some View {
        Map(position: $position, interactionModes: [.pan, .zoom]) {
            Annotation("", coordinate: coordinate) {
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(location == .local ? Color.green : Color.blue)
                            .frame(width: 40, height: 40)
                            .shadow(color: .black.opacity(0.3), radius: 4, y: 2)
                        
                        Image(systemName: location == .local ? "internaldrive" : "cloud")
                            .foregroundStyle(.white)
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Text(title)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.regularMaterial)
                                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                        }
                }
            }
        }
        .mapControls {
            MapCompass()
            MapPitchToggle()
        }
    }
}
