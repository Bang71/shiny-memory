//
//  AuthView.swift
//  UsQ
//
//  Created by 신병기 on 4/16/25.
//

import SwiftUI
import ComposableArchitecture

public struct AuthView: View {
    let store: StoreOf<AuthReducer>

    public init(store: StoreOf<AuthReducer>) {
        self.store = store
    }

    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 24) {
                Spacer()

                Text("Welcome to UsQ")
                    .font(.largeTitle)
                    .bold()

                Button(action: {
                    viewStore.send(.signInWithGoogleTapped)
                }) {
                    Text("Sign in with Google")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                if viewStore.isLoading {
                    ProgressView()
                }

                if let error = viewStore.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
        }
    }
}
