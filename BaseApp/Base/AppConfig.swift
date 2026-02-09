import Foundation

final class AppConfig {

    static let shared = AppConfig()

    private init() {}

    // Data to fill
    let serverURL: String = "https://laughingdropspop.com/config.php"
    let storeId: String = "6756708872"
    let firebaseProjectId: String = "662865312172"
    let appsFlyerDevKey: String = "zjmEk65LDPa3K8s4BWnpfA"
    // End Data to fill
    
    let os: String = "iOS"
    let noInternetMessage: String = "Please, check your internet connection and restart"
    let notificationSubtitle: String = "Allow notifications about bonuses and promos"
    let notificationDescription: String = "Stay tuned with best offers from our casino"

    
    // Debugging
    // white app: isGameOnly = true, other = false
    // grey app: everything = false
    let isDebug: Bool = false // shows Debug messages from custom debugging
    let isGameOnly: Bool = true // shows only gameScreen
    let isWebOnly: Bool = false // shows only webView
    let isNoNetwork: Bool = false // shows NoNetwork screen
    let isAskNotifications: Bool = false // shows Ask for Notifications screen
    let isInfinityLoading: Bool = false // shows loading screen

    var storeIdWithPrefix: String {
        return "id" + storeId
    }
}
