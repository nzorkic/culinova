//
//  RegisterView.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject private var auth: AuthService
    
    @Environment(\.dismiss) private var dismiss
    @State var vm = AuthViewModel()

    var body: some View {
        VStack(spacing: 24) {
            TextField("Email", text: $vm.email)
                .textContentType(.username)
                .autocapitalization(.none)
                .textFieldStyle(.roundedBorder)
            SecureField("Password", text: $vm.password)
                .textFieldStyle(.roundedBorder)

            Button("Create Account") {
                Task {
                    await vm.register()
                    if vm.error == nil { dismiss() }
                }
            }
            .buttonStyle(AccentButtonStyle())

            if let e = vm.error {
                Text(e).foregroundStyle(.red)
            }
        }
        .padding()
    }
}
