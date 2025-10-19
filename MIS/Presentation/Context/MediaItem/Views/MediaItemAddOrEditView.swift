//
//  DrivingStudentAddView.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.

import SwiftUI

struct MediaItemAddOrEditView: View {
    // MARK: - Internal

    enum Field: Hashable {
        case title, desc
    }

    @Environment(AppCoordinator.self) private var coordinator
    @State var viewModel: MediaItemViewModel

    var body: some View {
        NavigationStack {
            Form {
                UIComponentFactory.createSection(
                    label: MediaItemLK.SECTION_PERSONAL_INFORMATION,
                    accessibilityId: MediaItemAID.SECTION_MEDIA_ITEM
                ) {
                    UIComponentFactory.createTextfield(
                        label: MediaItemLK.TITLE,
                        text: $title,
                        accessibilityId: MediaItemAID.TITLE
                    )
                    .focused($focusedField, equals: .title)
                    .submitLabel(.next)
                    .onSubmit { focusedField = .desc }

                    UIComponentFactory.createTextEditor(
                        label: MediaItemLK.DESC,
                        text: $desc,
                        accessibilityId: MediaItemAID.DESC
                    )
                    .focused($focusedField, equals: .desc)
                    .submitLabel(.done)
                }
            }
            .background(Color.background)
            .navigationTitle(isEditMode ? MediaItemLK.EDIT_NAV_TITLE.localized : MediaItemLK.ADD_NAV_TITLE.localized)
            .toolbarTitleDisplayMode(.inline)
            .modifier(NavigationBarTitleColorModifier(color: .accent))
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
                        color: .error
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
                                    let formData = MediaItemDataForm(
                                        title: title,
                                        desc: desc,
                                        src: URL(fileURLWithPath: "defaultPicture"),
                                        createDate: Date(),
                                        type: .picture
                                    )
                                    await viewModel.addItem(from: formData)
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
            }
            .onDisappear {
                viewModel.selectedItem = nil
            }
        }
    }

    // MARK: - Private

    @State private var title = ""
    @State private var desc = ""
    @State private var isEditMode: Bool = false
    @FocusState private var focusedField: Field?
}
