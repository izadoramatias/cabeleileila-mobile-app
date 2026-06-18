//
//  ScheduleRepository.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import Foundation
import SwiftData
import WidgetKit

protocol ScheduleRepositoryProtocol {
    func fetchAppointments(from startDate: Date, to endDate: Date) -> [Appointment]
    func fetchAppointments(from startDate: Date, to endDate: Date, userId: String) -> [Appointment]
    func fetchAllAppointments() -> [Appointment]
    func fetchAppointments(forUser userId: String) -> [Appointment]
    func createAppointment(_ appointment: Appointment)
    func confirm(_ appointment: Appointment)
    func reschedule(_ appointment: Appointment, to newDate: Date)
    func cancel(_ appointment: Appointment, byAdmin: Bool)
    func markAsCompleted(_ appointment: Appointment)
    func markAsNoShow(_ appointment: Appointment)
    func seedServicesIfNeeded()
    func fetchServices() -> [SalonService]
}

@MainActor
final class ScheduleRepository: ScheduleRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func fetchAppointments(from startDate: Date, to endDate: Date) -> [Appointment] {
        let predicate = #Predicate<Appointment> { appointment in
            appointment.scheduledDate >= startDate && appointment.scheduledDate <= endDate
        }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.scheduledDate, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func fetchAppointments(from startDate: Date, to endDate: Date, userId: String) -> [Appointment] {
        let predicate = #Predicate<Appointment> { appointment in
            appointment.scheduledDate >= startDate &&
            appointment.scheduledDate <= endDate &&
            appointment.userId == userId
        }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.scheduledDate, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func fetchAllAppointments() -> [Appointment] {
        let descriptor = FetchDescriptor<Appointment>(sortBy: [SortDescriptor(\.scheduledDate, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func fetchAppointments(forUser userId: String) -> [Appointment] {
        let predicate = #Predicate<Appointment> { $0.userId == userId }
        let descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.scheduledDate, order: .reverse)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func createAppointment(_ appointment: Appointment) {
        modelContext.insert(appointment)
        save()
        NotificationManager.shared.scheduleReminder(for: appointment)
    }
    
    func confirm(_ appointment: Appointment) {
        appointment.status = .confirmed
        appointment.confirmedAt = Date()
        save()
    }
    
    func reschedule(_ appointment: Appointment, to newDate: Date) {
        appointment.scheduledDate = newDate
        appointment.status = .pendingConfirmation
        appointment.confirmedAt = nil
        save()
        NotificationManager.shared.rescheduleReminder(for: appointment)
    }
    
    func cancel(_ appointment: Appointment, byAdmin: Bool) {
        appointment.status = byAdmin ? .cancelledByAdmin : .cancelledByClient
        save()
        NotificationManager.shared.cancelReminder(for: appointment)
    }
    
    func markAsCompleted(_ appointment: Appointment) {
        appointment.status = .completed
        save()
    }
    
    func markAsNoShow(_ appointment: Appointment) {
        appointment.status = .noShow
        save()
    }
    
    func fetchServices() -> [SalonService] {
        let descriptor = FetchDescriptor<SalonService>(sortBy: [SortDescriptor(\.name)])
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func seedServicesIfNeeded() {
        let existing = fetchServices()
        guard existing.isEmpty else { return }
        
        SalonService.samples.forEach { modelContext.insert($0) }
        save()
    }
    
    private func save() {
        try? modelContext.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}
