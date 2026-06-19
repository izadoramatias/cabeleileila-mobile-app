//
//  AuthViewModel.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import Foundation
import Combine
import SwiftUI
import WidgetKit

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var fullName = ""
    
    @Published private(set) var authState: AuthState = .loading
    @Published private(set) var userRole: UserRole = .client
    @Published private(set) var userId: String = ""
    @Published var isShowingSignUp = false
    
    var isLoading: Bool { authState == .loading }
    var isAdmin: Bool { userRole == .admin }
    
    var errorMessage: String? {
        guard case .error(let message) = authState else { return nil }
        return message
    }
    
    private let repository: AuthRepositoryProtocol
    
    nonisolated init(repository: AuthRepositoryProtocol? = nil) {
        self.repository = repository ?? AuthRepository()
    }
    
    func signIn() async {
        guard validate(for: .signIn) else { return }
        
        await execute {
            try await self.repository.signIn(email: self.email, password: self.password)
        }
    }
    
    func signUp() async {
        guard validate(for: .signUp) else { return }
        
        authState = .loading
        
        let result = await Result {
            try await self.repository.signUp(
                email: self.email,
                password: self.password,
                fullName: self.fullName
            )
        }
        
        switch result {
        case .success(.authenticated):
            await loadUserInfo()
            authState = .authenticated
        case .success(.pendingConfirmation):
            authState = .pendingConfirmation
        case .failure(let error):
            authState = .error(error.localizedDescription)
        }
    }
    
    func signOut() async {
        let result = await Result { try await repository.signOut() }
        
        switch result {
        case .success:
            authState = .unauthenticated
            clearFields()
            
            let defaults = UserDefaults(suiteName: Constants.App.appGroupId)
            defaults?.removeObject(forKey: "userId")
            defaults?.removeObject(forKey: "userRole")
            WidgetCenter.shared.reloadAllTimelines()
        case .failure(let error):
            authState = .error(error.localizedDescription)
        }
    }
    
    func checkCurrentSession() async {
        authState = .loading
        
        let session = await repository.getCurrentSession()
        
        guard session != nil else {
            authState = .unauthenticated
            return
        }
        
        await loadUserInfo()
        authState = .authenticated
    }
    
    private func loadUserInfo() async {
        userRole = await repository.getCurrentUserRole()
        userId = await repository.getCurrentUserId() ?? ""
        
        let defaults = UserDefaults(suiteName: Constants.App.appGroupId)
        defaults?.set(userRole.rawValue, forKey: "userRole")
        defaults?.set(userId, forKey: "userId")
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func execute(_ action: @escaping () async throws -> Any?) async {
        authState = .loading
        
        let result = await Result { try await action() }
        
        switch result {
        case .success:
            await loadUserInfo()
            authState = .authenticated
        case .failure(let error):
            authState = .error(error.localizedDescription)
        }
    }
    
    private func validate(for mode: ValidationMode) -> Bool {
        let validations: [() throws -> Void] = switch mode {
        case .signIn:
            [validateEmail, validatePassword]
        case .signUp:
            [validateEmail, validatePassword, validatePasswordMatch]
        }
        
        for validation in validations {
            guard let error = Result(catching: validation).failure else { continue }
            authState = .error(error.localizedDescription)
            return false
        }
        
        return true
    }
    
    private func validateEmail() throws {
        guard !email.isEmpty, email.contains("@") else {
            throw AuthError.invalidEmail
        }
    }
    
    private func validatePassword() throws {
        guard password.count >= 6 else {
            throw AuthError.invalidPassword
        }
    }
    
    private func validatePasswordMatch() throws {
        guard password == confirmPassword else {
            throw AuthError.passwordMismatch
        }
    }
    
    private func clearFields() {
        email = ""
        password = ""
        confirmPassword = ""
        fullName = ""
    }
    
    func backToLogin() {
        authState = .unauthenticated
        clearFields()
    }
}

private extension AuthViewModel {
    enum ValidationMode {
        case signIn
        case signUp
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
    
    var failure: Failure? {
        guard case .failure(let error) = self else { return nil }
        return error
    }
}
