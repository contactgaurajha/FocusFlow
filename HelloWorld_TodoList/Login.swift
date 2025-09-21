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
            ZStack {
                // Full screen background
                Color(red: 242/255, green: 247/255, blue: 252/255)
                    .ignoresSafeArea()

                VStack {
                    Spacer()
                    
                    Text("Welcome Back!")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 20)
                        .foregroundColor(Color(red: 6/255, green: 67/255, blue: 117/255))
                    
                    TextField("Email", text: $email)
                        .padding()
                        .background(Color(.systemGray6))
                        .autocapitalization(.none)
                        .padding(.horizontal) // apply padding here
                    
                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color(.systemGray6))
                        .autocapitalization(.none)
                        .padding(.horizontal)
                    
                    Button("Login") {
                        loginAttempt()
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    
                    Button("Register") {
                        showRegister = true
                    }
                    .font(.headline)
                    .padding()
                    
                    Spacer()
                    
                    NavigationLink("", destination: RegisterView(), isActive: $showRegister)
                    NavigationLink("", destination: ContentView(), isActive: $showHome)
                }
            }
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

