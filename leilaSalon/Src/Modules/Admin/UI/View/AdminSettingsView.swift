//
//  AdminSettingsView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import SwiftUI

struct AdminSettingsView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var isShowingCreateAdmin = false
    @State private var isShowingAnalytics = false
    @State private var isSigningOut = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("Relatórios") {
                    Button {
                        isShowingAnalytics = true
                    } label: {
                        Label("Resumo e Análises", systemImage: "chart.bar")
                    }
                    .accessibilityLabel("Ver resumo semanal e análises")
                }
                
                Section("Usuários") {
                    Button {
                        isShowingCreateAdmin = true
                    } label: {
                        Label("Criar novo administrador", systemImage: "person.badge.plus")
                    }
                    .accessibilityLabel("Criar novo administrador")
                }
                
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
            .navigationTitle("Configurações")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                        .disabled(isSigningOut)
                }
            }
            .sheet(isPresented: $isShowingCreateAdmin) {
                CreateAdminView()
            }
            .sheet(isPresented: $isShowingAnalytics) {
                AnalyticsView()
            }
        }
    }
}

#Preview {
    AdminSettingsView(authViewModel: AuthViewModel())
}
