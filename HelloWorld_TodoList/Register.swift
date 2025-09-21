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
        ZStack {
            Color(red: 242/255, green: 247/255, blue: 252/255)
                .ignoresSafeArea()
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
    }

    private func registerUser() {
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            showError = true
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let err = error as NSError? {
                print("[AUTH] domain=\(err.domain) code=\(err.code) userInfo=\(err.userInfo)")
                errorMessage = err.localizedDescription
                showError = true
                return
            }

            // only runs if sign-up succeeded
            guard let user = authResult?.user else { return }

            Firestore.firestore().collection("users").document(user.uid).setData([
                "email": self.email,
                "createdAt": Timestamp()
            ]) { fsError in
                if let fsError = fsError as NSError? {
                    print("[FIRESTORE] domain=\(fsError.domain) code=\(fsError.code) userInfo=\(fsError.userInfo)")
                    errorMessage = "Firestore error: \(fsError.localizedDescription)"
                    showError = true
                } else {
                    showHome = true
                }
            }
        }
    }
}
