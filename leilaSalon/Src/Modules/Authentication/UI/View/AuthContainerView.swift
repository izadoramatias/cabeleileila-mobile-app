//
//  AuthContainerView.swift
//  leilaSalon
//
//  Created by Izadora Lima on 16/06/26.
//

import SwiftUI

struct AuthContainerView: View {
    @ObservedObject var viewModel: AuthViewModel
    
    var body: some View {
        SignInView(viewModel: viewModel)
            .sheet(isPresented: $viewModel.isShowingSignUp) {
                SignUpView(viewModel: viewModel)
            }
    }
}

#Preview {
    AuthContainerView(viewModel: AuthViewModel())
}
