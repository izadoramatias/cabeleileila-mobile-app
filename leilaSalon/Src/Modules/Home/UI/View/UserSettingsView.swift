//
//  UserSettingsView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import SwiftUI

struct UserSettingsView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isSigningOut = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(role: .destructive) {
                        isSigningOut = true
                        Task {
                            await authViewModel.signOut()
                            dismiss()
                        }
                    } label: {
                        HStack {
                            Label("Sair da conta", systemImage: "rectangle.portrait.and.arrow.right")
                            Spacer()
                            if isSigningOut {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isSigningOut)
                    .accessibilityLabel("Sair da conta")
                }
            }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                        .disabled(isSigningOut)
                }
            }
        }
    }
}

#Preview {
    UserSettingsView(authViewModel: AuthViewModel())
}
