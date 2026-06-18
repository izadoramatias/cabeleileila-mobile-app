//
//  HomeView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ScheduleTabView(modelContext: modelContext, authViewModel: authViewModel)
    }
}

#Preview {
    HomeView(authViewModel: AuthViewModel())
        .modelContainer(for: [Appointment.self, SalonService.self], inMemory: true)
}
