//
//  Color+Extensions.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 16.10.2025.
//

import SwiftUI

public extension Color {
    init(hex: UInt32, alpha: Double = 1.0) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: alpha)
    }

    init?(hexString: String, alpha: Double = 1.0) {
        let cleaned = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        guard cleaned.count == 6, let value = UInt32(cleaned, radix: 16) else { return nil }
        self.init(hex: value, alpha: alpha)
    }

    static func dynamic(light: UInt32, dark: UInt32) -> Color {
        #if canImport(UIKit)
        return Color(UIColor { trait in
            let v: UInt32 = (trait.userInterfaceStyle == .dark) ? dark : light
            return UIColor(hex: v)
        })
        #else
        return Color(hex: dark)
        #endif
    }
}

#if canImport(UIKit)
public extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        let cleaned = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        guard cleaned.count == 6, let value = UInt32(cleaned, radix: 16) else { return nil }
        self.init(hex: value, alpha: alpha)
    }
}
#endif

public enum RMPalette {
    public static let portalGreen      = Color(hex: 0x00FF88)
    public static let meeseeksBlue     = Color(hex: 0x2CC7FF)
    public static let mortyYellow      = Color(hex: 0xF5D000)
    public static let plumbusPink      = Color(hex: 0xFF7AB6)
    public static let rickHairBlue     = Color(hex: 0xB8E7F7)

    public static let galacticBlack    = Color(hex: 0x0A0E14)
    public static let spaceGray        = Color(hex: 0x121822)
    public static let cardSurface      = Color(hex: 0x151E2B)

    public static let textPrimary      = Color(hex: 0xE5E7EB)
    public static let textSecondary    = Color(hex: 0x9CA3AF)
}

public enum RMColor {
    public enum semantic {
        public static let background    = Color.dynamic(light: 0xF6F8FC, dark: 0x0B1017)
        public static let surface       = Color.dynamic(light: 0xFFFFFF, dark: 0x0F1621)

        public static let textPrimary   = Color.dynamic(light: 0x0B1017, dark: 0xE5E7EB)
        public static let textSecondary = Color.dynamic(light: 0x3F4B59, dark: 0x9CA3AF)

        public static let tint          = RMPalette.portalGreen
        public static let accent        = RMPalette.meeseeksBlue
    }
}


public enum RMExtra {
    public enum semantic {
        public static let separator   = Color.dynamic(light: 0xE5E7EB, dark: 0x223041)

        public static let disabledText   = Color.dynamic(light: 0x9CA3AF, dark: 0x6B7280)
        public static let disabledSurface = Color.dynamic(light: 0xF3F4F6, dark: 0x141B25)

        public static let success = Color.dynamic(light: 0x166534, dark: 0x22C55E)
        public static let warning = Color.dynamic(light: 0xB45309, dark: 0xF59E0B)
        public static let error   = Color.dynamic(light: 0xB91C1C, dark: 0xEF4444)
    }
}

public enum RMGradient {
    public static var portal: LinearGradient {
        LinearGradient(colors: [RMPalette.mortyYellow, RMPalette.portalGreen, Color(hex: 0x0D7A00)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    public static var sciFi: LinearGradient {
        LinearGradient(colors: [Color(hex: 0x00E5FF), RMPalette.meeseeksBlue, Color(hex: 0x7E57C2)],
                       startPoint: .top, endPoint: .bottomTrailing)
    }
}
