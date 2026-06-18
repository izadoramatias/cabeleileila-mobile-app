//
//  SignUpView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import SwiftUI

struct SignUpView: View {
    @ObservedObject var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                headerSection
                Spacer()
                formSection
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Voltar") { dismiss() }
                        .accessibilityLabel("Voltar para login")
                }
            }
            .onTapGesture { hideKeyboard() }
        }
    }
}

private extension SignUpView {
    
    var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.accentColor)
            
            Text("Criar Conta")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Preencha os dados abaixo")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    var formSection: some View {
        VStack(spacing: 16) {
            TextField("Nome completo", text: $viewModel.fullName)
                .textFieldStyle(.roundedBorder)
                .textContentType(.name)
                .accessibilityLabel("Campo de nome completo")
            
            TextField("E-mail", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .accessibilityLabel("Campo de e-mail")
            
            PasswordField(placeholder: "Senha", text: $viewModel.password, showRequirements: true)
                .accessibilityLabel("Campo de senha")
            
            PasswordField(placeholder: "Confirmar senha", text: $viewModel.confirmPassword)
                .accessibilityLabel("Campo de confirmação de senha")
            
            ErrorMessageView(message: viewModel.errorMessage)
            
            LoadingButton(title: "Cadastrar", isLoading: viewModel.isLoading) {
                Task { await viewModel.signUp() }
            }
            .accessibilityLabel("Botão cadastrar")
        }
        .padding(.horizontal)
    }
}

#Preview {
    SignUpView(viewModel: AuthViewModel())
}
