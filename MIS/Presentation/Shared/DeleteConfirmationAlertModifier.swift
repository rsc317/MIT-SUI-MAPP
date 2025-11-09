//
//  DeleteConfirmationAlertModifier.swift
//  MIS
//
//  Created by Emircan Duman on 09.11.25.
//

import Foundation
import SwiftUI

// MARK: - DeleteConfirmationAlertModifier -

struct DeleteConfirmationAlertModifier: ViewModifier {
    let isPresented: Binding<Bool>
    let title: String
    let message: String
    let destructiveAction: () -> Void

    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: isPresented) {
                Button("Löschen", role: .destructive, action: destructiveAction)
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text(message)
            }
    }
}

extension View {
    func deleteConfirmationAlert(isPresented: Binding<Bool>, title: String, message: String, destructiveAction: @escaping () -> Void) -> some View {
        modifier(DeleteConfirmationAlertModifier(isPresented: isPresented, title: title, message: message, destructiveAction: destructiveAction))
    }
}
