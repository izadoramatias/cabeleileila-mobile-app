//
//  RescheduleView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import SwiftUI

struct RescheduleView: View {
    @ObservedObject var viewModel: ScheduleViewModel
    @Environment(\.dismiss) private var dismiss
    
    let appointment: Appointment
    @State private var newDate: Date
    
    private var twoDaysAgo: Date {
        Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date()
    }
    
    init(viewModel: ScheduleViewModel, appointment: Appointment) {
        self.viewModel = viewModel
        self.appointment = appointment
        self._newDate = State(initialValue: appointment.scheduledDate)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Data Atual") {
                    Text(appointment.formattedDate)
                        .foregroundColor(.secondary)
                }
                
                Section("Nova Data") {
                    DatePicker(
                        "Selecione",
                        selection: $newDate,
                        in: twoDaysAgo...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .accessibilityLabel("Nova data do agendamento")
                }
            }
            .navigationTitle("Reagendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirmar") {
                        viewModel.reschedule(appointment, to: newDate)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
