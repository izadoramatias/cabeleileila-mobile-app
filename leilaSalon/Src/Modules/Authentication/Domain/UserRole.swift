//
//  UserRole.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import Foundation

enum UserRole: String, Equatable {
    case admin
    case professional
    case client
    
    static func from(_ value: String?) -> UserRole {
        guard let value else { return .client }
        return UserRole(rawValue: value) ?? .client
    }
}
