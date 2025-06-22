import SwiftUI

extension View {
    /// Gives any view a rounded-corner “card” with a soft shadow.
    func cardStyle() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
            )
            .padding(.horizontal)   // keeps cards away from screen edges
    }
}
