//
//  MediaItemListView.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import SwiftUI

struct MediaItemListView: View {
    // MARK: - Internal

    @Environment(AppCoordinator.self) private var coordinator
    @State var viewModel: MediaItemViewModel

    var body: some View {
        List {
            ForEach(viewModel.items, id: \.id) { item in
                ItemRowView(item: item, viewModel: viewModel)
                    .onTapGesture {
                        coordinator.push(route: .itemDetail(item))
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        UIComponentFactory.createDeleteButton(action: {
                            Task { await viewModel.deleteItem(item) }
                        }, accessibilityId: MediaItemAID.BUTTON_DELETE)

                        Button {
                            viewModel.currentItem = item
                            showingOptions = true
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                        .tint(.gray)
                    }
            }
        }
        .applyGlobalBackground()
        .modifier(NavigationBarTitleColorModifier(color: .accentColor))
        .navigationTitle(MediaItemLK.NAV_TITLE.localized)
        .toolbar {
            UIComponentFactory.createAddButton(action: {
                coordinator.presentSheet(.addOrEditNewItem(viewModel))
            }, accessibilityId: MediaItemAID.BUTTON_ADD)
        }
        .task { viewModel.loadItems() }
        .confirmationDialog(viewModel.currentItem?.title ?? "Unbekannt", isPresented: $showingOptions, titleVisibility: .visible) {
            Button(GlobalLocalizationKeys.BUTTON_DELETE.localized, role: .destructive) {
                Task {
                    await viewModel.deleteCurrentItem()
                }
            }
            Button(GlobalLocalizationKeys.BUTTON_EDIT.localized) {
                coordinator.presentSheet(.addOrEditNewItem(viewModel))
            }
            Button(GlobalLocalizationKeys.BUTTON_CANCEL.localized, role: .cancel) {}
        }
    }

    // MARK: - Private

    @State private var showingOptions = false

    struct ItemRowView: View {
        // MARK: - Internal

        let item: MediaItemDTO
        let viewModel: MediaItemViewModel

        var body: some View {
            ZStack {
                Color.card
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(1.5)
                        } else {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.headline)
                            .foregroundStyle(.text)
                        HStack {
                            Text(item.createDate.formatted())
                                .font(.subheadline)
                                .foregroundStyle(.text)
                            Text("Location: \(item.location.rawValue)")
                                .font(.subheadline)
                                .foregroundStyle(.text)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .listRowInsets(EdgeInsets())
            .task {
                await loadImage()
            }
        }

        // MARK: - Private

        @State private var image = Image(systemName: "defaultPicture")
        @State private var isLoading = true

        @MainActor
        private func loadImage() async {
            isLoading = true
            defer { isLoading = false }

            if let cached = ImageMemoryCache.shared.get(for: item.id.uuidString),
               let uiImage = UIImage(data: cached) {
                image = Image(uiImage: uiImage)
            } else if let data = try? await viewModel.getImageData(for: item),
                      let uiImage = UIImage(data: data) {
                ImageMemoryCache.shared.set(data, for: item.id.uuidString)
                image = Image(uiImage: uiImage)
            }
        }
    }
}
