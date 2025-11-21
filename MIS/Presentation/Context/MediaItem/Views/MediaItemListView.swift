//
//  MediaItemListView.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import SwiftUI

struct MediaItemListView: View {
    // MARK: - Internal

    @Environment(\.coordinator) private var coordinator
    @State var viewModel: MediaItemViewModel
    @State private var showDeleteItemAlert: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(filteredItems, id: \.id) { item in
                        ItemRowView(item: item, viewModel: viewModel)
                            .onTapGesture {
                                coordinator.push(route: .itemDetail(item))
                            }
                            .contextMenu {
                                Button {
                                    viewModel.currentItem = item
                                    coordinator.presentSheet(.addOrEditNewItem(viewModel))
                                } label: {
                                    Label(GlobalLocalizationKeys.BUTTON_EDIT.localized, systemImage: "pencil")
                                }
                                
                                Button(role: .destructive) {
                                    viewModel.currentItem = item
                                    showDeleteItemAlert = true
                                } label: {
                                    Label(GlobalLocalizationKeys.BUTTON_DELETE.localized, systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 12)
            }
            
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
    }

    private var filteredItems: [MediaItemDTO] {
        switch filter {
        case .all: viewModel.items
        case .local: viewModel.items.filter { $0.mediaFile.location == .local }
        case .remote: viewModel.items.filter { $0.mediaFile.location == .remote }
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
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    if isLoading {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 200)
                            .overlay {
                                ProgressView()
                                    .scaleEffect(1.5)
                            }
                    } else {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .clipped()
                    }
                    
                    VStack {
                        HStack {
                            Spacer()
                            HStack(spacing: 6) {
                                Image(systemName: item.mediaFile.location == .local ? "internaldrive.fill" : "cloud.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                Text(item.mediaFile.location == .local ? "Lokal" : "Extern")
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background {
                                Capsule()
                                    .fill(item.mediaFile.location == .local ? Color.green : Color.blue)
                                    .shadow(color: .black.opacity(0.3), radius: 6, y: 2)
                            }
                            .padding(12)
                        }
                        Spacer()
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .padding(.horizontal, 12)
                .padding(.top, 12)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(item.title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.text)
                        .lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 13, weight: .medium))
                        Text(item.createDate.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .foregroundStyle(.blue)
                            .font(.system(size: 13, weight: .medium))
                        Text(String(format: "%.4f, %.4f", item.latitude, item.longitude))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            .shadow(color: .black.opacity(0.04), radius: 1, x: 0, y: 1)
            .task(id: item.fileUpdateToken) {
                await loadImage()
            }
        }

        // MARK: - Private

        @State private var image = Image(systemName: "photo")
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
