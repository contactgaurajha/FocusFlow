import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showHome = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                Text("Create Account")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 20)

                TextField("Email", text: $email)
                    .padding()
                    .background(Color(.systemGray6))
                    .textInputAutocapitalization(.never)

                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .textInputAutocapitalization(.never)

                SecureField("Confirm Password", text: $confirmPassword)
                    .padding()
                    .background(Color(.systemGray6))
                    .textInputAutocapitalization(.never)

                Button(action: registerUser) {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                }
                .padding(.top, 20)

                Spacer()

                NavigationLink("", destination: ContentView(), isActive: $showHome)
            }
            .padding()
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func registerUser() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
            } else {
                showHome = true
            }
        }
    }
}
