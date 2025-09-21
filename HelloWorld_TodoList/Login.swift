import SwiftUI
import FirebaseCore
import FirebaseAuth

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var showRegister = false
    @State private var showHome = false

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Text("Welcome Back!")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .autocapitalization(.none)

                Button("Login") {
                    loginAttempt()
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(8)
                
                Button("Register") {
                    showRegister = true
                }
                .font(.headline)
                .padding()

                Spacer()
                
                NavigationLink("", destination: RegisterView(), isActive: $showRegister)
                NavigationLink("", destination: ContentView(), isActive: $showHome)
            }
            .padding()
            .alert("Login Failed", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Login Failed")
            }
        }
    }

    private func loginAttempt() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let _ = error {
                showError = true
            } else {
                showHome = true
            }
        }
    }
}
