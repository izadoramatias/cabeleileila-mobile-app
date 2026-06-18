//
//  AuthRepositoryProtocol.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import Foundation
import Supabase

enum SignUpResult {
    case authenticated(Session)
    case pendingConfirmation
}

protocol AuthRepositoryProtocol {
    func signIn(email: String, password: String) async throws -> Session
    func signUp(email: String, password: String, fullName: String) async throws -> SignUpResult
    func signOut() async throws
    func getCurrentSession() async -> Session?
    func refreshSession() async throws -> Session
    func getCurrentUserRole() async -> UserRole
    func getCurrentUserId() async -> String?
}
