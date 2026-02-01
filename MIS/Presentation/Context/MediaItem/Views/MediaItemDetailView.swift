//
//  MediaItemDetailView.swift
//  MediaApp
//
//  Created by Emircan Duman on 16.10.25.
//

import SwiftUI

struct MediaItemDetailView: View {
    let onDismiss: () -> Void

    @State var viewModel: MediaItemViewModel
    @State private var showDeleteItemAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                                .frame(height: 300)
                        } else {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.accent)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        if let currentItem = viewModel.currentItem {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    HStack(spacing: 6) {
                                        Image(systemName: currentItem.mediaFile.location == .local ? "internaldrive" : "cloud")
                                            .font(.system(size: 14, weight: .semibold))
                                        Text(currentItem.mediaFile.location == .local ? "Lokal gespeichert" : "Server gespeichert")
                                            .font(.caption.weight(.semibold))
                                    }
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background {
                                        Capsule()
                                            .fill(currentItem.mediaFile.location == .local ? Color.green : Color.blue)
                                            .shadow(color: .black.opacity(0.3), radius: 6, y: 2)
                                    }
                                    .padding(12)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 300)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                }
                
                if let currentItem = viewModel.currentItem {
                    VStack(alignment: .leading, spacing: 8) {
                        ZStack {
                            DetailMapView(
                                coordinate: currentItem.mediaFile.fileGPSCoordinate,
                                title: currentItem.title,
                                location: currentItem.mediaFile.location
                            )
                        }
                        .frame(height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle(viewModel.currentItem?.title ?? "")
        .toolbarTitleDisplayMode(.inline)
        .modifier(NavigationBarTitleColorModifier(color: .accentColor))
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive, action: {
                    showDeleteItemAlert = true
                }) {
                    Image(systemName: "trash")
                        .foregroundStyle(.error)
                }
                .accessibilityIdentifier(MediaItemAID.BUTTON_DELETE.rawValue)
            }
        }
        .deleteConfirmationAlert(
            isPresented: $showDeleteItemAlert,
            title: "Medium löschen?",
            message: "Möchten Sie das Medium \(viewModel.currentItem?.title ?? "")?",
            destructiveAction: {
                Task {
                    await viewModel.deleteCurrentItem()
                    onDismiss()
                }
            }
        )
        .task {
            await loadImage()
        }
        .applyGlobalBackground()
        .onDisappear {
            viewModel.onDisappearAction()
        }
    }

    @State private var image = Image(systemName: "defaultPicture")
    @State private var isLoading = true

    @MainActor private func loadImage() async {
        defer { isLoading = false }

        if let data = try? await viewModel.getImageData(),
           let uiImage = UIImage(data: data) {
            image = Image(uiImage: uiImage)
        }
    }
}
