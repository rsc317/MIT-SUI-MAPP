//
//  DrivingStudentAddView.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.

import PhotosUI
import SwiftUI

struct MediaItemAddOrEditView: View {
    // MARK: - Internal

    enum Field: Hashable {
        case title, desc
    }

    @Environment(AppCoordinator.self) private var coordinator
    @State var viewModel: MediaItemViewModel
    @State private var selectedItem: PhotosPickerItem? = nil

    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        UIComponentFactory.createTextfield(
                            label: MediaItemLK.TITLE,
                            text: $title,
                            accessibilityId: MediaItemAID.TITLE
                        )
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .desc }

                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            Image(systemName: "photo.on.rectangle")
                        }
                        .onChange(of: selectedItem) { _, newItem in
                            prepareMediaItem(newItem)
                        }
                    }
                    ZStack {
                        if let imageData = viewModel.selectedImageData, let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        } else {
                            Color.clear
                                .frame(height: 200)
                        }
                    }
                }
                .padding()
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.accent, lineWidth: 1)
                        .allowsHitTesting(false)
                )
            }
            .applyGlobalBackground()
            .navigationTitle(isEditMode ? MediaItemLK.EDIT_NAV_TITLE.localized : MediaItemLK.ADD_NAV_TITLE.localized)
            .toolbarTitleDisplayMode(.inline)
            .modifier(NavigationBarTitleColorModifier(color: .accentColor))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    UIComponentFactory.createToolbarButton(
                        label: isEditMode ? GlobalLocalizationKeys.BUTTON_DELETE : GlobalLocalizationKeys.BUTTON_CANCEL,
                        action: {
                            if isEditMode {
                                Task {
                                    await viewModel.deleteSelectedItem()
                                }
                            }
                            coordinator.dismissSheet()
                        },
                        accessibilityId: isEditMode ? MediaItemAID.BUTTON_DELETE : MediaItemAID.BUTTON_CANCEL,
                        color: isEditMode ? .error : .accentColor
                    )
                }

                ToolbarItem(placement: .confirmationAction) {
                    UIComponentFactory.createToolbarButton(
                        label: GlobalLocalizationKeys.BUTTON_SAVE,
                        action: {
                            Task {
                                if isEditMode {
                                    viewModel.selectedItem?.title = title
                                    viewModel.selectedItem?.desc = desc
                                    await viewModel.editItem()
                                } else {
                                    viewModel.newItem?.title = title
                                    viewModel.newItem?.desc = desc
                                    await viewModel.saveItem()
                                }
                                coordinator.dismissSheet()
                            }
                        },
                        accessibilityId: MediaItemAID.BUTTON_SAVE
                    )
                }
            }
            .onAppear {
                isEditMode = viewModel.selectedItem != nil
                focusedField = .title
                title = viewModel.selectedItem?.title ?? ""
                desc = viewModel.selectedItem?.desc ?? ""
                if let fileSrc = viewModel.selectedItem?.fileSrc,
                   let url = viewModel.getImageURL(fileSrc),
                   let data = try? Data(contentsOf: url) {
                    viewModel.selectedImageData = data
                }
            }
            .onDisappear {
                viewModel.disappear()
            }
        }
    }

    // MARK: - Private

    @State private var title = ""
    @State private var desc = ""
    @State private var isEditMode: Bool = false
    @FocusState private var focusedField: Field?

    private func prepareMediaItem(_ item: PhotosPickerItem?) {
        Task {
            guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
            viewModel.selectedImageData = data
            self.title = await viewModel.createNewItem(title, desc)
        }
    }
}
