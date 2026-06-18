//
//  HistoryView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel: HistoryViewModel
    @ObservedObject var scheduleViewModel: ScheduleViewModel
    
    @State private var filterMode: FilterMode = .all
    @State private var singleDate = Date()
    @State private var rangeStart = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    @State private var rangeEnd = Date()
    
    init(scheduleViewModel: ScheduleViewModel, repository: ScheduleRepositoryProtocol, userId: String, isAdmin: Bool) {
        self._viewModel = StateObject(wrappedValue: HistoryViewModel(repository: repository, userId: userId, isAdmin: isAdmin))
        self.scheduleViewModel = scheduleViewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            filterSection
            listSection
        }
        .navigationTitle("Histórico")
        .onAppear { viewModel.loadHistory() }
        .onChange(of: filterMode) { _ in updateFilter() }
        .onChange(of: singleDate) { _ in updateFilter() }
        .onChange(of: rangeStart) { _ in updateFilter() }
        .onChange(of: rangeEnd) { _ in updateFilter() }
    }
    
    private func updateFilter() {
        switch filterMode {
        case .all:
            viewModel.filter = .all
        case .singleDay:
            viewModel.filter = .singleDay(singleDate)
        case .range:
            viewModel.filter = .range(from: rangeStart, to: rangeEnd)
        }
    }
}

private extension HistoryView {
    
    var filterSection: some View {
        VStack(spacing: 12) {
            Picker("Filtro", selection: $filterMode) {
                ForEach(FilterMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            filterDatePickers
        }
        .padding(.vertical, 12)
        .background(Color(.systemGroupedBackground))
    }
    
    @ViewBuilder
    var filterDatePickers: some View {
        switch filterMode {
        case .all:
            EmptyView()
        case .singleDay:
            DatePicker("Dia", selection: $singleDate, displayedComponents: .date)
                .padding(.horizontal)
        case .range:
            VStack {
                DatePicker("De", selection: $rangeStart, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    
                DatePicker("Até", selection: $rangeEnd, displayedComponents: .date)
                    .datePickerStyle(.compact)
            }
            .padding(.horizontal)
        }
    }
    
    var listSection: some View {
        Group {
            if viewModel.filteredAppointments.isEmpty {
                ContentUnavailableView(
                    "Nenhum agendamento",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("Nenhum agendamento encontrado para o filtro selecionado.")
                )
            } else {
                List(viewModel.filteredAppointments) { appointment in
                    NavigationLink {
                        AppointmentDetailView(viewModel: scheduleViewModel, appointment: appointment)
                    } label: {
                        AppointmentRow(appointment: appointment)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

private enum FilterMode: String, CaseIterable, Identifiable {
    case all
    case singleDay
    case range
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .all: "Todos"
        case .singleDay: "Dia"
        case .range: "Período"
        }
    }
}
