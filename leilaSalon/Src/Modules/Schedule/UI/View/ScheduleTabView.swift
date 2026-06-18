//
//  ScheduleTabView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import SwiftUI
import SwiftData

struct ScheduleTabView: View {
    @Environment(\.modelContext) private var modelContext
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: ScheduleViewModel
    
    private let repository: ScheduleRepositoryProtocol
    
    init(modelContext: ModelContext, authViewModel: AuthViewModel) {
        let repo = ScheduleRepository(modelContext: modelContext)
        self.repository = repo
        self.authViewModel = authViewModel
        self._viewModel = StateObject(wrappedValue: ScheduleViewModel(repository: repo, userId: authViewModel.userId, isAdmin: authViewModel.isAdmin))
    }
    
    @State private var isShowingNewAppointment = false
    @State private var isShowingSettings = false
    @State private var selectedAppointment: Appointment?
    @ObservedObject private var deepLink = DeepLinkManager.shared
    
    var body: some View {
        TabView {
            appointmentsTab
            historyTab
        }
        .onAppear { viewModel.loadData() }
        .sheet(isPresented: $isShowingSettings) {
            if authViewModel.isAdmin {
                AdminSettingsView(authViewModel: authViewModel)
            } else {
                UserSettingsView(authViewModel: authViewModel)
            }
        }
        .onChange(of: deepLink.pendingAppointmentId) { appointmentId in
            guard let appointmentId else { return }
            selectedAppointment = viewModel.appointments.first { $0.id == appointmentId }
            deepLink.clearPending()
        }
    }
}

private extension ScheduleTabView {
    
    var appointmentsTab: some View {
        NavigationStack {
            appointmentsList
                .navigationTitle("Agendamentos")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        profileButton
                    }
                    if !authViewModel.isAdmin {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                isShowingNewAppointment = true
                            } label: {
                                Image(systemName: "plus")
                            }
                            .accessibilityLabel("Novo agendamento")
                        }
                    }
                }
                .sheet(isPresented: $isShowingNewAppointment) {
                    NewAppointmentView(viewModel: viewModel)
                }
                .navigationDestination(item: $selectedAppointment) { appointment in
                    AppointmentDetailView(viewModel: viewModel, appointment: appointment)
                }
        }
        .tabItem {
            Label("Agenda", systemImage: "calendar")
        }
    }
    
    var historyTab: some View {
        NavigationStack {
            HistoryView(
                scheduleViewModel: viewModel,
                repository: repository,
                userId: authViewModel.userId,
                isAdmin: authViewModel.isAdmin
            )
        }
        .tabItem {
            Label("Histórico", systemImage: "clock.arrow.circlepath")
        }
    }
    
    var profileButton: some View {
        Button {
            isShowingSettings = true
        } label: {
            Image(systemName: authViewModel.isAdmin ? "gearshape.fill" : "person.circle")
                .foregroundColor(authViewModel.isAdmin ? .indigo : .primary)
        }
        .accessibilityLabel(authViewModel.isAdmin ? "Configurações" : "Perfil")
    }
    
    @ViewBuilder
    var appointmentsList: some View {
        let upcoming = viewModel.appointments.filter { $0.isActive }
        
        if upcoming.isEmpty {
            ContentUnavailableView(
                "Nenhum agendamento",
                systemImage: "calendar",
                description: Text(authViewModel.isAdmin
                    ? "Nenhum agendamento ativo no momento."
                    : "Toque no + para criar um novo agendamento.")
            )
        } else {
            List(upcoming) { appointment in
                NavigationLink {
                    AppointmentDetailView(viewModel: viewModel, appointment: appointment)
                } label: {
                    AppointmentRow(appointment: appointment)
                }
            }
            .listStyle(.plain)
        }
    }
}
