//
//  DrivingStudentAddView.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.


import SwiftUI
import SwiftUI

struct MediaItemAddView: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @StateObject var viewModel: MediaItemViewModel

    @State private var title = ""
    @State private var desc = ""

    enum Field: Hashable {
        case title, desc
    }

    @FocusState private var focusedField: Field?

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
                    Button(GlobalLocalizationKeys.BUTTON_CANCEL.localized) {
                        coordinator.dismissSheet()
                    }
                    .accessibilityIdentifier(MediaItemAID.BUTTON_CANCEL.rawValue)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(GlobalLocalizationKeys.BUTTON_SAVE.localized) {
                        Task {
                            let formData = MediaItemFormData(
                                title: title,
                                description: desc,
                                src: URL(fileURLWithPath: "/tmp/sample.png"),
                                createDate: Date(),
                                type: .picture
                            )
                            await viewModel.addItem(from: formData)
                            coordinator.dismissSheet()
                        }
                    }
                    .accessibilityIdentifier(MediaItemAID.BUTTON_SAVE.rawValue)
                }
            }
            .tint(.accentColor)
            .onAppear { focusedField = .title }
        }
    }
}
