//
//  TextStyles.swift
//  RickAndMortyStudyCase
//
//  Created by Enes on 16.10.2025.
//

import SwiftUI

struct TextStyles: View {
    var body: some View {
        Text("Font")
            .titleStyle()
        Text("Body")
            .bodyStyle()
        Text("Caption")
        .captionStyle()
    }
}

#Preview {
    TextStyles()
}
