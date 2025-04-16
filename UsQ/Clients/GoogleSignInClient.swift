//
//  GoogleSignInClient.swift
//  UsQ
//
//  Created by 신병기 on 4/16/25.
//

import Foundation
import ComposableArchitecture
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

public struct GoogleSignInClient {
    public var signIn: @Sendable () async throws -> User
}

extension GoogleSignInClient {
    public static let live = GoogleSignInClient {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0 is UIWindowScene }) as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            throw SignInError.noPresentingViewController
        }

        let result = try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                do {
                    let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
                    continuation.resume(returning: result)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        guard let idToken = result.user.idToken?.tokenString else {
            throw SignInError.tokenMissing
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        let authDataResult = try await Auth.auth().signIn(with: credential)

        return User(uid: authDataResult.user.uid, email: authDataResult.user.email ?? "")
    }
}

private enum GoogleSignInClientKey: DependencyKey {
    static let liveValue = GoogleSignInClient.live
}

public enum SignInError: Error, Equatable {
    case missingClientID
    case noPresentingViewController
    case tokenMissing
    case firebase(String)
}

public struct User: Equatable {
    public let uid: String
    public let email: String
}

extension DependencyValues {
    public var googleSignInClient: GoogleSignInClient {
        get { self[GoogleSignInClientKey.self] }
        set { self[GoogleSignInClientKey.self] = newValue }
    }
}
