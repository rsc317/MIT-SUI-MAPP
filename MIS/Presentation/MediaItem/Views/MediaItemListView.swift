//
//  MediaItemListView.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import SwiftUI

struct MediaItemListView: View {
    // MARK: - Internal

    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject var viewModel: MediaItemViewModel

    var body: some View {
        List {
            ForEach(viewModel.items, id: \.id) { item in
                itemRow(item)
                    .onTapGesture {
                        coordinator.push(route: .itemDetail)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        UIComponentFactory.createDeleteButton(action: {
                            Task { await viewModel.deleteItem(item) }
                        }, accessibilityId: MediaItemAID.BUTTON_DELETE)
                    }
            }
        }
        .listStyle(.automatic)
        .background(Color.background)
        .modifier(NavigationBarTitleColorModifier(color: .accent))
        .navigationTitle(MediaItemLK.NAV_TITLE.localized)
        .toolbar {
            UIComponentFactory.createAddButton(action: {
                coordinator.presentSheet(.addNewItem(viewModel))
            }, accessibilityId: MediaItemAID.BUTTON_ADD)
        }
        .task { viewModel.loadItems() }
    }

    // MARK: - Private

    @ViewBuilder
    private func itemRow(_ item: MediaItemDataForm) -> some View {
        ZStack {
            Color.card
            HStack(alignment: .center) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.text)
                Text(item.formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.text)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .listRowInsets(EdgeInsets())
    }
}
