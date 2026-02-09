import SwiftUI

/// <summary>
/// Displays the application log console with scrollable log lines and a clear button.
/// </summary>
struct ConsoleView: View {
    @ObservedObject private var logStore = LogStore.shared

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Console")
                    .bold()
                Spacer()
                Button("Очистить") { logStore.clear() }
            }
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(Array(logStore.lines.enumerated()), id: \.0) { idx, line in
                            Text(line)
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .id(idx)
                        }
                    }
                    .padding(6)
                }
                .background(Color(.systemGray6))
                .onChange(of: logStore.lines.count) { _ in
                    if let last = logStore.lines.indices.last {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }
        }
        .padding(8)
    }
}
