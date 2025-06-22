//
//  Theme.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//


import SwiftUI

enum Theme {
    // Branding palette
    static let sky      = Color(hex: "8ECAE6")
    static let aqua     = Color(hex: "219EBC")
    static let navy     = Color(hex: "023047")
    static let amber    = Color(hex: "FFB703")
    static let orange   = Color(hex: "FB8500")

    /// Global accent
    static let accent = aqua
}

// Small Color-init helper
extension Color {
    init(hex: String) {
        let v = UInt64(hex, radix: 16) ?? 0
        let r = Double((v >> 16) & 0xFF) / 255
        let g = Double((v >> 8)  & 0xFF) / 255
        let b = Double(v & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }
}
