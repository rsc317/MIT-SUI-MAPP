//
//  MediaItemDetailView.swift
//  MediaApp
//
//  Created by OpenAI on 2025-10-17.
//

import SwiftUI

struct MediaItemDetailView: View {
    // MARK: - Internal

    @State var item: MediaItemDataForm
    @State var viewModel: MediaItemDetailViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            rowImage(item.fileSrc)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundStyle(.accent)
        }
        .navigationTitle(item.title)
        .toolbarTitleDisplayMode(.inline)
        .modifier(NavigationBarTitleColorModifier(color: .accent))
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive, action: {
                    Task {
                        await viewModel.deleteItem(item)
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

    private func rowImage(_ fileScr: String?) -> Image {
        guard let fileUrl = viewModel.getImageURL(fileScr) else {
            return Image(systemName: "photo")
        }

        if let uiImage = UIImage(contentsOfFile: fileUrl.path) {
            return Image(uiImage: uiImage)
        }

        return Image(systemName: "photo")
    }
}
