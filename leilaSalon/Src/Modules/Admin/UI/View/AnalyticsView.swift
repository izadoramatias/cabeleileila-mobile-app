//
//  AnalyticsView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 18/06/26.
//

import SwiftUI
import SwiftData

struct AnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AnalyticsViewModel
    
    init() {
        self._viewModel = StateObject(wrappedValue: AnalyticsViewModel(
            repository: AnalyticsPlaceholderRepository()
        ))
    }
    
    var body: some View {
        NavigationStack {
            content
                .navigationTitle("Análises")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Fechar") { dismiss() }
                    }
                }
                .onAppear {
                    let repo = ScheduleRepository(modelContext: modelContext)
                    viewModel.updateRepository(repo)
                    viewModel.loadData()
                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        if let summary = viewModel.summary {
            List {
                periodPicker
                overviewSection(summary)
                revenueSection(summary)
                statusBreakdown(summary)
                topServicesSection(summary)
            }
        } else {
            ProgressView()
        }
    }
}

private extension AnalyticsView {
    
    var periodPicker: some View {
        Section {
            Picker("Período", selection: $viewModel.selectedPeriod) {
                ForEach(AnalyticsPeriod.allCases) { period in
                    Text(period.rawValue).tag(period)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    func overviewSection(_ summary: AnalyticsSummary) -> some View {
        Section("Visão Geral") {
            statRow("Total de agendamentos", value: "\(summary.totalAppointments)")
            statRow("Taxa de confirmação", value: summary.formattedConfirmationRate)
        }
    }
    
    func revenueSection(_ summary: AnalyticsSummary) -> some View {
        Section("Faturamento") {
            statRow("Receita total", value: summary.formattedRevenue)
            statRow("Ticket médio", value: summary.formattedAverage)
        }
    }
    
    func statusBreakdown(_ summary: AnalyticsSummary) -> some View {
        Section("Por Status") {
            statusRow("Confirmados", count: summary.confirmedCount, color: .blue)
            statusRow("Pendentes", count: summary.pendingCount, color: .orange)
            statusRow("Concluídos", count: summary.completedCount, color: .green)
            statusRow("Cancelados", count: summary.cancelledCount, color: .red)
            statusRow("Não compareceram", count: summary.noShowCount, color: .gray)
        }
    }
    
    func topServicesSection(_ summary: AnalyticsSummary) -> some View {
        Section("Serviços Mais Populares") {
            if summary.topServices.isEmpty {
                Text("Sem dados para este período")
                    .foregroundColor(.secondary)
            } else {
                ForEach(summary.topServices, id: \.name) { service in
                    HStack {
                        Text(service.name)
                        Spacer()
                        Text("\(service.count)x")
                            .foregroundColor(.secondary)
                            .fontWeight(.medium)
                    }
                }
            }
        }
    }
    
    func statRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
    }
    
    func statusRow(_ title: String, count: Int, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
            Spacer()
            Text("\(count)")
                .fontWeight(.medium)
                .foregroundColor(.secondary)
        }
    }
}

private class AnalyticsPlaceholderRepository: ScheduleRepositoryProtocol {
    func fetchAppointments(from startDate: Date, to endDate: Date) -> [Appointment] { [] }
    func fetchAppointments(from startDate: Date, to endDate: Date, userId: String) -> [Appointment] { [] }
    func fetchAllAppointments() -> [Appointment] { [] }
    func fetchAppointments(forUser userId: String) -> [Appointment] { [] }
    func createAppointment(_ appointment: Appointment) {}
    func confirm(_ appointment: Appointment) {}
    func reschedule(_ appointment: Appointment, to newDate: Date) {}
    func cancel(_ appointment: Appointment, byAdmin: Bool) {}
    func markAsCompleted(_ appointment: Appointment) {}
    func markAsNoShow(_ appointment: Appointment) {}
    func seedServicesIfNeeded() {}
    func fetchServices() -> [SalonService] { [] }
}
