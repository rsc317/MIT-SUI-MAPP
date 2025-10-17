//
//  Repository.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Foundation
import SwiftData


final class Repository<Model: PersistentModel>: RepositoryProtocol {
    private let persistence: PersistenceController
    
    init(_ persistence: PersistenceController) {
        self.persistence = persistence
    }
    
    func fetchAll() async throws -> [Model] {
        let context = persistence.makeBackgroundContext()
        return try context.fetch(FetchDescriptor<Model>())
    }
    
    func add(_ model: Model) async throws {
        let context = persistence.makeBackgroundContext()
        context.insert(model)
        try context.save()
    }
    
    func delete(_ model: Model) async throws {
        guard let ctx = model.modelContext else {
            return
        }

        ctx.delete(model)
        try ctx.save()
    }
    func fetch(byId id: PersistentIdentifier) async throws -> Model? {
        let descriptor = FetchDescriptor<Model>(predicate: #Predicate { $0.id == id })
        return try persistence.makeBackgroundContext().fetch(descriptor).first
    }
}
