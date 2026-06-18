//
//  ScheduleViewModel.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import Foundation
import Combine
import SwiftData

@MainActor
class ScheduleViewModel: ObservableObject {
    
    @Published var appointments: [Appointment] = []
    @Published var services: [SalonService] = []
    @Published private(set) var errorMessage: String?
    @Published private(set) var suggestedDate: Date?
    
    private let repository: ScheduleRepositoryProtocol
    private let userId: String
    let isAdmin: Bool
    
    init(repository: ScheduleRepositoryProtocol, userId: String, isAdmin: Bool = false) {
        self.repository = repository
        self.userId = userId
        self.isAdmin = isAdmin
    }
    
    func loadData() {
        repository.seedServicesIfNeeded()
        services = repository.fetchServices()
        reloadAppointments()
    }
    
    func createAppointment(clientName: String, date: Date, selectedServices: [SalonService]) {
        guard !clientName.isEmpty else {
            errorMessage = "Informe o nome da cliente."
            return
        }
        guard !selectedServices.isEmpty else {
            errorMessage = "Selecione pelo menos um serviço."
            return
        }
        
        errorMessage = nil
        let appointment = Appointment(userId: userId, clientName: clientName, scheduledDate: date, services: selectedServices)
        repository.createAppointment(appointment)
        reloadAppointments()
    }
    
    func confirmAppointment(_ appointment: Appointment) {
        guard appointment.canConfirm else {
            errorMessage = "Não é possível confirmar este agendamento."
            return
        }
        
        errorMessage = nil
        repository.confirm(appointment)
        reloadAppointments()
    }
    
    func reschedule(_ appointment: Appointment, to newDate: Date) {
        guard isAdmin || appointment.isEditable else {
            errorMessage = "Este agendamento não pode ser alterado."
            return
        }
        
        errorMessage = nil
        repository.reschedule(appointment, to: newDate)
        reloadAppointments()
    }
    
    func cancel(_ appointment: Appointment) {
        errorMessage = nil
        repository.cancel(appointment, byAdmin: isAdmin)
        reloadAppointments()
    }
    
    func markAsCompleted(_ appointment: Appointment) {
        errorMessage = nil
        repository.markAsCompleted(appointment)
        reloadAppointments()
    }
    
    func markAsNoShow(_ appointment: Appointment) {
        errorMessage = nil
        repository.markAsNoShow(appointment)
        reloadAppointments()
    }
    
    func checkWeekSuggestion(for date: Date) {
        let calendar = Calendar.current
        
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: date)?.start,
              let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) else {
            suggestedDate = nil
            return
        }
        
        let sameWeekAppointments = repository.fetchAppointments(from: weekStart, to: weekEnd, userId: userId)
            .filter { $0.isActive }
            .filter { !calendar.isDate($0.scheduledDate, inSameDayAs: date) }
        
        suggestedDate = sameWeekAppointments.first?.scheduledDate
    }
    
    func clearSuggestion() {
        suggestedDate = nil
    }
    
    private func reloadAppointments() {
        appointments = isAdmin
            ? repository.fetchAllAppointments()
            : repository.fetchAppointments(forUser: userId)
    }
}
