//
//  InvitationCodeGenerator.swift
//  UsQ
//
//  Created by 신병기 on 4/17/25.
//

import Foundation

public struct InvitationCodeGenerator {
    public static func generateCode(length: Int = 6) -> String {
        let characters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<length).compactMap { _ in characters.randomElement() })
    }

    public static func defaultExpiration(hours: Int = 24) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: Date())!
    }
}
