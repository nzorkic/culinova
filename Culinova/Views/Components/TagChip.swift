//
//  TagChip.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//


import SwiftUI

struct TagChip: View {
    let text: String
    var selected = false
    
    private var bg: Color   { selected ? Theme.accent : Theme.sky.opacity(0.3) }
    private var fg: Color   { selected ? .white       : Theme.navy }
    
    var body: some View {
        Text(text.capitalized)
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(bg, in: Capsule())
            .foregroundStyle(fg)
    }
}
