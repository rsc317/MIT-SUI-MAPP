//
//  DrivingStudentAddView.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.

import SwiftUI

struct MediaItemAddView: View {
    // MARK: - Internal

    enum Field: Hashable {
        case title, desc
    }

    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject var viewModel: MediaItemViewModel

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
            .navigationTitle(MediaItemLK.ADD_NAV_TITLE.localized)
            .toolbarTitleDisplayMode(.inline)
            .modifier(NavigationBarTitleColorModifier(color: .accent))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    UIComponentFactory.createToolbarButton(
                        label: GlobalLocalizationKeys.BUTTON_CANCEL,
                        action: { coordinator.dismissSheet() },
                        accessibilityId: MediaItemAID.BUTTON_CANCEL
                    )
                }

                ToolbarItem(placement: .confirmationAction) {
                    UIComponentFactory.createToolbarButton(
                        label: GlobalLocalizationKeys.BUTTON_SAVE,
                        action: {
                            Task {
                                let formData = MediaItemDataForm(
                                    title: title,
                                    desc: desc,
                                    src: URL(fileURLWithPath: "defaultPicture"),
                                    createDate: Date(),
                                    type: .picture
                                )
                                await viewModel.addItem(from: formData)
                                coordinator.dismissSheet()
                            }
                        },
                        accessibilityId: MediaItemAID.BUTTON_SAVE
                    )
                }
            }
            .tint(.accentColor)
            .onAppear { focusedField = .title }
        }
    }

    // MARK: - Private

    @State private var title = ""
    @State private var desc = ""

    @FocusState private var focusedField: Field?
}
