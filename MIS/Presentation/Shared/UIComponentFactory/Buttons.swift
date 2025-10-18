//
//  Buttons.swift
//  MIS
//
//  Created by Emircan Duman on 18.10.25.
//

import SwiftUI

extension UIComponentFactory {
    static func createAddButton(systemImage: String? = "plus", action: @escaping () -> Void, accessibilityId: AccessibilityIdentifierProtocol) -> some View {
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
        .foregroundStyle(.interaction)
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
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .accessibilityIdentifier(accessibilityId.rawValue)
    }

    static func createToolbarButton(label: LocalizationKeyProtocol, action: @escaping () -> Void, accessibilityId: AccessibilityIdentifierProtocol) -> some View {
        Button(action: {
            action()
        }) {
            Text(label.localized)
                .foregroundStyle(Color.interaction)
        }
        .accessibilityIdentifier(accessibilityId.rawValue)
    }

    static func createPrimaryActionButton(label: LocalizationKeyProtocol, action: @escaping () -> Void, accessibilityId: AccessibilityIdentifierProtocol) -> some View {
        Button(action: {
            action()
        }) {
            Text(label.localized)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.primary)
                .foregroundStyle(.text)
                .cornerRadius(12)
        }
        .accessibilityIdentifier(accessibilityId.rawValue)
    }
}
