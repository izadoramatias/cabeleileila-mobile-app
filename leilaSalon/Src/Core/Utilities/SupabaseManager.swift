//
//  SupabaseManager.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: Constants.Supabase.projectURL,
            supabaseKey: Constants.Supabase.anonKey
        )
    }
}
