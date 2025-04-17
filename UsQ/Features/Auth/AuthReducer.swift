//
//  AuthReducer.swift
//  UsQ
//
//  Created by 신병기 on 4/16/25.
//

import Foundation
import ComposableArchitecture
import FirebaseAuth

@Reducer
public struct AuthReducer {
    public struct State: Equatable {
        public var user: User?
        public var isLoading: Bool = false
        public var errorMessage: String?
        public var didLogin: Bool = false
        public init() {}
    }

    public enum Action: Equatable {
        case signInWithGoogleTapped
        case signInResult(Result<User, SignInError>)
    }

    @Dependency(\.googleSignInClient) var googleSignInClient
    @Dependency(\.userFirestoreClient) var userFirestoreClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .signInWithGoogleTapped:
                state.isLoading = true
                return .run { send in
                    do {
                        let user = try await googleSignInClient.signIn()
                        
                        let joinedAt = Auth.auth().currentUser?.metadata.creationDate ?? Date()
                        let appUser = AppUser(
                            uid: user.uid,
                            email: user.email,
                            nickname: "", // 추후 닉네임 설정 시 업데이트
                            joinedAt: joinedAt
                        )
                        try await userFirestoreClient.createIfNeeded(appUser)
                        
                        await send(.signInResult(.success(user)))
                    } catch let error as SignInError {
                        await send(.signInResult(.failure(error)))
                    } catch {
                        await send(.signInResult(.failure(.firebase(error.localizedDescription))))
                    }
                }

            case let .signInResult(.success(user)):
                state.user = user
                state.isLoading = false
                state.errorMessage = nil
                state.didLogin = true
                return .none

            case let .signInResult(.failure(error)):
                state.isLoading = false
                state.errorMessage = "Login failed: \(error)"
                return .none
            }
        }
    }
}
