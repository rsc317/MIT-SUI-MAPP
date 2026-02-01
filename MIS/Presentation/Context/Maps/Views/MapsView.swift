//
//  MapsView.swift
//  MIS
//
//  Created by Emircan Duman on 18.10.25.
//

import MapKit
import SwiftUI

// MARK: - MapsView -

struct MapsView: View {
    // MARK: - Internal

    @Environment(\.mapCoordinator) private var coordinator
    @AppStorage("use_design_two") private var useDesignTwo: Bool = false

    @State var viewModel: MediaItemViewModel

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $position, selection: $viewModel.selectedItemID) {
                ForEach(viewModel.items) { item in
                    Annotation("", coordinate: item.mediaFile.fileGPSCoordinate) {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 32, height: 32)
                                    .shadow(color: .black.opacity(0.3), radius: 4, y: 2)

                                Image(systemName: item.mediaFile.location == .local ? "internaldrive" : "cloud")
                                    .foregroundStyle(.white)
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .onTapGesture {
                                withAnimation(.smooth(duration: 0.5)) {
                                    position = .region(
                                        MKCoordinateRegion(
                                            center: item.mediaFile.fileGPSCoordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                                        )
                                    )
                                    viewModel.selectedItemID = item.id
                                }
                            }

                            if viewModel.selectedItemID == item.id {
                                Text(item.title)
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.regularMaterial)
                                            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                                    }
                                    .transition(.scale.combined(with: .opacity))
                                    .onTapGesture {
                                        viewModel.currentItem = item
                                        if useDesignTwo {
                                            coordinator.presentFullScreenCover(.itemDetail)
                                        } else {
                                            coordinator.push(route: .detail)
                                        }
                                    }
                            }
                        }
                    }
                    .tag(item.id)
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapPitchToggle()
            }
            .ignoresSafeArea()
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.2)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.ultraThickMaterial)
                                    .shadow(radius: 10)
                            }
                    }
                }
            }
            
            // Button zum Anzeigen aller Pinpoints
            Button {
                fitAllAnnotations()
            } label: {
                Image(systemName: "scope")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
            }
            .padding(.trailing, 16)
            .padding(.bottom, 16)
        }
        .task {
            // Lade alle Items für die Map
            await viewModel.loadItems()
            
            if let userLocation = await LocationManager.shared.requestCurrentLocationAsync() {
                position = .region(
                    MKCoordinateRegion(
                        center: userLocation,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
            }

            if let firstItem = viewModel.items.first {
                position = .region(
                    MKCoordinateRegion(
                        center: firstItem.mediaFile.fileGPSCoordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                )
            }
        }
        .onChange(of: viewModel.items) { oldItems, newItems in
            if oldItems.count > newItems.count {
                viewModel.selectedItemID = nil
            }

            if let firstItem = newItems.first {
                withAnimation(.easeInOut(duration: 0.5)) {
                    position = .region(
                        MKCoordinateRegion(
                            center: firstItem.mediaFile.fileGPSCoordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    )
                }
            }
        }
        .id(viewModel.items.count)
    }

    // MARK: - Private

    @State private var position = MapCameraPosition.userLocation(fallback: .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 52.52, longitude: 13.405),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
    ))
    
    private func fitAllAnnotations() {
        guard !viewModel.items.isEmpty else { return }
        
        let coordinates = viewModel.items.map { $0.mediaFile.fileGPSCoordinate }
        
        let minLat = coordinates.map(\.latitude).min() ?? 0
        let maxLat = coordinates.map(\.latitude).max() ?? 0
        let minLon = coordinates.map(\.longitude).min() ?? 0
        let maxLon = coordinates.map(\.longitude).max() ?? 0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max((maxLat - minLat) * 1.5, 0.01),
            longitudeDelta: max((maxLon - minLon) * 1.5, 0.01)
        )
        
        withAnimation(.smooth(duration: 0.8)) {
            position = .region(MKCoordinateRegion(center: center, span: span))
            viewModel.selectedItemID = nil
        }
    }
}
