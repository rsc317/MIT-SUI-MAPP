//
//  MediaItemListView.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import SwiftUI

struct MediaItemListView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject var viewModel: MediaItemViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.items, id: \.id) { item in
                studentCard(item)
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
    
    @ViewBuilder
    private func studentCard(_ item: MediaItem) -> some View {
        ZStack {
            Color.card
            HStack(alignment: .center) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.text)
                Text(item.type.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.text)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .listRowInsets(EdgeInsets())
    }
}
