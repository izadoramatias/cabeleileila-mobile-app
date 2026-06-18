//
//  Constants.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import Foundation

enum Constants {
    enum Supabase {
        static let projectURL = URL(string: "https://fvtdaetnjmxjlfjfskbi.supabase.co")!
        static let anonKey = "sb_publishable_jkbk_6cxFaT8T0IPdOtQQg_Uk3rHNGD"
    }
    
    enum App {
        static let name = "Leila Salon"
        static let bundleId = "com.leilasalon.app"
        static let appGroupId = "group.app.leilaSalonWidgetExtension"
    }
    
    enum Contact {
        static let phone = "11999999999"
        static let whatsappMessage = "Olá! Gostaria de reagendar meu horário."
    }
}
