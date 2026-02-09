import UIKit

/// <summary>
/// Provides helper methods to control and enforce application interface orientation.
/// </summary>
struct OrientationLock {

    /// <summary>
    /// Locks the application to the specified interface orientation mask.
    /// </summary>
    static func lock(_ orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            delegate.orientationLock = orientation
        }
    }

    /// <summary>
    /// Locks the application to portrait orientation and forces device orientation update.
    /// </summary>
    static func lockPortrait() {
        lock(.portrait)
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
    }
}
