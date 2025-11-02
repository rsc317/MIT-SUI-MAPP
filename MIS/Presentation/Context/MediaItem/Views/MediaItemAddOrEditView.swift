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
    @State private var titleError: String? = nil
    @State private var imageError: String? = nil

    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            UIComponentFactory.createTextfield(
                                label: MediaItemLK.TITLE,
                                text: $title,
                                accessibilityId: MediaItemAID.TITLE
                            )
                            .focused($focusedField, equals: .title)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .desc }
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(titleError != nil ? Color.red : Color.clear, lineWidth: 1)
                            )
                        }
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
                    buildErrorView()

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
                                validateView()

                                guard titleError == nil, imageError == nil else {
                                    return
                                }
                                
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
            .onChange(of: title) { _, newValue in
                if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    titleError = nil
                }
            }
            .onChange(of: selectedItem) { _, newItem in
                prepareMediaItem(newItem)
                imageError = nil
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
            title = await viewModel.createNewItem(title, desc)
        }
    }

    private func validateView() {
        titleError = nil
        imageError = nil

        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            titleError = "Titel darf nicht leer sein."
        }

        if viewModel.selectedImageData == nil {
            imageError = "Bitte wähle ein Bild aus."
        }
    }

    private func buildErrorView() -> some View {
        VStack {
            if let titleError {
                Text(titleError)
                    .font(.caption)
                    .foregroundColor(.red)
            }

            if let imageError {
                Text(imageError)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}
