import SwiftUI

/// Main tab view providing navigation between game application sections (Generator, Save, List).
struct MainTabView: View {
    @Environment(\.dependencyContainer) private var container

    var body: some View {
        Group {
            if let container = container {
                TabView {
                    NavigationStack {
                        PasswordGeneratorView(generatePasswordUseCase: container.generatePasswordUseCase)
                    }
                    .tabItem { Label("Generator", systemImage: "key.fill") }

                    NavigationStack {
                        PasswordSaveView(savePasswordUseCase: container.savePasswordUseCase)
                    }
                    .tabItem { Label("Save", systemImage: "square.and.arrow.down") }

                    NavigationStack {
                        PasswordListView(getPasswordsUseCase: container.getPasswordsUseCase)
                    }
                    .tabItem { Label("Passwords", systemImage: "list.bullet") }
                }
            } else {
                Text("No container")
                    .foregroundColor(.secondary)
            }
        }
    }
}
