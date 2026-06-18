//
//  AppointmentDetailView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import SwiftUI

struct AppointmentDetailView: View {
    @ObservedObject var viewModel: ScheduleViewModel
    @Environment(\.dismiss) private var dismiss
    
    let appointment: Appointment
    @State private var isShowingReschedule = false
    @State private var isShowingContact = false
    
    var body: some View {
        List {
            infoSection
            servicesSection
            confirmationSection
            adminActionsSection
            editableActionsSection
            expiredSection
        }
        .navigationTitle("Detalhes")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingReschedule) {
            RescheduleView(viewModel: viewModel, appointment: appointment)
        }
        .sheet(isPresented: $isShowingContact) {
            ContactOptionsSheet()
        }
    }
}

private extension AppointmentDetailView {
    
    var infoSection: some View {
        Section("Informações") {
            row("Cliente", value: appointment.clientName)
            row("Data", value: appointment.formattedDate)
            row("Status", value: statusLabel)
            row("Duração", value: "\(appointment.totalDurationMinutes) min")
            row("Total", value: appointment.formattedTotalPrice)
            
            if let confirmedAt = appointment.confirmedAt {
                row("Confirmado em", value: confirmedAt.formatted(date: .abbreviated, time: .shortened))
            }
        }
    }
    
    var servicesSection: some View {
        Section("Serviços") {
            ForEach(appointment.services) { service in
                HStack {
                    Text(service.name)
                    Spacer()
                    Text(service.formattedPrice)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    var confirmationSection: some View {
        if !viewModel.isAdmin && appointment.canConfirm {
            Section {
                Button {
                    viewModel.confirmAppointment(appointment)
                } label: {
                    Label("Confirmar Presença", systemImage: "checkmark.seal")
                        .foregroundColor(.green)
                }
                .accessibilityLabel("Confirmar presença no agendamento")
            } footer: {
                Text("Confirme sua presença para garantir seu horário.")
                    .font(.caption)
            }
        }
    }
    
    @ViewBuilder
    var adminActionsSection: some View {
        if viewModel.isAdmin && appointment.isActive {
            Section("Ações do Admin") {
                Button {
                    isShowingReschedule = true
                } label: {
                    Label("Reagendar", systemImage: "calendar.badge.clock")
                }
                
                if appointment.status == .confirmed {
                    Button {
                        viewModel.markAsCompleted(appointment)
                        dismiss()
                    } label: {
                        Label("Marcar como Concluído", systemImage: "checkmark.circle")
                            .foregroundColor(.green)
                    }
                    
                    Button {
                        viewModel.markAsNoShow(appointment)
                        dismiss()
                    } label: {
                        Label("Não Compareceu", systemImage: "person.slash")
                            .foregroundColor(.orange)
                    }
                }
                
                Button(role: .destructive) {
                    viewModel.cancel(appointment)
                    dismiss()
                } label: {
                    Label("Cancelar Agendamento", systemImage: "xmark.circle")
                }
            }
        }
    }
    
    @ViewBuilder
    var editableActionsSection: some View {
        if !viewModel.isAdmin && appointment.isEditable {
            Section {
                Button {
                    isShowingReschedule = true
                } label: {
                    Label("Reagendar", systemImage: "calendar.badge.clock")
                }
                .accessibilityLabel("Reagendar este agendamento")
                
                Button(role: .destructive) {
                    viewModel.cancel(appointment)
                    dismiss()
                } label: {
                    Label("Cancelar Agendamento", systemImage: "xmark.circle")
                }
                .accessibilityLabel("Cancelar este agendamento")
            }
        }
    }
    
    @ViewBuilder
    var expiredSection: some View {
        if !viewModel.isAdmin && !appointment.isEditable && appointment.isActive {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    Text("O período para alterações online expirou. Entre em contato conosco se precisar reagendar.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button {
                        isShowingContact = true
                    } label: {
                        Label("Entrar em contato", systemImage: "phone.arrow.up.right")
                    }
                    .accessibilityLabel("Entrar em contato para reagendar")
                }
            }
        }
    }
    
    private var statusLabel: String {
        switch appointment.status {
        case .pendingConfirmation: "Pendente de Confirmação"
        case .confirmed: "Confirmado"
        case .completed: "Concluído"
        case .cancelledByClient: "Cancelado pelo Cliente"
        case .cancelledByAdmin: "Cancelado pelo Salão"
        case .noShow: "Não Compareceu"
        }
    }
    
    private func row(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}
