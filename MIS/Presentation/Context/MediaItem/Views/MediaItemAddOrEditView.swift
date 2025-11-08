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
    @State private var showSaveOptions = false

    var body: some View {
        let imageData = viewModel.selectedImageData

        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 8) {
                    UIComponentFactory.createTextfield(
                        label: MediaItemLK.TITLE,
                        text: $viewModel.title,
                        accessibilityId: MediaItemAID.TITLE
                    )
                    .focused($focusedField, equals: .title)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .desc }
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(titleError != nil ? .error : Color.clear, lineWidth: 2)
                    )

                    if let titleError {
                        Text(titleError)
                            .font(.caption)
                            .foregroundColor(.error)
                    }

                    ZStack {
                        PhotosPicker(
                            selection: $selectedItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            if let imageData, let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 210)
                                    .frame(maxWidth: .infinity)
                                    .clipped()
                            } else {
                                Image(systemName: "photo.on.rectangle.angled.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(imageError != nil ? .error : .accentColor)
                                    .frame(maxWidth: .infinity, maxHeight: 210)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(imageError != nil ? .error : .accentColor, lineWidth: 1)
                                    )
                            }
                        }
                        .onChange(of: selectedItem) { _, newItem in
                            prepareMediaItem(newItem)
                            imageError = nil
                        }
                    }

                    if let imageError {
                        Text(imageError)
                            .font(.caption)
                            .foregroundColor(.error)
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
                                    await viewModel.deleteCurrentItem()
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
                            if isEditMode {
                                viewModel.updateItem()
                                coordinator.dismissSheet()
                            } else {
                                showSaveOptions = true
                            }
                        },
                        accessibilityId: MediaItemAID.BUTTON_SAVE
                    )
                }
            }
            .onAppear {
                isEditMode = viewModel.currentItem != nil
                viewModel.onAppearAction()
            }
            .onDisappear {
                viewModel.onDisappearAction()
            }
            .onChange(of: viewModel.title) { _, newValue in
                if !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    titleError = nil
                }
            }
            .confirmationDialog("Wie möchtest du speichern?", isPresented: $showSaveOptions, titleVisibility: .visible) {
                Button("Lokal speichern") {
                    saveOnLocalAction()
                }
                Button("Auf Server speichern") {
                    //saveOnServerAction()
                }

                Button("Abbrechen", role: .cancel) {}
            }
        }
    }

    // MARK: - Private

    @State private var isEditMode: Bool = false
    @FocusState private var focusedField: Field?
    
//
//    private func saveOnServerAction() {
//        Task {
//            validateView()
//            guard titleError == nil, imageError == nil else { return }
//
//            if isEditMode {
//                viewModel.selectedItem?.title = title
//                viewModel.selectedItem?.desc = desc
//                await viewModel.saveSelectedItem()
//            } else {
//                viewModel.newItem?.title = title
//                viewModel.newItem?.desc = desc
//                viewModel.newItem?.location = .remote
//                await viewModel.saveNewItem()
//            }
//            coordinator.dismissSheet()
//        }
//    }
//
    private func saveOnLocalAction() {
        Task {
            validateView()
            guard titleError == nil, imageError == nil else { return }
            await viewModel.saveNewItem()
            coordinator.dismissSheet()
        }
    }

    private func prepareMediaItem(_ item: PhotosPickerItem?) {
        Task {
            guard let data = try? await item?.loadTransferable(type: Data.self) else { return }
            let mime = item?.supportedContentTypes.first?.preferredMIMEType ?? "application/octet-stream"
            let ext = MimeType.getExtension(for: mime)
            viewModel.prepareMediaItem(data, ext)
        }
    }

    private func validateView() {
        titleError = nil
        imageError = nil

        if viewModel.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            titleError = "Titel darf nicht leer sein."
        }

        if viewModel.selectedImageData == nil {
            imageError = "Bitte wähle ein Bild aus."
        }
    }
}
