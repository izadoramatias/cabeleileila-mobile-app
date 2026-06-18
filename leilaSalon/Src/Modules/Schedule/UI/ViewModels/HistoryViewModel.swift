//
//  HistoryViewModel.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import Foundation
import Combine

enum HistoryFilter: Equatable {
    case all
    case singleDay(Date)
    case range(from: Date, to: Date)
}

@MainActor
class HistoryViewModel: ObservableObject {
    
    @Published var filteredAppointments: [Appointment] = []
    @Published var filter: HistoryFilter = .all {
        didSet { applyFilter() }
    }
    
    private let repository: ScheduleRepositoryProtocol
    private let userId: String
    private let isAdmin: Bool
    
    init(repository: ScheduleRepositoryProtocol, userId: String, isAdmin: Bool) {
        self.repository = repository
        self.userId = userId
        self.isAdmin = isAdmin
    }
    
    func loadHistory() {
        applyFilter()
    }
    
    private func applyFilter() {
        switch filter {
        case .all:
            filteredAppointments = isAdmin
                ? repository.fetchAllAppointments()
                : repository.fetchAppointments(forUser: userId)
        case .singleDay(let date):
            let (start, end) = dayBounds(for: date)
            filteredAppointments = isAdmin
                ? repository.fetchAppointments(from: start, to: end)
                : repository.fetchAppointments(from: start, to: end, userId: userId)
        case .range(let from, let to):
            let start = Calendar.current.startOfDay(for: from)
            let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: to) ?? to
            filteredAppointments = isAdmin
                ? repository.fetchAppointments(from: start, to: end)
                : repository.fetchAppointments(from: start, to: end, userId: userId)
        }
    }
    
    private func dayBounds(for date: Date) -> (Date, Date) {
        let start = Calendar.current.startOfDay(for: date)
        let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: date) ?? date
        return (start, end)
    }
}
