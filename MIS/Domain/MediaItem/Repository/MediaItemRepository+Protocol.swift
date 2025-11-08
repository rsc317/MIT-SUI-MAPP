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
    func update(_ dto: MediaItemDTO) throws
    func delete(byUUID id: UUID) async throws
    func getExternImage(dbID: String) throws -> Data?
    func updateImageExtern(data: Data, dbID: String) throws
    func getLocalImage(file: String) throws -> Data?
    func updateImageLocal(data: Data, file: String) throws
}
