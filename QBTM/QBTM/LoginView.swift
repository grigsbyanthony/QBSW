import SwiftUI

struct OutlinedTextFieldStyle: TextFieldStyle {
    var icon: Image? = nil

    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack {
            if let icon = icon {
                icon
                    .foregroundColor(.gray)
            }
            configuration
                .padding(0)
        }
        .background(RoundedRectangle(cornerRadius: 8).stroke(Color.clear, lineWidth: 1))
        .padding(.horizontal)
    }
}


struct LoginView: View {
    @State private var address: String = ""
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showMainView = false
    @State private var showError = false

    var body: some View {
        if showMainView {
            ContentView()
        } else {
            VStack {
                VStack(spacing: 20) {
                    CustomTextField(placeholder: "WebUI Host Address", text: $address)
                        .textFieldStyle(OutlinedTextFieldStyle(icon: Image(systemName: "network")))
                    CustomTextField(placeholder: "WebUI Username", text: $username)
                        .textFieldStyle(OutlinedTextFieldStyle(icon: Image(systemName: "person.crop.circle.badge")))
                    SecureCustomTextField(placeholder: "WebUI Password", text: $password)
                        .textFieldStyle(OutlinedTextFieldStyle(icon: Image(systemName: "ellipsis.rectangle.fill")))
                }
                .padding(.horizontal, 40)

                Button(action: authenticateAndSaveCredentials) {
                    Text("Login")
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(10)
                        .padding(.top, 30)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 40)


                if showError {
                    Text("Login failed. Please check your details.")
                        .foregroundColor(.red)
                        .padding(.top, 10)
                }
            }
            .frame(width: 400, height: 400)
        }
    }

    func authenticateAndSaveCredentials() {
        if address.isEmpty || username.isEmpty || password.isEmpty {
            showError = true
        } else {
            UserDefaults.standard.set(address, forKey: "qbAddress")
            UserDefaults.standard.set(username, forKey: "qbUsername")
            UserDefaults.standard.set(password, forKey: "qbPassword")
            showMainView = true
        }
    }
}

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)
    }
}

struct SecureCustomTextField: View {
    var placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(placeholder, text: $text)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            .padding(.horizontal)
    }
}

#Preview {
    LoginView()
}
