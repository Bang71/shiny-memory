//
//  Membership.swift
//  UsQ
//
//  Created by 신병기 on 4/17/25.
//

import Foundation

public struct Membership: Codable, Identifiable, Equatable {
    public let id: String
    public let userId: String
    public let groupId: String
    public let joinedAt: Date

    public init(
        id: String,
        userId: String,
        groupId: String,
        joinedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.groupId = groupId
        self.joinedAt = joinedAt
    }
}
