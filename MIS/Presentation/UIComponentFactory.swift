//
//  UIComponentFactory.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//


import SwiftUI

class UIComponentFactory {
    // MARK: - Primary Actions
    static func createAddButton(systemImage: String? = "plus.circle",
                                action: @escaping () -> Void,
                                accessibilityId: AccessibilityIdentifierProtocol) -> some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
            }
            .cornerRadius(12)
        }
        .foregroundStyle(.buttonPrimary)
        .accessibilityIdentifier(accessibilityId.rawValue)
    }

    static func createDeleteButton(label: LocalizationKeyProtocol = GlobalLocalizationKeys.BUTTON_DELETE,
                                   systemImage: String? = "trash",
                                   action: @escaping () -> Void,
                                   accessibilityId: AccessibilityIdentifierProtocol) -> some View {
        Button(role: .destructive, action: {
            action()
        }) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(label.localized)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, minHeight: 50)
            .background(Color.error)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .accessibilityIdentifier(accessibilityId.rawValue)
    }

    static func createInteractionButton(label: LocalizationKeyProtocol, action: @escaping () -> Void, accessibilityId: AccessibilityIdentifierProtocol) -> some View {
        Button(action: {
            action()
        }) {
            Text(label.localized)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.interaction)
                .foregroundColor(.text)
                .cornerRadius(12)
        }
        .accessibilityIdentifier(accessibilityId.rawValue)
    }
    

    
    static func createPasswordField(label: LocalizationKeyProtocol, text: Binding<String>, accessibilityId: AccessibilityIdentifierProtocol) -> some View {
        SecureField(label.localized, text: text)
            .padding()
            .cornerRadius(12)
            .textContentType(.oneTimeCode)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.accent, lineWidth: 1)
            )
            .accessibilityIdentifier(accessibilityId.rawValue)
    }
    
    static func createInteractionFooter(footerText: LocalizationKeyProtocol, footerButtonText: LocalizationKeyProtocol, view: some View, accessibilityId: AccessibilityIdentifierProtocol) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(footerText.localized)
                    .font(.footnote)
                NavigationLink {
                    view
                } label: {
                    Text(footerButtonText.localized)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.interaction)
                }
                .accessibilityIdentifier(accessibilityId.rawValue)
            }
        }
    }
    
    static func createInteractionFooter(footerText: LocalizationKeyProtocol, footerButtonText: LocalizationKeyProtocol, action: @escaping () -> Void, accessibilityId: AccessibilityIdentifierProtocol) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(footerText.localized)
                    .font(.footnote)
                Button {
                    action()
                } label: {
                    Text(footerButtonText.localized)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(.interaction)
                }
                .accessibilityIdentifier(accessibilityId.rawValue)
            }
        }
    }
    
    static func errorText(_ text: String) -> some View {
        Text(text)
            .foregroundColor(Color.error)
            .font(.footnote)
    }
    
    static func succesText(_ text: String) -> some View {
        Text(text)
            .foregroundColor(Color.success)
            .font(.footnote)
    }
    
    static func createTextfield(label: LocalizationKeyProtocol, text: Binding<String>, accessibilityId: AccessibilityIdentifierProtocol) -> some View {
        TextField(label.localized, text: text)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.textFieldBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.textFieldBorder, lineWidth: 1)
            )
            .foregroundStyle(.text)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .accessibilityIdentifier(accessibilityId.rawValue)
    }
    
    static func createTextEditor(label: LocalizationKeyProtocol,
                                 text: Binding<String>,
                                 accessibilityId: AccessibilityIdentifierProtocol,
                                 minHeight: CGFloat = 120) -> some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.textFieldBackground)
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.textFieldBorder, lineWidth: 1)

            if text.wrappedValue.isEmpty {
                Text(label.localized)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 14)
            }

            TextEditor(text: text)
                .frame(minHeight: minHeight)
                .padding(8)
                .foregroundStyle(.text)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .accessibilityIdentifier(accessibilityId.rawValue)
    }
    
    // MARK: - Section Factory
    static func createSection<Content: View>(
        label: LocalizationKeyProtocol,
        accessibilityId: AccessibilityIdentifierProtocol,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label.localized)
                .font(.title)
                .foregroundColor(.accent)
            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .padding()
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.accent, lineWidth: 1)
                    .allowsHitTesting(false)
            )
        }
        .accessibilityIdentifier(accessibilityId.rawValue)
    }

    // MARK: - DatePicker Factory
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

    // MARK: - Picker Factory (Generic)
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

