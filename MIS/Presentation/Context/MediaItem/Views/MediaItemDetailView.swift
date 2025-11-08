//
//  MediaItemDetailView.swift
//  MediaApp
//
//  Created by OpenAI on 2025-10-17.
//

import SwiftUI

struct MediaItemDetailView: View {
    // MARK: - Internal

    @State var viewModel: MediaItemDetailViewModel

    var body: some View {
        VStack(spacing: 16) {
            rowImage()
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.accent)
        }
        .navigationTitle(viewModel.item.title)
        .toolbarTitleDisplayMode(.inline)
        .modifier(NavigationBarTitleColorModifier(color: .accentColor))
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive, action: {
                    Task {
                        await viewModel.deleteItem()
                        coordinator.pop()
                    }
                }) {
                    Image(systemName: "trash")
                        .foregroundStyle(.error)
                }
                .accessibilityIdentifier(MediaItemAID.BUTTON_DELETE.rawValue)
            }
        }
        .applyGlobalBackground()
    }

    // MARK: - Private

    @Environment(AppCoordinator.self) private var coordinator

    private func rowImage() -> Image {
        guard let data = viewModel.getImage(),
              let uiImage = UIImage(data: data) else {
            return Image(systemName: "photo")
        }

        return Image(uiImage: uiImage)
    }
}
