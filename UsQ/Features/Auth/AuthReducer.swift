//
//  AuthReducer.swift
//  UsQ
//
//  Created by 신병기 on 4/16/25.
//

import ComposableArchitecture

public struct AuthReducer: Reducer {
    public struct State: Equatable {
        public var user: User?
        public var isLoading: Bool = false
        public var errorMessage: String?
        public init() {}
    }

    public enum Action: Equatable {
        case signInWithGoogleTapped
        case signInResult(Result<User, SignInError>)
    }

    @Dependency(\.googleSignInClient) var googleSignInClient

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .signInWithGoogleTapped:
                state.isLoading = true
                return .run { send in
                    do {
                        let user = try await googleSignInClient.signIn()
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
                return .none

            case let .signInResult(.failure(error)):
                state.isLoading = false
                state.errorMessage = "Login failed: \(error)"
                return .none
            }
        }
    }
}
