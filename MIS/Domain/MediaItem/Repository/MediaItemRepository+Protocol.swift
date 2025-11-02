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
    func fetch(byId id: PersistentIdentifier) async throws -> MediaItemDTO?
    func add(_ dto: MediaItemDTO) async throws
    func update(_ dto: MediaItemDTO) async throws
    func delete(byUUID id: UUID) async throws
    func saveImageLocally(_ data: Data, with fileName: String) throws -> String
    func getImageURL(for fileName: String) -> URL
}
