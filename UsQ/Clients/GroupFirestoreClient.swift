//
//  GroupFirestoreClient.swift
//  UsQ
//
//  Created by 신병기 on 4/17/25.
//
import Foundation
import ComposableArchitecture
import FirebaseFirestore

public struct GroupFirestoreClient {
    public var createGroup: (_ group: Group) async throws -> Void
    public var fetchGroupByCode: (_ code: String) async throws -> Group?
    public var refreshCodeIfNeeded: (_ group: Group) async throws -> Group
}

extension GroupFirestoreClient {
    public static let live = GroupFirestoreClient(
        createGroup: { group in
            let db = Firestore.firestore()
            try db.collection("groups").document(group.id).setData(from: group)
        },

        fetchGroupByCode: { code in
            let db = Firestore.firestore()
            let query = try await db.collection("groups")
                .whereField("invitationCode", isEqualTo: code)
                .getDocuments()

            return try query.documents.first?.data(as: Group.self)
        },

        refreshCodeIfNeeded: { group in
            let now = Date()
            if let expiresAt = group.expiresAt, now <= expiresAt {
                return group
            }

            let newCode = InvitationCodeGenerator.generateCode()
            let newExpiresAt = InvitationCodeGenerator.defaultExpiration()
            let updatedGroup = Group(
                id: group.id,
                name: group.name,
                type: group.type,
                createdAt: group.createdAt,
                invitationCode: newCode,
                expiresAt: newExpiresAt
            )

            let db = Firestore.firestore()
            try db.collection("groups").document(group.id).setData(from: updatedGroup)
            return updatedGroup
        }
    )
}

private enum GroupFirestoreClientKey: DependencyKey {
    static let liveValue = GroupFirestoreClient.live
}

extension DependencyValues {
    public var groupFirestoreClient: GroupFirestoreClient {
        get { self[GroupFirestoreClientKey.self] }
        set { self[GroupFirestoreClientKey.self] = newValue }
    }
}
