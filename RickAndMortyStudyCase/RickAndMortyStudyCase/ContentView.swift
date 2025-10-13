//
//  ContentView.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Main", systemImage: "person.fill") {
                CharactersView()
            }
            
            Tab("Favorites", systemImage: "heart.circle") {
                FavoritesView()
            }
            
            Tab("Settings", systemImage: "gear") {
                SettingsView()
            }
            
        }
    }    
}

#Preview {
    ContentView()
}
