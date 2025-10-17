//
//  MediaItemRepository+Protocol.swift
//  MIS
//
//  Created by Emircan Duman on 17.10.25.
//

import SwiftData

protocol MediaItemRepositoryProtocol {
    func fetchAll() async throws -> [MediaItem]
    func fetch(byId id: PersistentIdentifier) async throws -> MediaItem?
    func add(_ model: MediaItem) async throws
    func delete(_ model: MediaItem) async throws
}
