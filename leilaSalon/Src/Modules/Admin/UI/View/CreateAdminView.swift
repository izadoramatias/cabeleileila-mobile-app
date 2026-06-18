//
//  CreateAdminView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import SwiftUI

struct CreateAdminView: View {
    @StateObject private var viewModel = CreateAdminViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                formFields
                errorSection
                submitButton
            }
            .navigationTitle("Novo Administrador")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
            }
            .alert("Administrador criado!", isPresented: showSuccessAlert) {
                Button("OK") { dismiss() }
            } message: {
                Text("O novo administrador já pode fazer login.")
            }
        }
    }
    
    private var showSuccessAlert: Binding<Bool> {
        Binding(
            get: { viewModel.state == .success },
            set: { if !$0 { viewModel.reset() } }
        )
    }
}

private extension CreateAdminView {
    
    var formFields: some View {
        Section("Dados do novo administrador") {
            TextField("Nome completo", text: $viewModel.fullName)
                .textContentType(.name)
                .accessibilityLabel("Campo de nome completo")
            
            TextField("E-mail", text: $viewModel.email)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .accessibilityLabel("Campo de e-mail")
            
            SecureField("Senha", text: $viewModel.password)
                .textContentType(.newPassword)
                .accessibilityLabel("Campo de senha")
        }
    }
    
    @ViewBuilder
    var errorSection: some View {
        if let message = viewModel.errorMessage {
            Section {
                Text(message)
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
    
    var submitButton: some View {
        Section {
            LoadingButton(title: "Criar Administrador", isLoading: viewModel.isLoading) {
                Task { await viewModel.createAdmin() }
            }
            .accessibilityLabel("Botão criar administrador")
        }
    }
}

#Preview {
    CreateAdminView()
}
