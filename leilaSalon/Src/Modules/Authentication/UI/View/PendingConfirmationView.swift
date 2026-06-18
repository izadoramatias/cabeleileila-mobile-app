//
//  PendingConfirmationView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import SwiftUI

struct PendingConfirmationView: View {
    @ObservedObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "envelope.badge")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
            
            Text("Verifique seu e-mail")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Enviamos um link de confirmação para o seu e-mail. Após confirmar, volte aqui e toque no botão abaixo.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            LoadingButton(title: "Já confirmei", isLoading: authViewModel.isLoading) {
                Task { await authViewModel.checkCurrentSession() }
            }
            .padding(.horizontal)
            
            Button("Voltar ao login") {
                authViewModel.backToLogin()
            }
            .font(.subheadline)
            .foregroundColor(.accentColor)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    PendingConfirmationView(authViewModel: AuthViewModel())
}
