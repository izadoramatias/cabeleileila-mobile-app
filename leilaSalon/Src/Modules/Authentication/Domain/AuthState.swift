//
//  AuthState.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import Foundation

enum AuthState: Equatable {
    case idle
    case loading
    case authenticated
    case pendingConfirmation
    case unauthenticated
    case error(String)
}
