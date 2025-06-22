//
//  OptionalStringBinding.swift
//  Culinova
//
//  Created 22 Jun 2025
//

import SwiftUI

// MARK: - String helper
///
/// Turns a `Binding<String?>` into a non-optional `Binding<String>`
/// and writes `nil` back when the text field is cleared.
///
extension Binding where Value == String {
    /// - Parameters:
    ///   - source: The original optional binding (`Binding<String?>`)
    ///   - defaultValue: What to show when the value is `nil` (defaults to an empty string)
    init(_ source: Binding<String?>, _ defaultValue: String = "") {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in
                source.wrappedValue = newValue.isEmpty ? nil : newValue
            }
        )
    }
}

// MARK: - Double helper
///
/// Same idea for optional numbers (handy for quantities).
/// Writes `nil` back when the user clears the field or sets the *fallback* value.
///
extension Binding where Value == Double {
    init(_ source: Binding<Double?>, _ defaultValue: Double = 0) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { newValue in
                source.wrappedValue = (newValue == defaultValue) ? nil : newValue
            }
        )
    }
}
