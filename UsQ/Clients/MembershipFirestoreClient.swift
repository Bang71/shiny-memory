//
//  MembershipFirestoreClient.swift
//  UsQ
//
//  Created by 신병기 on 4/17/25.
//

import Foundation
import ComposableArchitecture
import FirebaseFirestore

public struct MembershipFirestoreClient {
    public var joinGroup: (_ userId: String, _ groupId: String) async throws -> Void
    public var isAlreadyJoined: (_ userId: String, _ groupId: String) async throws -> Bool
}

extension MembershipFirestoreClient {
    public static let live = MembershipFirestoreClient(
        joinGroup: { userId, groupId in
            let db = Firestore.firestore()
            let membershipId = "\(userId)_\(groupId)"
            let membership = Membership(id: membershipId, userId: userId, groupId: groupId)

            try db.collection("memberships").document(membershipId).setData(from: membership)
        },
        isAlreadyJoined: { userId, groupId in
            let db = Firestore.firestore()
            let membershipId = "\(userId)_\(groupId)"
            let doc = try await db.collection("memberships").document(membershipId).getDocument()
            return doc.exists
        }
    )
}

private enum MembershipFirestoreClientKey: DependencyKey {
    static let liveValue = MembershipFirestoreClient.live
}

extension DependencyValues {
    public var membershipFirestoreClient: MembershipFirestoreClient {
        get { self[MembershipFirestoreClientKey.self] }
        set { self[MembershipFirestoreClientKey.self] = newValue }
    }
}
