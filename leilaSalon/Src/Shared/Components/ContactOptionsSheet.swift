//
//  ContactOptionsSheet.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import SwiftUI

struct ContactOptionsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                headerSection
                warningSection
                buttonsSection
                Spacer()
            }
            .padding()
            .navigationTitle("Entrar em Contato")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

private extension ContactOptionsSheet {
    
    var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "phone.bubble")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
            
            Text("Como deseja entrar em contato?")
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }
    
    var warningSection: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.caption)
            
            Text("Você será redirecionada para fora do aplicativo.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.orange.opacity(0.08))
        .cornerRadius(8)
    }
    
    var buttonsSection: some View {
        VStack(spacing: 12) {
            Button {
                openWhatsApp()
            } label: {
                Label("WhatsApp", systemImage: "message.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .accessibilityLabel("Abrir WhatsApp")
            
            Button {
                openPhone()
            } label: {
                Label("Ligar", systemImage: "phone.fill")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .accessibilityLabel("Fazer ligação telefônica")
        }
    }
    
    private func openWhatsApp() {
        let phone = Constants.Contact.phone
        let message = Constants.Contact.whatsappMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: "https://wa.me/55\(phone)?text=\(message)") else { return }
        openURL(url)
        dismiss()
    }
    
    private func openPhone() {
        guard let url = URL(string: "tel://\(Constants.Contact.phone)") else { return }
        openURL(url)
        dismiss()
    }
}

#Preview {
    ContactOptionsSheet()
}
