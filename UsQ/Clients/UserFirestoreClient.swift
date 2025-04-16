//
//  UserFirestoreClient.swift
//  UsQ
//
//  Created by 신병기 on 4/16/25.
//

import Foundation
import ComposableArchitecture
import FirebaseFirestore

public struct UserFirestoreClient {
    public var createIfNeeded: (_ user: AppUser) async throws -> Void
}

extension UserFirestoreClient {
    public static let live = UserFirestoreClient { user in
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(user.uid)

        let snapshot = try await docRef.getDocument()

        if snapshot.exists {
            return // 이미 존재하므로 아무것도 하지 않음
        } else {
            try docRef.setData(from: user)
        }
    }
}

private enum UserFirestoreClientKey: DependencyKey {
    static let liveValue = UserFirestoreClient.live
}

extension DependencyValues {
    public var userFirestoreClient: UserFirestoreClient {
        get { self[UserFirestoreClientKey.self] }
        set { self[UserFirestoreClientKey.self] = newValue }
    }
}
