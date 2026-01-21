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

    @Environment(\.mediaItemCoordinator) private var coordinator
    @State var viewModel: MediaItemAddOrEditViewModel
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var titleError: String? = nil
    @State private var imageError: String? = nil
    @State private var showSaveOptions = false
    @State private var showDeleteItemAlert = false

    var body: some View {
        let imageData = viewModel.mediaItemViewModel.selectedImageData

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
            .navigationTitle(viewModel.isEditMode ? MediaItemLK.EDIT_NAV_TITLE.localized : MediaItemLK.ADD_NAV_TITLE.localized)
            .toolbarTitleDisplayMode(.inline)
            .modifier(NavigationBarTitleColorModifier(color: .accentColor))
            .deleteConfirmationAlert(
                isPresented: $showDeleteItemAlert,
                title: "Medium löschen?",
                message: "Möchten Sie das Medium \(viewModel.mediaItemViewModel.currentItemTitle)?",
                destructiveAction: {
                    Task {
                        await viewModel.mediaItemViewModel.deleteCurrentItem()
                        coordinator.dismissSheet()
                    }
                }
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    UIComponentFactory.createToolbarButton(
                        label: viewModel.isEditMode ? GlobalLocalizationKeys.BUTTON_DELETE : GlobalLocalizationKeys.BUTTON_CANCEL,
                        action: {
                            if viewModel.isEditMode {
                                showDeleteItemAlert = true
                            } else {
                                coordinator.dismissSheet()
                            }
                        },
                        accessibilityId: viewModel.isEditMode ? MediaItemAID.BUTTON_DELETE : MediaItemAID.BUTTON_CANCEL,
                        color: viewModel.isEditMode ? .error : .accentColor
                    )
                }
                ToolbarItem(placement: .confirmationAction) {
                    UIComponentFactory.createToolbarButton(
                        label: GlobalLocalizationKeys.BUTTON_SAVE,
                        action: {
                            Task {
                                if viewModel.isEditMode {
                                    await viewModel.updateItem()
                                    
                                    if let error = viewModel.error {
                                        viewModel.mediaItemViewModel.error = error
                                    } else {
                                        coordinator.dismissSheet()
                                    }
                                } else {
                                    validateView()
                                    showSaveOptions = titleError == nil && imageError == nil
                                }
                            }
                        },
                        accessibilityId: MediaItemAID.BUTTON_SAVE
                    )
                }
            }
            .onAppear {
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
                    saveAction()
                }
                Button("Auf Server speichern") {
                    saveAction(false)
                }
                Button("Abbrechen", role: .cancel) {}
            } 
            .alert("Fehler beim Speichern", isPresented: .init(
                get: { viewModel.error != nil },
                set: { if !$0 { viewModel.error = nil } }
            )) {
                Button("Abbrechen", role: .cancel) {
                    viewModel.error = nil
                    coordinator.dismissSheet()
                }
                
                Button("Erneut versuchen") {
                    viewModel.error = nil
                    showSaveOptions = true
                }
            } message: {
                if let error = viewModel.error {
                    switch error {
                    case .repositoryFailure(let details):
                        Text("Es gab ein Problem beim Speichern: \(details)")
                    case .itemNotFound:
                        Text(error.localizedDescription)
                    case .unknown:
                        Text("Ein unbekannter Fehler ist aufgetreten. Bitte versuchen Sie es später erneut.")
                    }
                }
            }
        }
    }

    // MARK: - Private

    @FocusState private var focusedField: Field?

    private func saveAction(_ local: Bool = true) {
        Task { @MainActor in
            print("💾 saveAction gestartet, lokal: \(local)")
            validateView()
            guard titleError == nil, imageError == nil else {
                print("❌ Validierung fehlgeschlagen: titleError=\(titleError ?? "nil"), imageError=\(imageError ?? "nil")")
                return
            }

            await viewModel.saveItem(local)
            
            if let error = viewModel.error {
                print("❌ Fehler beim Speichern: \(error)")
                viewModel.mediaItemViewModel.error = error
            } else {
                print("✅ Speichern erfolgreich, schließe Sheet...")
                coordinator.dismissSheet()
            }
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

        if viewModel.emptyTitle {
            titleError = "Titel darf nicht leer sein."
        }

        if viewModel.emptyImage {
            imageError = "Bitte wähle ein Bild aus."
        }
    }
}
