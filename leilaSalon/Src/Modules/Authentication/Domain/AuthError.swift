//
//  AuthError.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import Foundation

enum AuthError: LocalizedError {
    case invalidEmail
    case invalidPassword
    case passwordMismatch
    case sessionNotFound
    case signUpFailed(String)
    case signInFailed(String)
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Por favor, insira um e-mail válido."
        case .invalidPassword:
            return "A senha deve ter pelo menos 6 caracteres."
        case .passwordMismatch:
            return "As senhas não coincidem."
        case .sessionNotFound:
            return "Sessão não encontrada. Tente novamente."
        case .signUpFailed(let message):
            return "Falha no cadastro: \(message)"
        case .signInFailed(let message):
            return "Falha no login: \(message)"
        case .unknown(let message):
            return "Erro desconhecido: \(message)"
        }
    }
}
