//
//  AdminError.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import Foundation

enum AdminError: LocalizedError {
    case creationFailed(String)
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .creationFailed(let message):
            return "Falha ao criar usuário: \(message)"
        case .unauthorized:
            return "Você não tem permissão para esta ação."
        }
    }
}
