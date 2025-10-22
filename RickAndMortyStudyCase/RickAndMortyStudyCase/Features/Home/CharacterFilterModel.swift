import Foundation
import RickAndMortyAPI

struct CharacterFilter: Equatable {
    var status: Status?
    var gender: Gender?
    
    var isActive: Bool {
        status != nil || gender != nil
    }
    
    mutating func reset() {
        status = nil
        gender = nil
    }
}

extension Status: @retroactive CaseIterable {
    public static var allCases: [Status] {
        [.alive, .dead, .unknown]
    }
    
    var displayName: String {
        switch self {
        case .alive: return "Alive"
        case .dead: return "Dead"
        case .unknown: return "Unknown"
        @unknown default:
            fatalError()
        }
    }
}

extension Gender: @retroactive CaseIterable {
    public static var allCases: [Gender] {
        [.male, .female, .genderless, .unknown]
    }
    
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .genderless: return "Genderless"
        case .unknown: return "Unknown"
        @unknown default:
            fatalError()
        }
    }
}

