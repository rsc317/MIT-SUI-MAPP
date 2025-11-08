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
    func save(_ dto: MediaItemDTO) async throws
    func update(_ dto: MediaItemDTO) throws
    func delete(byUUID id: UUID) async throws
    func saveImageExtern(data: Data, fileName: String) async throws -> String
    func getExternImage(dbID: String) throws -> Data?
    func updateImageExtern(data: Data, dbID: String) throws
    func deleteImageExtern(dbID: String) async throws
    func saveImageLocal(data: Data, fileName: String) async throws
    func getLocalImage(fileName: String) throws -> Data?
    func updateImageLocal(data: Data, fileName: String) throws
    func deleteImageLocal(fileName: String) async throws
}
