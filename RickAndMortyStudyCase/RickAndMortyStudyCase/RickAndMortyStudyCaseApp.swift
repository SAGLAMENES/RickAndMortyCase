//
//  RickAndMortyStudyCaseApp.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

import SwiftUI
import RickAndMortyPersistence
import RickAndMortyAPI
@main
struct RickAndMortyStudyCaseApp: App {
    
    private let api = RickAndMortyAPIClient()
    private let local = DefaultCharacterLocalDataSource()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
