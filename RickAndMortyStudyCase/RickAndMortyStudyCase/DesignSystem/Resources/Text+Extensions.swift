//
//  Text+Extensions.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 16.10.2025.
//

import SwiftUI
struct TitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("AvenirNext-DemiBold", size: 49, relativeTo: .body))
    }
}
struct BodyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("AvenirNext-DemiBold", size: 29, relativeTo: .body))
    }
}
struct CaptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.custom("AvenirNext-DemiBold", size: 19, relativeTo: .body))
    }
}

extension View {
    func titleStyle() -> some View {
        modifier(TitleStyle())
    }
    func bodyStyle() -> some View {
        modifier(BodyStyle())
    }
    func captionStyle() -> some View {
        modifier(CaptionStyle())
    }
}
