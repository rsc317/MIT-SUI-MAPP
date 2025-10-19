//
//  MediaItemRepository+Protocol.swift
//  MIS
//
//  Created by Emircan Duman on 17.10.25.
//

import Foundation
import SwiftData

protocol MediaItemRepositoryProtocol {
    func fetchAll() async throws -> [MediaItem]
    func fetch(byId id: PersistentIdentifier) async throws -> MediaItem?
    func fetch(byUUID uuid: UUID) async throws -> MediaItem?
    func add(_ model: MediaItem) async throws
    func delete(_ model: MediaItem) async throws
    func delete(byUUID uuid: UUID) async throws
    func update(_ model: MediaItem) async throws
}
