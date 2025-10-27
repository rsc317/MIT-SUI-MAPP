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
                itemRow(item)
                    .onTapGesture {
                        coordinator.push(route: .itemDetail(item))
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        UIComponentFactory.createDeleteButton(action: {
                            Task { await viewModel.deleteItem(item) }
                        }, accessibilityId: MediaItemAID.BUTTON_DELETE)

                        Button {
                            viewModel.selectedItem = item
                            showingOptions = true
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                        .tint(.gray)
                    }
            }
        }
        .applyGlobalBackground()
        .modifier(NavigationBarTitleColorModifier(color: .accent))
        .navigationTitle(MediaItemLK.NAV_TITLE.localized)
        .toolbar {
            UIComponentFactory.createAddButton(action: {
                coordinator.presentSheet(.addOrEditNewItem(viewModel))
            }, accessibilityId: MediaItemAID.BUTTON_ADD)
        }
        .task { viewModel.loadItems() }
        .confirmationDialog(viewModel.selectedItem?.title ?? "Unbekannt", isPresented: $showingOptions, titleVisibility: .visible) {
            Button(GlobalLocalizationKeys.BUTTON_DELETE.localized, role: .destructive) {
                Task {
                    await viewModel.deleteSelectedItem()
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

    @ViewBuilder
    private func itemRow(_ item: MediaItemDataForm) -> some View {
        ZStack {
            Color.card
            HStack(alignment: .center, spacing: 12) {
                rowImage(item.fileSrc)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(.text)
                    Text(item.formattedDate)
                        .font(.subheadline)
                        .foregroundStyle(.text)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
        }
        .listRowInsets(EdgeInsets())
    }

    private func rowImage(_ fileSrc: String?) -> Image {
        guard let url = viewModel.getImageURL(fileSrc) else {
            return Image(systemName: "photo")
        }

        let assetName = url.lastPathComponent
        if UIImage(named: assetName) != nil {
            return Image(assetName)
        }
        
        if let uiImage = UIImage(contentsOfFile: url.path) {
            return Image(uiImage: uiImage)
        }
        
        return Image(systemName: "photo")
    }
}
