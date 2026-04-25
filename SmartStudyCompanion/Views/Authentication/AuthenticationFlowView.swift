import SwiftUI

/// Container view that manages navigation between login and signup
struct AuthenticationFlowView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isShowingSignUp = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.94, green: 0.98, blue: 0.95),
                    Color(red: 0.96, green: 0.98, blue: 0.94)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if isShowingSignUp {
                SignUpView(isShowingSignUp: $isShowingSignUp)
                    .environmentObject(authViewModel)
                    .transition(.move(edge: .trailing))
            } else {
                LoginView(isShowingSignUp: $isShowingSignUp)
                    .environmentObject(authViewModel)
                    .transition(.move(edge: .leading))
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        AuthenticationFlowView()
            .environmentObject(AuthViewModel())
    }
}
