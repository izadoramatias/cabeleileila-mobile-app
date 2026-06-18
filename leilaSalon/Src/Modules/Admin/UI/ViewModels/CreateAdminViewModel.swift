//
//  CreateAdminViewModel.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import Foundation
import Combine

enum CreateAdminState: Equatable {
    case idle
    case loading
    case success
    case error(String)
}

@MainActor
class CreateAdminViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var fullName = ""
    
    @Published private(set) var state: CreateAdminState = .idle
    
    var isLoading: Bool { state == .loading }
    
    var errorMessage: String? {
        guard case .error(let message) = state else { return nil }
        return message
    }
    
    private let repository: AdminRepositoryProtocol
    
    nonisolated init(repository: AdminRepositoryProtocol? = nil) {
        self.repository = repository ?? AdminRepository()
    }
    
    func createAdmin() async {
        guard validate() else { return }
        
        state = .loading
        
        let result = await Result { try await repository.createAdmin(
            email: email,
            password: password,
            fullName: fullName
        )}
        
        switch result {
        case .success:
            state = .success
            clearFields()
        case .failure(let error):
            state = .error(error.localizedDescription)
        }
    }
    
    func reset() {
        state = .idle
    }
    
    private func validate() -> Bool {
        guard !fullName.isEmpty else {
            state = .error("Informe o nome completo.")
            return false
        }
        guard !email.isEmpty, email.contains("@") else {
            state = .error("Informe um e-mail válido.")
            return false
        }
        guard password.count >= 6 else {
            state = .error("A senha deve ter pelo menos 6 caracteres.")
            return false
        }
        return true
    }
    
    private func clearFields() {
        email = ""
        password = ""
        fullName = ""
    }
}

private extension Result where Failure == Error {
    init(_ asyncWork: () async throws -> Success) async {
        do {
            let value = try await asyncWork()
            self = .success(value)
        } catch {
            self = .failure(error)
        }
    }
}
