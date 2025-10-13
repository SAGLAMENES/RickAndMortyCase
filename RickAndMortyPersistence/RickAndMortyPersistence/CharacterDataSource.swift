//
//  CharacterDataSource.swift
//  RickAndMortyPersistence
//
//  Created by Enes on 13.10.2025.
//

import CoreData

public struct CharacterLocal: Equatable, Sendable {
    public let id: Int64
    public let name: String
    public let status: String
    public let gender: String
    public let species: String
    public let imageURL: String
    public let locationName: String
    
    public init(
            id: Int64,
            name: String,
            status: String,
            gender: String,
            species: String,
            imageURL: String,
            locationName: String
        ) {
            self.id = id
            self.name = name
            self.status = status
            self.gender = gender
            self.species = species
            self.imageURL = imageURL
            self.locationName = locationName
        }
}

public protocol CharacterLocalDataSource {
    func addFavorite(_ item: CharacterLocal) throws
    func removeFavorite(id: Int64) throws
    func isFavorite(id: Int64) throws -> Bool
    func fetchFavoriteIDs() throws -> Set<Int64>
    func fetchFavorites() throws -> [CharacterLocal]
}

public final class DefaultCharacterLocalDataSource: CharacterLocalDataSource {
    private let container: NSPersistentContainer
    public init(container: NSPersistentContainer = PersistenceController.shared.container) {
        self.container = container
    }

    public func addFavorite(_ it: CharacterLocal) throws {
        let context = container.viewContext
        let request: NSFetchRequest<CharacterCD> = CharacterCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", it.id)
        request.fetchLimit = 1
        let obj = try context.fetch(request).first ?? CharacterCD(context: context)
        obj.id = it.id
        obj.name = it.name
        obj.status = it.status
        obj.gender = it.gender
        obj.species = it.species
        obj.imageURL = it.imageURL
        obj.locationName = it.locationName
        obj.addedAt = Date()
        try context.save()
    }

    public func removeFavorite(id: Int64) throws {
        let context = container.viewContext
        let request: NSFetchRequest<CharacterCD> = CharacterCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", id)
        if let obj = try context.fetch(request).first {
            context.delete(obj)
            try context.save()
        }
    }

    public func isFavorite(id: Int64) throws -> Bool {
        let context = container.viewContext
        let request: NSFetchRequest<NSFetchRequestResult> = CharacterCD.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", id)
        request.fetchLimit = 1
        return try context.count(for: request) > 0
    }

    public func fetchFavoriteIDs() throws -> Set<Int64> {
        let context = container.viewContext
        let rows: [CharacterCD] = try context.fetch(CharacterCD.fetchRequest())
        return Set(rows.map { $0.id })
    }

    public func fetchFavorites() throws -> [CharacterLocal] {
        let context = container.viewContext
        let rows: [CharacterCD] = try context.fetch(CharacterCD.fetchRequest())
        return rows.map {
            CharacterLocal(
                id: $0.id,
                name: $0.name ?? "",
                status: $0.status ?? "",
                gender: $0.gender ?? "",
                species: $0.species ?? "",
                imageURL: $0.imageURL ?? "",
                locationName: $0.locationName ?? ""
            )
        }
    }
}

