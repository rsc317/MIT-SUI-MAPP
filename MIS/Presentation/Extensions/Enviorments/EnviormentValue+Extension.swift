//
//  EnviormentValue+Extension.swift
//  MIS
//
//  Created by Emircan Duman on 16.11.25.
//

import SwiftUI

extension EnvironmentValues {
    var coordinator: AppCoordinator {
        get { self[CoordinatorKey.self] }
        set { self[CoordinatorKey.self] = newValue }
    }
}
