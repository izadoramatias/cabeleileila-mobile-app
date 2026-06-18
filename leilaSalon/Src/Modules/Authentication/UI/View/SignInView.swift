//
//  SignInView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import SwiftUI

struct SignInView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            headerSection
            Spacer()
            formSection
            signUpLink
            Spacer()
        }
        .padding()
        .onTapGesture { hideKeyboard() }
    }
}

private extension SignInView {
    
    var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "scissors")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Leila Salon")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Bem-vinda de volta!")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    var formSection: some View {
        VStack(spacing: 16) {
            TextField("E-mail", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .autocorrectionDisabled()
                .accessibilityLabel("Campo de e-mail")
            
            PasswordField(placeholder: "Senha", text: $viewModel.password)
                .accessibilityLabel("Campo de senha")
            
            ErrorMessageView(message: viewModel.errorMessage)
            
            LoadingButton(title: "Entrar", isLoading: viewModel.isLoading) {
                Task { await viewModel.signIn() }
            }
            .accessibilityLabel("Botão entrar")
        }
        .padding(.horizontal)
    }
    
    var signUpLink: some View {
        Button {
            viewModel.isShowingSignUp = true
        } label: {
            HStack {
                Text("Não tem conta?")
                    .foregroundColor(.secondary)
                Text("Cadastre-se")
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
            }
            .font(.subheadline)
        }
        .accessibilityLabel("Ir para cadastro")
    }
}

#Preview {
    SignInView(viewModel: AuthViewModel())
}
