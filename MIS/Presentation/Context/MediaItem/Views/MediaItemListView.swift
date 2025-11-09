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
    @State private var showDeleteItemAlert: Bool = false

    var body: some View {
        List {
            ForEach(filteredItems, id: \.id) { item in
                ItemRowView(item: item, viewModel: viewModel)
                    .onTapGesture {
                        coordinator.push(route: .itemDetail(item))
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        UIComponentFactory.createDeleteButton(action: {
                            viewModel.currentItem = item
                            showDeleteItemAlert = true
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
        .task { await viewModel.loadItems() }
        .confirmationDialog(viewModel.currentItem?.title ?? "Unbekannt", isPresented: $showingOptions, titleVisibility: .visible) {
            Button(GlobalLocalizationKeys.BUTTON_DELETE.localized, role: .destructive) {
                Task {
                    showDeleteItemAlert = true
                }
            }
            Button(GlobalLocalizationKeys.BUTTON_EDIT.localized) {
                coordinator.presentSheet(.addOrEditNewItem(viewModel))
            }
            Button(GlobalLocalizationKeys.BUTTON_CANCEL.localized, role: .cancel) {}
        }
        .deleteConfirmationAlert(
            isPresented: $showDeleteItemAlert,
            title: "Medium löschen?",
            message: "Möchten Sie das Medium \(viewModel.currentItem?.title ?? "")?",
            destructiveAction: {
                Task {
                    await viewModel.deleteCurrentItem()
                    coordinator.pop()
                }
            }
        )
        Spacer()
        HStack {
            Picker("Filter", selection: $filter) {
                Text("Alle").tag(FilterType.all)
                Image(systemName: "internaldrive")
                    .tag(FilterType.local)
                Image(systemName: "cloud")
                    .tag(FilterType.remote)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
        }
        .padding(.bottom, 12)
    }

    private var filteredItems: [MediaItemDTO] {
        switch filter {
        case .all: viewModel.items
        case .local: viewModel.items.filter { $0.location == .local }
        case .remote: viewModel.items.filter { $0.location == .remote }
        }
    }

    // MARK: - Private

    @State private var showingOptions = false
    @State private var filter = FilterType.all

    private enum FilterType {
        case all, local, remote
    }

    private struct ItemRowView: View {
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
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    HStack(spacing: 4) {
                        Image(systemName: item.location == .local ? "internaldrive" : "cloud")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(item.location == .local ? .green : .blue)
                            .font(.system(size: 17, weight: .bold))
                        Text(item.location == .local ? "Lokal" : "Extern")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(item.location == .local ? .green : .blue)
                    }
                }
                .padding()
            }
            .listRowInsets(EdgeInsets())
            .task(id: item.imageUpdateToken) {
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
            if let data = await viewModel.getImageData(for: item),
               let uiImage = UIImage(data: data) {
                image = Image(uiImage: uiImage)
            }
        }
    }
}
