//
//  GlobalBackgroundModifier.swift
//  MIS
//
//  Created by Emircan Duman on 19.10.25.
//
import SwiftUI

struct GlobalBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(Color.background.ignoresSafeArea())
    }
}
