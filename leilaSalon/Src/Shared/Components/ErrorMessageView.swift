//
//  ErrorMessageView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import SwiftUI

struct ErrorMessageView: View {
    let message: String?
    
    var body: some View {
        if let message {
            Text(message)
                .font(.caption)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .accessibilityLabel("Erro: \(message)")
        }
    }
}
