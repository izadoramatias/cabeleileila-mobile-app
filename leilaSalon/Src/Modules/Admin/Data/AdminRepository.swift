//
//  AdminRepository.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import Foundation
import Supabase

protocol AdminRepositoryProtocol {
    func createAdmin(email: String, password: String, fullName: String) async throws
}

final class AdminRepository: AdminRepositoryProtocol {
    private let supabase = SupabaseManager.shared.client
    
    func createAdmin(email: String, password: String, fullName: String) async throws {
        struct CreateUserPayload: Encodable {
            let email: String
            let password: String
            let full_name: String
            let role: String
        }
        
        let payload = CreateUserPayload(
            email: email,
            password: password,
            full_name: fullName,
            role: "admin"
        )
        
        try await supabase.functions.invoke(
            "create-user",
            options: .init(body: payload)
        )
    }
}
