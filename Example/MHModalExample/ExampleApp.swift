import SwiftUI
import MHModal

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Debug Border

extension View {
    func debugBorder(_ color: Color) -> some View {
        self.border(color, width: 2)
    }
}

// MARK: - Content View

struct ContentView: View {
    @State private var showBasic = false
    @State private var showPhaseFlow = false
    @State private var showNavigation = false
    @State private var showKeyboard = false
    @State private var showMinimal = false
    @State private var onboardingStep = 0

    var body: some View {
        NavigationStack {
            List {
                Section("Transitions") {
                    Button("Phase Flow (Cross-Dissolve + Morph)") {
                        onboardingStep = 0
                        showPhaseFlow = true
                    }
                }

                Section("Navigation") {
                    Button("Push / Pop (Back Button)") {
                        showNavigation = true
                    }
                }

                Section("Keyboard") {
                    Button("Modal with Text Field") {
                        showKeyboard = true
                    }
                }

                Section("Appearance") {
                    Button("Basic Modal") {
                        showBasic = true
                    }
                    Button("Minimal Style") {
                        showMinimal = true
                    }
                }
            }
            .navigationTitle("MHModal")
        }

        // MARK: - Basic

        .presentModal(isPresented: $showBasic) {
            BasicModalContent(isPresented: $showBasic)
        }

        // MARK: - Phase Flow

        .presentModal(
            isPresented: $showPhaseFlow,
            phase: onboardingStep,
            behavior: .nonDismissible
        ) { step in
            PhaseFlowContent(
                step: step,
                onNext: { onboardingStep += 1 },
                onDone: { showPhaseFlow = false }
            )
        }

        // MARK: - Navigation

        .presentModal(isPresented: $showNavigation) {
            NavigationModalContent(isPresented: $showNavigation)
        }

        // MARK: - Keyboard

        .presentModal(isPresented: $showKeyboard) {
            KeyboardModalContent(isPresented: $showKeyboard)
        }

        // MARK: - Minimal

        .presentMinimalModal(isPresented: $showMinimal) {
            MinimalModalContent(isPresented: $showMinimal)
        }
    }
}

// MARK: - Basic Modal

private struct BasicModalContent: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
                .debugBorder(.red)

            Text("Hello from MHModal")
                .font(.title2.bold())
                .debugBorder(.green)

            Text("This sheet automatically sizes to its content. Try adding more content to see it grow.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .debugBorder(.blue)

            Button("Done") {
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
            .debugBorder(.purple)
        }
        .debugBorder(.orange)
        .padding(24)
        .debugBorder(.red)
    }
}

// MARK: - Phase Flow

private struct PhaseFlowContent: View {
    let step: Int
    let onNext: () -> Void
    let onDone: () -> Void

    var body: some View {
        switch step {
        case 0:
            welcomeStep
        case 1:
            featuresStep
        default:
            doneStep
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(.indigo)
                .debugBorder(.red)

            Text("Welcome")
                .font(.title2.bold())
                .debugBorder(.green)

            Text("Let's get you set up in a few quick steps.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .debugBorder(.blue)

            Button("Get Started", action: onNext)
                .buttonStyle(.borderedProminent)
                .tint(.indigo)
                .debugBorder(.purple)
        }
        .debugBorder(.orange)
        .padding(24)
        .debugBorder(.red)
    }

    private var featuresStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
                .debugBorder(.red)

            Text("What's New")
                .font(.title2.bold())
                .debugBorder(.green)

            VStack(alignment: .leading, spacing: 12) {
                featureRow(icon: "bolt.fill", color: .yellow, text: "Synchronized transitions")
                featureRow(icon: "keyboard", color: .blue, text: "Keyboard avoidance")
                featureRow(icon: "arrow.up.and.down", color: .green, text: "Self-sizing sheets")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .debugBorder(.cyan)

            Button("Continue", action: onNext)
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .debugBorder(.purple)
        }
        .debugBorder(.orange)
        .padding(24)
        .debugBorder(.red)
    }

    private var doneStep: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
                .debugBorder(.red)

            Text("You're all set!")
                .font(.title2.bold())
                .debugBorder(.green)

            Button("Let's Go", action: onDone)
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .debugBorder(.purple)
        }
        .debugBorder(.orange)
        .padding(24)
        .debugBorder(.red)
    }

    private func featureRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body.bold())
                .foregroundStyle(color)
                .frame(width: 24)

            Text(text)
                .font(.body)
        }
        .debugBorder(.mint)
    }
}

// MARK: - Navigation Modal

private struct NavigationModalContent: View {
    @Binding var isPresented: Bool
    @Environment(\.modalNavigator) var navigator

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet")
                .font(.system(size: 48))
                .foregroundStyle(.teal)
                .debugBorder(.red)

            Text("Settings")
                .font(.title2.bold())
                .debugBorder(.green)

            Button("Account Details") {
                navigator?.push(title: "Account") {
                    AccountDetailView()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
            .debugBorder(.purple)

            Button("Done") {
                isPresented = false
            }
            .buttonStyle(.bordered)
            .debugBorder(.purple)
        }
        .debugBorder(.orange)
        .padding(24)
        .debugBorder(.red)
    }
}

private struct AccountDetailView: View {
    @Environment(\.modalNavigator) var navigator

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: { navigator?.pop() }) {
                Label("Back", systemImage: "chevron.left")
            }
            .debugBorder(.purple)

            Label("John Appleseed", systemImage: "person.fill")
                .debugBorder(.green)
            Label("john@example.com", systemImage: "envelope.fill")
                .debugBorder(.green)
            Label("Member since 2024", systemImage: "calendar")
                .debugBorder(.green)

            Button("Subscription") {
                navigator?.push(title: "Subscription") {
                    SubscriptionDetailView()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.teal)
            .debugBorder(.purple)
        }
        .font(.body)
        .debugBorder(.orange)
        .padding(24)
        .debugBorder(.red)
    }
}

private struct SubscriptionDetailView: View {
    @Environment(\.modalNavigator) var navigator

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: { navigator?.pop() }) {
                Label("Back", systemImage: "chevron.left")
            }
            .debugBorder(.purple)

            Label("Pro Plan", systemImage: "star.fill")
                .debugBorder(.green)
            Label("$9.99/month", systemImage: "creditcard.fill")
                .debugBorder(.green)
            Label("Renews April 15, 2026", systemImage: "arrow.clockwise")
                .debugBorder(.green)
        }
        .font(.body)
        .debugBorder(.orange)
        .padding(24)
        .debugBorder(.red)
    }
}

// MARK: - Keyboard Modal

private struct KeyboardModalContent: View {
    @Binding var isPresented: Bool
    @State private var name = ""
    @State private var email = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Sign Up")
                .font(.title2.bold())
                .debugBorder(.green)

            TextField("Name", text: $name)
                .textFieldStyle(.roundedBorder)
                .debugBorder(.blue)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .debugBorder(.blue)

            Button("Submit") {
                isPresented = false
            }
            .buttonStyle(.borderedProminent)
            .disabled(name.isEmpty || email.isEmpty)
            .debugBorder(.purple)
        }
        .debugBorder(.orange)
        .padding(24)
        .debugBorder(.red)
    }
}

// MARK: - Minimal Modal

private struct MinimalModalContent: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 16) {
            Text("Minimal Style")
                .font(.title3.bold())
                .debugBorder(.green)

            Text("No grabber, 24pt corner radius.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .debugBorder(.blue)

            Button("Close") {
                isPresented = false
            }
            .buttonStyle(.bordered)
            .debugBorder(.purple)
        }
        .debugBorder(.orange)
        .padding(24)
        .debugBorder(.red)
    }
}
