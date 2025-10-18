//
//  PersistenceController.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Foundation
import SwiftData

public class PersistenceController {
    // MARK: - Lifecycle

    init(inMemory: Bool = false) {
        let schema = Self.getSchema()
        let configuration: ModelConfiguration

        configuration = ModelConfiguration(isStoredInMemoryOnly: inMemory)

        do {
            container = try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - Internal

    let container: ModelContainer

    @MainActor
    var context: ModelContext { container.mainContext }

    func makeBackgroundContext() -> ModelContext {
        ModelContext(container)
    }

    // MARK: - Private

    private static func getSchema() -> Schema {
        Schema([MediaItem.self])
    }
}
