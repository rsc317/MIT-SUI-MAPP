//
//  Pickers.swift
//  MIS
//
//  Created by Emircan Duman on 18.10.25.
//

import SwiftUI

extension UIComponentFactory {
    static func createDatePicker(label: LocalizationKeyProtocol,
                                 selection: Binding<Date>,
                                 displayedComponents: DatePickerComponents = .date,
                                 accessibilityId: AccessibilityIdentifierProtocol) -> some View {
        DatePicker(label.localized,
                   selection: selection,
                   displayedComponents: displayedComponents)
            .padding()
            .cornerRadius(12)
            .accessibilityIdentifier(accessibilityId.rawValue)
    }

    static func createDatePicker(label: LocalizationKeyProtocol,
                                 selection: Binding<Date?>,
                                 displayedComponents: DatePickerComponents = .date,
                                 accessibilityId: AccessibilityIdentifierProtocol) -> some View {
        let nonOptionalBinding = Binding<Date>(
            get: { selection.wrappedValue ?? Date() },
            set: { selection.wrappedValue = $0 }
        )
        return createDatePicker(label: label,
                                selection: nonOptionalBinding,
                                displayedComponents: displayedComponents,
                                accessibilityId: accessibilityId)
    }

    static func createPicker<T: Hashable>(label: LocalizationKeyProtocol,
                                          selection: Binding<T>,
                                          options: [T],
                                          titleProvider: @escaping (T) -> String,
                                          accessibilityId: AccessibilityIdentifierProtocol) -> some View {
        Picker(label.localized, selection: selection) {
            ForEach(options, id: \ .self) { option in
                Text(titleProvider(option)).tag(option)
            }
        }
        .padding()
        .cornerRadius(12)
        .pickerStyle(.menu)
        .accessibilityIdentifier(accessibilityId.rawValue)
    }
}
