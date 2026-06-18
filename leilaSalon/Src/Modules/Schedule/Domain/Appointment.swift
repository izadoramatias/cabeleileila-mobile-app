//
//  Appointment.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import Foundation
import SwiftData

enum AppointmentStatus: String, Codable {
    case pendingConfirmation = "pending_confirmation"
    case confirmed = "confirmed"
    case completed = "completed"
    case cancelledByClient = "cancelled_by_client"
    case cancelledByAdmin = "cancelled_by_admin"
    case noShow = "no_show"
}

@Model
final class Appointment {
    var id: UUID
    var userId: String
    var clientName: String
    var scheduledDate: Date
    var createdAt: Date
    var confirmedAt: Date?
    var status: AppointmentStatus
    
    @Relationship(deleteRule: .nullify)
    var services: [SalonService]
    
    init(userId: String, clientName: String, scheduledDate: Date, services: [SalonService]) {
        self.id = UUID()
        self.userId = userId
        self.clientName = clientName
        self.scheduledDate = scheduledDate
        self.createdAt = Date()
        self.confirmedAt = nil
        self.status = .pendingConfirmation
        self.services = services
    }
}

extension Appointment {
    var totalPrice: Double {
        services.reduce(0) { $0 + $1.price }
    }
    
    var totalDurationMinutes: Int {
        services.reduce(0) { $0 + $1.durationMinutes }
    }
    
    var formattedTotalPrice: String {
        String(format: "R$ %.2f", totalPrice)
    }
    
    var formattedDate: String {
        scheduledDate.formatted(date: .abbreviated, time: .shortened)
    }
    
    var isEditable: Bool {
        let deadline = Calendar.current.date(byAdding: .day, value: -2, to: scheduledDate) ?? scheduledDate
        return isActive && Date() < deadline
    }
    
    var isActive: Bool {
        status == .pendingConfirmation || status == .confirmed
    }
    
    var canConfirm: Bool {
        guard status == .pendingConfirmation else { return false }
        return scheduledDate > Date()
    }
    
    var isCancelled: Bool {
        status == .cancelledByClient || status == .cancelledByAdmin
    }
}
