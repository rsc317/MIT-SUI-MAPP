//
//  PersistenceController.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//


import SwiftData
import Foundation

public class PersistenceController {
    let container: ModelContainer
    @MainActor var context: ModelContext { container.mainContext }
    
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
    
    func makeBackgroundContext() -> ModelContext {
        ModelContext(container)
    }
    
    private static func getSchema() -> Schema {
        return Schema([MediaItem.self])
    }
}
