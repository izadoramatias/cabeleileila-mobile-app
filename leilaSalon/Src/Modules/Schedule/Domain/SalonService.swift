//
//  SalonService.swift
//  leilaSalon
//
//  Created by Izadora Lima on 17/06/26.
//

import Foundation
import SwiftData

@Model
final class SalonService {
    var id: UUID
    var name: String
    var durationMinutes: Int
    var price: Double
    
    init(name: String, durationMinutes: Int, price: Double) {
        self.id = UUID()
        self.name = name
        self.durationMinutes = durationMinutes
        self.price = price
    }
}

extension SalonService {
    var formattedPrice: String {
        String(format: "R$ %.2f", price)
    }
    
    var formattedDuration: String {
        "\(durationMinutes) min"
    }
    
    static var samples: [SalonService] {
        [
            SalonService(name: "Corte Feminino", durationMinutes: 45, price: 80),
            SalonService(name: "Escova", durationMinutes: 30, price: 50),
            SalonService(name: "Coloração", durationMinutes: 90, price: 150),
            SalonService(name: "Hidratação", durationMinutes: 40, price: 70),
            SalonService(name: "Manicure", durationMinutes: 30, price: 35),
            SalonService(name: "Pedicure", durationMinutes: 40, price: 45),
            SalonService(name: "Progressiva", durationMinutes: 120, price: 250),
        ]
    }
}
