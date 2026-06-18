//
//  DeepLinkManager.swift
//  leilaSalon
//
//  Created by Izadora Lima on 18/06/26.
//

import Foundation
import Combine

@MainActor
class DeepLinkManager: ObservableObject {
    static let shared = DeepLinkManager()
    
    @Published var pendingAppointmentId: UUID?
    
    private init() {}
    
    func navigate(toAppointment id: UUID) {
        pendingAppointmentId = id
    }
    
    func clearPending() {
        pendingAppointmentId = nil
    }
}
