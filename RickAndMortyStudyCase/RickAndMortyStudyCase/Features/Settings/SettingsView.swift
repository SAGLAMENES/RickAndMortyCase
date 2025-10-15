//
//  SettingsView.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 13.10.2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Appearance") {
                    Toggle("Dark Mode", isOn: $viewModel.isDarkMode)
                }
                
                Section("Language") {
                    Picker("App Language", selection: $viewModel.selectedLanguage) {
                        ForEach(viewModel.languages, id: \.self) { lang in
                            Text(lang)
                        }
                    }
                }
                
                Section("Account") {
                    Button("Log Out") {
                        viewModel.logout()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
        }
        .preferredColorScheme(viewModel.isDarkMode ? .dark : .light)
    }
}

#Preview {
    SettingsView()
}
