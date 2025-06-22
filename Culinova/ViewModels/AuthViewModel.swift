//
//  AuthViewModel.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//


import Foundation

@Observable class AuthViewModel {
    var email = ""
    var password = ""
    var error: String?

    private let service = AuthService.shared

    @MainActor
    func login() async {
        do   { try await service.signIn(email: email, password: password) }
        catch { self.error = error.localizedDescription }
    }
    @MainActor
    func register() async {
        do   { try await service.signUp(email: email, password: password) }
        catch { self.error = error.localizedDescription }
    }
}
