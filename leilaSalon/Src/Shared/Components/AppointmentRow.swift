//
//  AppointmentRow.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import SwiftUI

struct AppointmentRow: View {
    let appointment: Appointment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(appointment.clientName)
                    .fontWeight(.medium)
                Spacer()
                statusBadge
            }
            
            Text(appointment.formattedDate)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(serviceNames)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(appointment.clientName), \(appointment.formattedDate)")
    }
    
    private var serviceNames: String {
        appointment.services.map(\.name).joined(separator: ", ")
    }
    
    private var statusBadge: some View {
        Text(statusText)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(statusColor.opacity(0.12))
            .clipShape(Capsule())
    }
    
    private var statusText: String {
        switch appointment.status {
        case .pendingConfirmation: "Pendente"
        case .confirmed: "Confirmado"
        case .completed: "Concluído"
        case .cancelledByClient: "Cancelado"
        case .cancelledByAdmin: "Cancelado (salão)"
        case .noShow: "Não compareceu"
        }
    }
    
    private var statusColor: Color {
        switch appointment.status {
        case .pendingConfirmation: .orange
        case .confirmed: .blue
        case .completed: .green
        case .cancelledByClient, .cancelledByAdmin: .red
        case .noShow: .gray
        }
    }
}
