//
//  AuthRepository.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import Foundation
import Supabase

final class AuthRepository: AuthRepositoryProtocol {
    private let supabase = SupabaseManager.shared.client
    
    func signIn(email: String, password: String) async throws -> Session {
        try await supabase.auth.signIn(email: email, password: password)
    }
    
    func signUp(email: String, password: String, fullName: String) async throws -> SignUpResult {
        let response = try await supabase.auth.signUp(
            email: email,
            password: password,
            data: ["full_name": .string(fullName)]
        )
        
        guard let session = response.session else {
            return .pendingConfirmation
        }
        
        return .authenticated(session)
    }
    
    func signOut() async throws {
        try await supabase.auth.signOut()
    }
    
    func getCurrentSession() async -> Session? {
        guard let session = try? await supabase.auth.session else {
            return nil
        }
        
        guard let refreshed = try? await supabase.auth.refreshSession() else {
            try? await supabase.auth.signOut(scope: .local)
            return nil
        }
        
        return refreshed
    }
    
    func refreshSession() async throws -> Session {
        try await supabase.auth.refreshSession()
    }
    
    func getCurrentUserRole() async -> UserRole {
        guard let session = try? await supabase.auth.session else {
            return .client
        }
        
        guard let roleJSON = session.user.appMetadata["role"] else {
            return .client
        }
        
        switch roleJSON {
        case .string(let value):
            return UserRole.from(value)
        default:
            return .client
        }
    }
    
    func getCurrentUserId() async -> String? {
        guard let session = try? await supabase.auth.session else {
            return nil
        }
        return session.user.id.uuidString
    }
}
