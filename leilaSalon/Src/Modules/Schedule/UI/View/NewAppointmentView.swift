//
//  NewAppointmentView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import SwiftUI

struct NewAppointmentView: View {
    @ObservedObject var viewModel: ScheduleViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var clientName = ""
    @State private var selectedDate = Date()
    @State private var selectedServices: Set<SalonService> = []
    
    var body: some View {
        NavigationStack {
            Form {
                clientSection
                dateSection
                suggestionSection
                servicesSection
                summarySection
                errorSection
            }
            .navigationTitle("Novo Agendamento")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { save() }
                        .fontWeight(.semibold)
                }
            }
            .onChange(of: selectedDate) { _ in
                viewModel.checkWeekSuggestion(for: selectedDate)
            }
            .onDisappear { viewModel.clearSuggestion() }
        }
    }
    
    private func save() {
        viewModel.createAppointment(
            clientName: clientName,
            date: selectedDate,
            selectedServices: Array(selectedServices)
        )
        
        guard viewModel.errorMessage == nil else { return }
        dismiss()
    }
}

private extension NewAppointmentView {
    
    var clientSection: some View {
        Section("Cliente") {
            TextField("Nome da cliente", text: $clientName)
                .textContentType(.name)
                .accessibilityLabel("Nome da cliente")
        }
    }
    
    var dateSection: some View {
        Section("Data e Horário") {
            DatePicker(
                "Quando",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .accessibilityLabel("Data do agendamento")
        }
    }
    
    @ViewBuilder
    var suggestionSection: some View {
        if let suggestedDate = viewModel.suggestedDate {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("Sugestão")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    
                    Text("Você já tem um agendamento nessa semana em \(suggestedDate.formatted(date: .abbreviated, time: .omitted)). Que tal marcar no mesmo dia?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Button {
                        selectedDate = suggestedDate
                        viewModel.clearSuggestion()
                    } label: {
                        Label("Usar \(suggestedDate.formatted(date: .abbreviated, time: .omitted))", systemImage: "calendar.badge.checkmark")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    var servicesSection: some View {
        Section("Serviços") {
            ForEach(viewModel.services) { service in
                ServiceRow(
                    service: service,
                    isSelected: selectedServices.contains(service)
                ) {
                    toggleService(service)
                }
            }
        }
    }
    
    @ViewBuilder
    var summarySection: some View {
        if !selectedServices.isEmpty {
            Section("Resumo") {
                HStack {
                    Text("Serviços")
                    Spacer()
                    Text("\(selectedServices.count)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Duração total")
                    Spacer()
                    Text("\(totalDuration) min")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Total")
                    Spacer()
                    Text(formattedTotal)
                        .fontWeight(.semibold)
                }
            }
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
    
    private var totalDuration: Int {
        selectedServices.reduce(0) { $0 + $1.durationMinutes }
    }
    
    private var formattedTotal: String {
        let total = selectedServices.reduce(0.0) { $0 + $1.price }
        return String(format: "R$ %.2f", total)
    }
    
    private func toggleService(_ service: SalonService) {
        if selectedServices.contains(service) {
            selectedServices.remove(service)
        } else {
            selectedServices.insert(service)
        }
    }
}

private struct ServiceRow: View {
    let service: SalonService
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(service.name)
                        .foregroundColor(.primary)
                    Text("\(service.formattedDuration) • \(service.formattedPrice)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
        }
        .accessibilityLabel("\(service.name), \(isSelected ? "selecionado" : "não selecionado")")
    }
}
