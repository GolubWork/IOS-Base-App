import SwiftUI

/// <summary>
/// Main tab view providing navigation between game application sections:
/// </summary>
struct MainTabView: View {
    @EnvironmentObject var history: HistoryStore

    var body: some View {
        TabView {
        }
        .onAppear {
