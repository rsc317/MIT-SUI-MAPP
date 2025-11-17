//
//  PersistenceController+Protocol.swift
//  MIS
//
//  Created by Emircan Duman on 16.11.25.
//
import SwiftData

protocol PersistenceControllerProtocol {
    var container: ModelContainer { get }
    var context: ModelContext { get }
    func makeBackgroundContext() -> ModelContext
}
