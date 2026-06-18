//
//  AppCoordinator.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import SwiftUI

struct AppCoordinator: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        content
            .task {
                await authViewModel.checkCurrentSession()
                _ = await NotificationManager.shared.requestPermission()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        switch authViewModel.authState {
        case .authenticated:
            HomeView(authViewModel: authViewModel)
        case .loading:
            ProgressView("Carregando...")
                .accessibilityLabel("Carregando aplicativo")
        case .pendingConfirmation:
            PendingConfirmationView(authViewModel: authViewModel)
        default:
            AuthContainerView(viewModel: authViewModel)
        }
    }
}

#Preview {
    AppCoordinator()
}
