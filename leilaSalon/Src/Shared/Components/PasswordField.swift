//
//  PasswordField.swift
//  leilaSalon
//
//  Created by Izadora Lima on 18/06/26.
//

import SwiftUI

struct PasswordField: View {
    let placeholder: String
    @Binding var text: String
    var showRequirements: Bool = false
    
    @State private var isVisible = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Group {
                    if isVisible {
                        TextField(placeholder, text: $text)
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .autocapitalization(.none)
                .autocorrectionDisabled()
                
                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isVisible ? "Ocultar senha" : "Mostrar senha")
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(.systemGray4), lineWidth: 0.5)
            )
            
            if showRequirements {
                requirementsView
            }
        }
    }
    
    private var requirementsView: some View {
        VStack(alignment: .leading, spacing: 4) {
            requirementRow("Mínimo de 6 caracteres", met: text.count >= 6)
        }
        .padding(.leading, 4)
    }
    
    private func requirementRow(_ label: String, met: Bool) -> some View {
        HStack(spacing: 4) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.caption2)
                .foregroundColor(met ? .green : .secondary)
            Text(label)
                .font(.caption)
                .foregroundColor(met ? .green : .secondary)
        }
        .accessibilityLabel("\(label): \(met ? "cumprido" : "pendente")")
    }
}
