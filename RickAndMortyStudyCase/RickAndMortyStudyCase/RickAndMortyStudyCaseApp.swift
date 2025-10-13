//
//  RickAndMortyStudyCaseApp.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

import SwiftUI

@main
struct RickAndMortyStudyCaseApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            CharactersView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
