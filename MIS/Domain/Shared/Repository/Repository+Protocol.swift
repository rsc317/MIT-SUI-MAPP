//
//  Repository+Protocol.swift
//  MIS
//
//  Created by Emircan Duman on 16.10.25.
//

import Foundation
import SwiftData

protocol RepositoryProtocol {
    associatedtype Model: PersistentModel
    func fetchAll() async throws -> [Model]
    func add(_ model: Model) async throws
    func delete(_ model: Model) async throws
    func fetch(byId id: PersistentIdentifier) async throws -> Model?
}
