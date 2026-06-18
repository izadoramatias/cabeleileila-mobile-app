//
//  leilaSalonTests.swift
//  leilaSalonTests
//
//  Created by Izadora Lima on 16/06/26.
//

import Testing
import Foundation
@testable import leilaSalon

struct AppointmentTests {
        
    @Test func novoAgendamentoCriaPendente() {
        let appointment = Appointment(
            userId: "user-1",
            clientName: "Maria",
            scheduledDate: Date().addingTimeInterval(86400 * 7),
            services: []
        )
        
        #expect(appointment.status == .pendingConfirmation)
        #expect(appointment.confirmedAt == nil)
    }
    
    @Test func agendamentoPendenteEhAtivo() {
        let appointment = makeAppointment(status: .pendingConfirmation)
        #expect(appointment.isActive == true)
    }
    
    @Test func agendamentoConfirmadoEhAtivo() {
        let appointment = makeAppointment(status: .confirmed)
        #expect(appointment.isActive == true)
    }
    
    @Test func agendamentoCanceladoNaoEhAtivo() {
        let appointment = makeAppointment(status: .cancelledByClient)
        #expect(appointment.isActive == false)
    }
    
    @Test func agendamentoConcluidoNaoEhAtivo() {
        let appointment = makeAppointment(status: .completed)
        #expect(appointment.isActive == false)
    }
    
    @Test func agendamentoNoShowNaoEhAtivo() {
        let appointment = makeAppointment(status: .noShow)
        #expect(appointment.isActive == false)
    }
    
    @Test func agendamentoFuturoMaisDe2DiasEhEditavel() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let appointment = makeAppointment(status: .pendingConfirmation, date: futureDate)
        #expect(appointment.isEditable == true)
    }
    
    @Test func agendamentoAmanhaNaoEhEditavel() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let appointment = makeAppointment(status: .pendingConfirmation, date: tomorrow)
        #expect(appointment.isEditable == false)
    }
    
    @Test func agendamentoCanceladoNaoEhEditavel() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let appointment = makeAppointment(status: .cancelledByClient, date: futureDate)
        #expect(appointment.isEditable == false)
    }
    
    @Test func podeConfirmarQuandoPendenteEFuturo() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        let appointment = makeAppointment(status: .pendingConfirmation, date: futureDate)
        #expect(appointment.canConfirm == true)
    }
    
    @Test func naoPodeConfirmarQuandoJaConfirmado() {
        let futureDate = Calendar.current.date(byAdding: .day, value: 3, to: Date())!
        let appointment = makeAppointment(status: .confirmed, date: futureDate)
        #expect(appointment.canConfirm == false)
    }
    
    @Test func naoPodeConfirmarQuandoDataPassou() {
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let appointment = makeAppointment(status: .pendingConfirmation, date: pastDate)
        #expect(appointment.canConfirm == false)
    }
    
    @Test func canceladoPeloClienteEhCancelado() {
        let appointment = makeAppointment(status: .cancelledByClient)
        #expect(appointment.isCancelled == true)
    }
    
    @Test func canceladoPeloAdminEhCancelado() {
        let appointment = makeAppointment(status: .cancelledByAdmin)
        #expect(appointment.isCancelled == true)
    }
    
    @Test func confirmadoNaoEhCancelado() {
        let appointment = makeAppointment(status: .confirmed)
        #expect(appointment.isCancelled == false)
    }
    
    @Test func precoTotalSomaServicos() {
        let services = [
            SalonService(name: "Corte", durationMinutes: 45, price: 80),
            SalonService(name: "Escova", durationMinutes: 30, price: 50),
        ]
        let appointment = Appointment(
            userId: "user-1",
            clientName: "Ana",
            scheduledDate: Date(),
            services: services
        )
        
        #expect(appointment.totalPrice == 130.0)
        #expect(appointment.formattedTotalPrice == "R$ 130.00")
    }
    
    @Test func duracaoTotalSomaServicos() {
        let services = [
            SalonService(name: "Corte", durationMinutes: 45, price: 80),
            SalonService(name: "Escova", durationMinutes: 30, price: 50),
        ]
        let appointment = Appointment(
            userId: "user-1",
            clientName: "Ana",
            scheduledDate: Date(),
            services: services
        )
        
        #expect(appointment.totalDurationMinutes == 75)
    }
    
    @Test func semServicosPrecoEZero() {
        let appointment = Appointment(
            userId: "user-1",
            clientName: "Ana",
            scheduledDate: Date(),
            services: []
        )
        
        #expect(appointment.totalPrice == 0)
        #expect(appointment.totalDurationMinutes == 0)
    }
    
    private func makeAppointment(
        status: AppointmentStatus,
        date: Date = Date().addingTimeInterval(86400 * 7)
    ) -> Appointment {
        let appointment = Appointment(
            userId: "user-1",
            clientName: "Teste",
            scheduledDate: date,
            services: []
        )
        appointment.status = status
        return appointment
    }
}

struct UserRoleTests {
    
    @Test func roleAdminRetornaAdmin() {
        let role = UserRole.from("admin")
        #expect(role == .admin)
    }
    
    @Test func roleProfessionalRetornaProfessional() {
        let role = UserRole.from("professional")
        #expect(role == .professional)
    }
    
    @Test func roleClientRetornaClient() {
        let role = UserRole.from("client")
        #expect(role == .client)
    }
    
    @Test func roleNilRetornaClient() {
        let role = UserRole.from(nil)
        #expect(role == .client)
    }
    
    @Test func roleDesconhecidoRetornaClient() {
        let role = UserRole.from("manager")
        #expect(role == .client)
    }
    
    @Test func roleVazioRetornaClient() {
        let role = UserRole.from("")
        #expect(role == .client)
    }
}

struct SalonServiceTests {
    
    @Test func formatacaoDePreco() {
        let service = SalonService(name: "Corte", durationMinutes: 45, price: 80)
        #expect(service.formattedPrice == "R$ 80.00")
    }
    
    @Test func formatacaoDeDuracao() {
        let service = SalonService(name: "Corte", durationMinutes: 45, price: 80)
        #expect(service.formattedDuration == "45 min")
    }
    
    @Test func samplesNaoEstaVazio() {
        #expect(SalonService.samples.count == 7)
    }
    
    @Test func samplesTemPrecosPositivos() {
        for service in SalonService.samples {
            #expect(service.price > 0)
            #expect(service.durationMinutes > 0)
        }
    }
}

struct AuthErrorTests {
    
    @Test func emailInvalidoTemMensagem() {
        let error = AuthError.invalidEmail
        #expect(error.errorDescription == "Por favor, insira um e-mail válido.")
    }
    
    @Test func senhaInvalidaTemMensagem() {
        let error = AuthError.invalidPassword
        #expect(error.errorDescription == "A senha deve ter pelo menos 6 caracteres.")
    }
    
    @Test func senhasNaoCoincidemTemMensagem() {
        let error = AuthError.passwordMismatch
        #expect(error.errorDescription == "As senhas não coincidem.")
    }
    
    @Test func sessaoNaoEncontradaTemMensagem() {
        let error = AuthError.sessionNotFound
        #expect(error.errorDescription == "Sessão não encontrada. Tente novamente.")
    }
}
