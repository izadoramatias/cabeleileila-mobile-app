//
//  leilaSalonApp.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import SwiftUI
import SwiftData
import Supabase
import WidgetKit

@main
struct leilaSalonApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        clearKeychainIfFirstLaunch()
        _ = NotificationManager.shared
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Appointment.self,
            SalonService.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier(Constants.App.appGroupId)
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            AppCoordinator()
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .background {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    private func clearKeychainIfFirstLaunch() {
        let key = "hasLaunchedBefore"
        
        guard UserDefaults.standard.bool(forKey: key) == false else { return }
        
        Task { try? await SupabaseManager.shared.client.auth.signOut(scope: .local) }
        
        UserDefaults.standard.set(true, forKey: key)
    }
}
