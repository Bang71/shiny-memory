//
//  AppUser.swift
//  UsQ
//
//  Created by 신병기 on 4/16/25.
//

import Foundation

public struct AppUser: Codable, Equatable {
    public let uid: String
    public let email: String
    public let nickname: String
    public let joinedAt: Date

    public init(uid: String, email: String, nickname: String = "", joinedAt: Date = Date()) {
        self.uid = uid
        self.email = email
        self.nickname = nickname
        self.joinedAt = joinedAt
    }
}
