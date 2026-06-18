//
//  NotificationManager.swift
//  leilaSalon
//
//  Created by Izadora Lima on 18/06/26.
//

import Foundation
import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let identifier = response.notification.request.identifier
        
        guard identifier.hasPrefix("reminder-"),
              let uuidString = identifier.components(separatedBy: "reminder-").last,
              let appointmentId = UUID(uuidString: uuidString) else {
            return
        }
        
        await DeepLinkManager.shared.navigate(toAppointment: appointmentId)
    }
    
    func scheduleReminder(for appointment: Appointment) {
        let center = UNUserNotificationCenter.current()
        
        guard let triggerDate = Calendar.current.date(byAdding: .hour, value: -24, to: appointment.scheduledDate),
              triggerDate > Date() else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Lembrete - Leila Salon"
        content.body = "Seu agendamento é amanhã às \(appointment.scheduledDate.formatted(date: .omitted, time: .shortened))! Confirme sua presença no app."
        content.sound = .default
        content.categoryIdentifier = "APPOINTMENT_REMINDER"
        
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "reminder-\(appointment.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        center.add(request)
    }
    
    func cancelReminder(for appointment: Appointment) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(
            withIdentifiers: ["reminder-\(appointment.id.uuidString)"]
        )
    }
    
    func rescheduleReminder(for appointment: Appointment) {
        cancelReminder(for: appointment)
        scheduleReminder(for: appointment)
    }
}
