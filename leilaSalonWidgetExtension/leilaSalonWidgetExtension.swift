//
//  leilaSalonWidgetExtension.swift
//  leilaSalonWidgetExtension
//
//  Created by Izadora Lima on 18/06/26.
//

import WidgetKit
import SwiftUI
import SwiftData

private enum Config {
    static let appGroup = "group.app.leilaSalonWidgetExtension"
    static let confirmURL = "leilasalon://confirm-appointment/"
}

struct ClientWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ClientWidget", provider: ClientProvider()) { entry in
            ClientView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Próximo Agendamento")
        .description("Contagem regressiva e status do seu próximo horário.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

private struct ClientProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClientEntry { .empty }
    
    func getSnapshot(in context: Context, completion: @escaping (ClientEntry) -> Void) {
        completion(ClientEntry(date: .now, appointment: nextAppointment()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ClientEntry>) -> Void) {
        let entry = ClientEntry(date: .now, appointment: nextAppointment())
        let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
    
    private func nextAppointment() -> AppointmentSnapshot? {
        guard let container = sharedContainer() else { return nil }
        
        let context = ModelContext(container)
        let now = Date()
        let predicate = #Predicate<Appointment> { $0.scheduledDate > now }
        var descriptor = FetchDescriptor(predicate: predicate, sortBy: [SortDescriptor(\.scheduledDate)])
        descriptor.fetchLimit = 1
        
        guard let appointment = try? context.fetch(descriptor).first,
              appointment.isActive else { return nil }
        
        return AppointmentSnapshot(
            id: appointment.id,
            scheduledDate: appointment.scheduledDate,
            status: appointment.status,
            services: appointment.services.map(\.name)
        )
    }
}

struct ClientEntry: TimelineEntry {
    let date: Date
    let appointment: AppointmentSnapshot?
    
    static let empty = ClientEntry(date: .now, appointment: nil)
}

struct AppointmentSnapshot {
    let id: UUID
    let scheduledDate: Date
    let status: AppointmentStatus
    let services: [String]
    
    var isPending: Bool { status == .pendingConfirmation }
    
    var countdown: String {
        let calendar = Calendar.current
        let now = Date.now
        
        guard scheduledDate > now else { return "Agora" }
        
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: now), to: calendar.startOfDay(for: scheduledDate)).day ?? 0
        
        if days > 1 { return "Em \(days) dias" }
        if days == 1 { return "Amanhã" }
        
        let hours = Int(scheduledDate.timeIntervalSince(now)) / 3600
        if hours > 0 { return "Em \(hours)h" }
        
        let minutes = Int(scheduledDate.timeIntervalSince(now)) / 60
        return "Em \(minutes) min"
    }
    
    var deepLink: URL { URL(string: "\(Config.confirmURL)\(id.uuidString)")! }
}

private struct ClientView: View {
    let entry: ClientEntry
    
    var body: some View {
        if let apt = entry.appointment {
            content(apt)
        } else {
            placeholder
        }
    }
    
    private func content(_ apt: AppointmentSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: "scissors")
                    .font(.caption2)
                    .foregroundStyle(Color.accentColor)
                Text("Leila Salon")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Text(apt.countdown)
                .font(.headline)
                .bold()
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            
            Text(apt.services.joined(separator: ", "))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            
            Spacer(minLength: 0)
            
            HStack(spacing: 4) {
                badge(apt.status)
                Spacer(minLength: 0)
                if apt.isPending {
                    Text("Confirmar →")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(Color.accentColor)
                }
            }
        }
        .widgetURL(apt.deepLink)
    }
    
    private var placeholder: some View {
        VStack(spacing: 6) {
            Image(systemName: "calendar")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Nenhum agendamento")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    private func badge(_ status: AppointmentStatus) -> some View {
        let label: String
        let color: Color
        
        switch status {
        case .pendingConfirmation: label = "Pendente"; color = .orange
        case .confirmed: label = "Confirmado"; color = .blue
        default: label = ""; color = .clear
        }
        
        return Text(label)
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

private func sharedContainer() -> ModelContainer? {
    try? ModelContainer(
        for: Appointment.self, SalonService.self,
        configurations: ModelConfiguration(groupContainer: .identifier(Config.appGroup))
    )
}
