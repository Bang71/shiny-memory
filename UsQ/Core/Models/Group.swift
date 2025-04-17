//
//  Group.swift
//  UsQ
//
//  Created by 신병기 on 4/17/25.
//

import Foundation

public struct Group: Codable, Identifiable, Equatable {
    public let id: String
    public let name: String
    public let type: String // "couple", "friend", "group"
    public let createdAt: Date
    public let invitationCode: String
    public let expiresAt: Date?

    public init(
        id: String,
        name: String,
        type: String,
        createdAt: Date = Date(),
        invitationCode: String,
        expiresAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.createdAt = createdAt
        self.invitationCode = invitationCode
        self.expiresAt = expiresAt
    }
}
