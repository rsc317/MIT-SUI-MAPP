//
//  MediaItemRepository+Protocol.swift
//  MIS
//
//  Created by Emircan Duman on 17.10.25.
//

import Foundation
import SwiftData

protocol MediaItemRepositoryProtocol {
    func fetchAll() async throws -> [MediaItemDTO]
    func fetch(byUUID id: UUID) throws -> MediaItem?
    func save(toLocalStore: Bool, data: Data, title: String, desc: String, file: String) async throws -> MediaItemDTO
    func update(_ dto: MediaItemDTO, data: Data) throws
    func delete(byUUID id: UUID) async throws
    func getImage(_ dto: MediaItemDTO) async throws -> Data?
}
