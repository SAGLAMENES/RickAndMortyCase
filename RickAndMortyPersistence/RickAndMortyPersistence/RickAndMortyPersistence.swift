//
//  RickAndMortyPersistence.swift
//  RickAndMortyPersistence
//
//  Created by Enes on 13.10.2025.
//

import CoreData

public final class PersistenceController {
    public static let shared = PersistenceController()

    public let container: NSPersistentContainer

    public init(inMemory: Bool = false) {
        let bundle = Bundle(for: PersistenceController.self)
        guard let url = bundle.url(forResource: "RickAndMortyModel", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Core Data model not found in RickAndMortyPersistence bundle")
        }

        container = NSPersistentContainer(name: "RickAndMortyModel", managedObjectModel: model)

        let description = NSPersistentStoreDescription()

        if inMemory {
            description.type = NSInMemoryStoreType
        } else {
            description.type = NSSQLiteStoreType

            let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            let storeURL = appSupport.appendingPathComponent("RickAndMortyModel.sqlite")

            try? FileManager.default.createDirectory(
                at: appSupport,
                withIntermediateDirectories: true,
                attributes: nil
            )

            description.url = storeURL
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
        }

        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { desc, error in
            if let error {
                fatalError("Store load failed: \(error)")
            }
        }

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    public func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }
}
