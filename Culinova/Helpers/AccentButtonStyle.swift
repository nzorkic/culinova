//
//  AccentButtonStyle.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//

import SwiftUI

/// A pill-shaped, brand-colored button with a subtle press animation.
struct AccentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Theme.accent.gradient)
            )
            .foregroundStyle(.white)
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(duration: 0.3), value: configuration.isPressed)
    }
}
