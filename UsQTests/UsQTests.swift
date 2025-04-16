//
//  UsQTests.swift
//  UsQTests
//
//  Created by 신병기 on 4/15/25.
//

import Testing
import ComposableArchitecture
@testable import UsQ

struct UsQTests {
    
    @Test func testSignInSuccess() async throws {
        let mockUser = User(uid: "123", email: "test@example.com")
        let store = await TestStore(initialState: AuthReducer.State()) {
            AuthReducer()
        } withDependencies: {
            $0.googleSignInClient.signIn = {
                mockUser
            }
        }
        
        await store.send(.signInWithGoogleTapped) {
            $0.isLoading = true
        }
        
        await store.receive(.signInResult(.success(mockUser))) {
            $0.isLoading = false
            $0.user = mockUser
            $0.errorMessage = nil
        }
    }
    
    @Test func testSignInFailure() async throws {
        let store = await TestStore(initialState: AuthReducer.State()) {
            AuthReducer()
        } withDependencies: {
            $0.googleSignInClient.signIn = {
                throw SignInError.tokenMissing
            }
        }
        
        await store.send(.signInWithGoogleTapped) {
            $0.isLoading = true
        }
        
        await store.receive(.signInResult(.failure(.tokenMissing))) {
            $0.isLoading = false
            $0.errorMessage = "Login failed: tokenMissing"
        }
    }
}
