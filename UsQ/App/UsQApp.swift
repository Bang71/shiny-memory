//
//  UsQApp.swift
//  UsQ
//
//  Created by 신병기 on 4/15/25.
//

import SwiftUI
import ComposableArchitecture
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct UsQApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            AuthView(
                store: Store(
                    initialState: AuthReducer.State(),
                    reducer: {
                        AuthReducer()
                            .dependency(\.googleSignInClient, .live)
                    }
                )
            )
        }
    }
}
