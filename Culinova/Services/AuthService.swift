//
//  AuthService.swift
//  Culinova
//
//  Created by Nikola Zorkic on 22. 6. 2025..
//


import Foundation
import SwiftData
import FirebaseAuth
import AuthenticationServices
import CryptoKit

final class AuthService: NSObject, ObservableObject {
    @Published var user: FirebaseAuth.User?   // Firebase user object
    @Published var currentUser: User?

    private var context: ModelContext!
    
    // MARK: singleton
    static let shared = AuthService()
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    /// Set once at app launch.
    static func setContext(_ context: ModelContext) {
        shared.context = context
    }   // use your singleton / inject if needed

    private override init() { super.init()
        user = Auth.auth().currentUser
        authStateHandle = Auth.auth().addStateDidChangeListener { _, u in
            self.user = u
            guard let uid = u?.uid else { self.currentUser = nil; return }

            if let existing = try? self.context.fetch(
                FetchDescriptor<User>(predicate: #Predicate { $0.firebaseUID == uid })
            ).first {
                // Ensure the record has the latest UID (for migrations where it was nil)
                if existing.firebaseUID == nil {
                    existing.firebaseUID = uid
                }
                self.currentUser = existing
            } else {
                let newUser = User(username: uid.lowercased())
                newUser.firebaseUID = uid
                newUser.displayName = u?.displayName
                self.context.insert(newUser)
                self.currentUser = newUser
            }
        }
    }
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    // MARK: - Email / password
    func signUp(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    func signOut() throws { try Auth.auth().signOut() }

    // MARK: - Apple
    private var currentNonce: String?

    func startSignInWithApple() {
        let nonce = randomNonce()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let ctrl = ASAuthorizationController(authorizationRequests: [request])
        ctrl.delegate = self
        ctrl.presentationContextProvider = self
        ctrl.performRequests()
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AuthService: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Use the key window from the first active UIWindowScene (iOS 15+ safe)
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization auth: ASAuthorization) {
        guard
            let appleID = auth.credential as? ASAuthorizationAppleIDCredential,
            let nonce   = currentNonce,
            let token   = appleID.identityToken,
            let idToken = String(data: token, encoding: .utf8)
        else { return }

        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: idToken,
            rawNonce: nonce,
            accessToken: nil
        )

        Task { try? await Auth.auth().signIn(with: credential) }
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple sign-in failed", error)
    }
}

// MARK: - Nonce helpers
private func randomNonce(length: Int = 32) -> String {
    let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var rng = SystemRandomNumberGenerator()
    for _ in 0..<length { result.append(charset.randomElement(using: &rng)!) }
    return result
}
private func sha256(_ s: String) -> String {
    let data = Data(s.utf8)
    let hash = SHA256.hash(data: data)
    return hash.compactMap { String(format: "%02x", $0) }.joined()
}
