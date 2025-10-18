//
//  View+Extension.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import SwiftUI

extension View {
    func navigationBarTitleColor(_ color: Color) -> some View {
        modifier(NavigationBarTitleColorModifier(color: color))
    }
}
