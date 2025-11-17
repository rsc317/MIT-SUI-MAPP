//
//  MediaItemDetailView.swift
//  MediaApp
//
//  Created by Emircan Duman on 16.10.25.
//

import SwiftUI

struct MediaItemDetailView: View {
    @State var viewModel: MediaItemDetailViewModel
    @State private var showDeleteItemAlert = false

    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                } else {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundStyle(.accent)
                }
            }
        }
        .navigationTitle(viewModel.item.title)
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
            message: "Möchten Sie das Medium \(viewModel.item.title)?",
            destructiveAction: {
                Task {
                    await viewModel.deleteItem()
                    coordinator.pop()
                }
            }
        )
        .task {
            await loadImage()
        }
        .applyGlobalBackground()
    }

    @Environment(\.coordinator) private var coordinator
    @State private var image = Image(systemName: "defaultPicture")
    @State private var isLoading = true

    @MainActor private func loadImage() async {
        defer { isLoading = false }

        if let data = try? await viewModel.getImage(),
           let uiImage = UIImage(data: data) {
            image = Image(uiImage: uiImage)
        }
    }
}
