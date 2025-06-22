//
//  LoginView.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//


import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthService
    
    @State var vm = AuthViewModel()
    @State private var showRegister = false

    var body: some View {
        VStack(spacing: 24) {
            TextField("Email", text: $vm.email)
                .textContentType(.username)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $vm.password)
                .textFieldStyle(.roundedBorder)

            Button("Sign In") {
                Task { await vm.login() }
            }
            .buttonStyle(AccentButtonStyle())

            Button("Sign in with Apple") {
                AuthService.shared.startSignInWithApple()
            }
            .buttonStyle(AccentButtonStyle())

            Button("Create new account") { showRegister = true }
                .padding(.top)

            if let e = vm.error {
                Text(e).foregroundStyle(.red)
            }
        }
        .padding()
        .sheet(isPresented: $showRegister) { RegisterView() }
    }
}
