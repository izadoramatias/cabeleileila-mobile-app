//
//  AnalyticsViewModel.swift
//  leilaSalon
//
//  Created by Izadora Lima on 18/06/26.
//

import Foundation
import Combine
import SwiftData

enum AnalyticsPeriod: String, CaseIterable, Identifiable {
    case week = "Semana"
    case month = "Mês"
    case quarter = "Trimestre"
    
    var id: String { rawValue }
    
    var dateRange: (start: Date, end: Date) {
        let now = Date()
        let calendar = Calendar.current
        
        switch self {
        case .week:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else {
                return (now, now)
            }
            return (interval.start, interval.end)
        case .month:
            guard let interval = calendar.dateInterval(of: .month, for: now) else {
                return (now, now)
            }
            return (interval.start, interval.end)
        case .quarter:
            let start = calendar.date(byAdding: .month, value: -3, to: now) ?? now
            let end = calendar.dateInterval(of: .month, for: now)?.end ?? now
            return (start, end)
        }
    }
}

struct AnalyticsSummary {
    let totalAppointments: Int
    let confirmedCount: Int
    let pendingCount: Int
    let cancelledCount: Int
    let noShowCount: Int
    let completedCount: Int
    let totalRevenue: Double
    let averageRevenuePerAppointment: Double
    let topServices: [(name: String, count: Int)]
    let confirmationRate: Double
    
    var formattedRevenue: String {
        String(format: "R$ %.2f", totalRevenue)
    }
    
    var formattedAverage: String {
        String(format: "R$ %.2f", averageRevenuePerAppointment)
    }
    
    var formattedConfirmationRate: String {
        String(format: "%.0f%%", confirmationRate * 100)
    }
}

@MainActor
class AnalyticsViewModel: ObservableObject {
    
    @Published var summary: AnalyticsSummary?
    @Published var selectedPeriod: AnalyticsPeriod = .week {
        didSet { computeSummary() }
    }
    
    private var repository: ScheduleRepositoryProtocol
    
    init(repository: ScheduleRepositoryProtocol) {
        self.repository = repository
    }
    
    func updateRepository(_ repository: ScheduleRepositoryProtocol) {
        self.repository = repository
    }
    
    func loadData() {
        computeSummary()
    }
    
    private func computeSummary() {
        let range = selectedPeriod.dateRange
        let appointments = repository.fetchAppointments(from: range.start, to: range.end)
        
        guard !appointments.isEmpty else {
            summary = AnalyticsSummary(
                totalAppointments: 0,
                confirmedCount: 0,
                pendingCount: 0,
                cancelledCount: 0,
                noShowCount: 0,
                completedCount: 0,
                totalRevenue: 0,
                averageRevenuePerAppointment: 0,
                topServices: [],
                confirmationRate: 0
            )
            return
        }
        
        let confirmed = appointments.filter { $0.status == .confirmed }
        let pending = appointments.filter { $0.status == .pendingConfirmation }
        let cancelled = appointments.filter { $0.isCancelled }
        let noShow = appointments.filter { $0.status == .noShow }
        let completed = appointments.filter { $0.status == .completed }
        
        let revenueAppointments = completed
        let totalRevenue = revenueAppointments.reduce(0.0) { $0 + $1.totalPrice }
        let avgRevenue = revenueAppointments.isEmpty ? 0 : totalRevenue / Double(revenueAppointments.count)
        
        var serviceCounts: [String: Int] = [:]
        for appointment in appointments {
            for service in appointment.services {
                serviceCounts[service.name, default: 0] += 1
            }
        }
        let topServices = serviceCounts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { (name: $0.key, count: $0.value) }
        
        let decidedCount = confirmed.count + completed.count + noShow.count + cancelled.count
        let positiveCount = confirmed.count + completed.count
        let confirmationRate = decidedCount > 0 ? Double(positiveCount) / Double(decidedCount) : 0
        
        summary = AnalyticsSummary(
            totalAppointments: appointments.count,
            confirmedCount: confirmed.count,
            pendingCount: pending.count,
            cancelledCount: cancelled.count,
            noShowCount: noShow.count,
            completedCount: completed.count,
            totalRevenue: totalRevenue,
            averageRevenuePerAppointment: avgRevenue,
            topServices: topServices,
            confirmationRate: confirmationRate
        )
    }
}
