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
        Map(position: $position, selection: $viewModel.selectedItemID) {
            ForEach(viewModel.items) { item in
                Annotation("", coordinate: item.mediaFile.fileGPSCoordinate) {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 32, height: 32)
                                .shadow(color: .black.opacity(0.3), radius: 4, y: 2)

                            Image(systemName: item.mediaFile.location == .local ? "internaldrive.fill" : "cloud.fill")
                                .foregroundStyle(.white)
                                .font(.system(size: 14, weight: .semibold))
                        }

                        if viewModel.selectedItemID == item.id {
                            Text(item.title)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.white)
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
        .task {
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
}
