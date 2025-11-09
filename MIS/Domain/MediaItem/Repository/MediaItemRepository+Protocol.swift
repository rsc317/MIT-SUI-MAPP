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
    func fetch(byUUID id: UUID) async throws -> MediaItem?
    func save(shouldSaveLocal: Bool, data: Data, title: String, desc: String, file: String) async throws -> MediaItem
    func update(byUUID id: UUID, data: Data, title: String, desc: String) async throws
    func delete(byUUID id: UUID) async throws
    func getImage(_ id: UUID) async throws -> Data?
}
