//
//  Text&EditorFields.swift
//  MIS
//
//  Created by Emircan Duman on 18.10.25.
//

import SwiftUI

extension UIComponentFactory {
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
}
