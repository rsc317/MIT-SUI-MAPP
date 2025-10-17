//
//  MediaItemDetailView.swift
//  MediaApp
//
//  Created by OpenAI on 2025-10-17.
//

import SwiftUI

struct MediaItemDetailView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject var viewModel: MediaItemViewModel
    
    let item: MediaItem

    init(viewModel: MediaItemViewModel, item: MediaItem? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        if let item = item {
            self.item = item
        } else if let firstItem = viewModel.items.first {
            self.item = firstItem
        } else {
            self.item = MediaItem(
                title: "-",
                desc: nil,
                src: URL(fileURLWithPath: "/"),
                createDate: Date(),
                type: .picture
            )
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color.background.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .overlay {
                        Image(systemName: item.type == .picture ? "photo" : "video")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .foregroundStyle(.text)
                    }

                Text(item.title)
                    .font(.title)
                    .bold()
                    .foregroundStyle(.text)

                Text(item.type.rawValue.capitalized)
                    .font(.headline)
                    .foregroundStyle(.text)

                Text(item.createDate, format: .dateTime)
                    .foregroundStyle(.text)

                if let desc = item.desc, !desc.isEmpty {
                    Text(desc)
                        .foregroundStyle(.text)
                        .multilineTextAlignment(.leading)
                } else {
                    Text(LocalizedStringKey("No description"))
                        .italic()
                        .foregroundStyle(.text.opacity(0.6))
                }
            }
            .padding()
        }
        .navigationTitle(item.title)
        .toolbarTitleDisplayMode(.inline)
        .modifier(NavigationBarTitleColorModifier(color: .accent))
    }
}

#Preview {
    // Minimal fake repository and view model to satisfy compiler
    class FakeRepository: MediaRepository {
        // Empty stub implementation
    }

    let sampleItem = MediaItem(
        title: "Sample Item",
        desc: "This is a sample media item description.",
        src: URL(string: "https://example.com/media")!,
        createDate: Date(),
        type: .picture
    )
    let viewModel = MediaItemViewModel(repository: FakeRepository())
    MediaItemDetailView(viewModel: viewModel, item: sampleItem)
        .environmentObject(AppCoordinator())
}
