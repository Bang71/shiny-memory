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
    public var fetchMembers: (_ groupId: String) async throws -> [Membership]
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
        },
        fetchMembers: { groupId in
            let db = Firestore.firestore()
            let snapshot = try await db.collection("memberships")
                .whereField("groupId", isEqualTo: groupId)
                .getDocuments()

            return try snapshot.documents.compactMap { document in
                try document.data(as: Membership.self)
            }
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
