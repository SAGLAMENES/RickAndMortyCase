//
//  SettingsViewModel.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 15.10.2025.
//

 
import SwiftUI
//import Firebase
protocol SettingsViewModelProtocol: ObservableObject {
    var isDarkMode: Bool { get set }
    var selectedLanguage: String { get set }
    var languages: [String] { get }
    func logout()
}

final class SettingsViewModel: SettingsViewModelProtocol {
    @AppStorage("isDarkMode") var isDarkMode = false
    @AppStorage("selectedLanguage") var selectedLanguage = "English"
    
    let languages = ["English", "Türkçe", "Deutsch", "Español"]
    
    func logout() {
      
    }
}
