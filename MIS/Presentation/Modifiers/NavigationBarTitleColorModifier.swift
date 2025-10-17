//
//  NavigationBarTitleColorModifier.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//


import SwiftUI

struct NavigationBarTitleColorModifier: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .onAppear {
                let coloredAppearance = UINavigationBarAppearance()
                coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(color)]
                coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor(color)]
                UINavigationBar.appearance().standardAppearance = coloredAppearance
            }
    }
}