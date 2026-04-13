import SwiftUI

/// App-wide custom font (Paytone One Regular). Register `PaytoneOne-Regular.ttf` under `UIAppFonts`.
enum AppTypography {
    /// PostScript name from the embedded TTF (must match font metadata).
    static let paytonePostScriptName = "PaytoneOne-Regular"

    static func paytone(size: CGFloat) -> Font {
        Font.custom(paytonePostScriptName, size: size)
    }

    static var largeTitle: Font { paytone(size: 34) }
    static var title: Font { paytone(size: 28) }
    static var title2: Font { paytone(size: 22) }
    static var title3: Font { paytone(size: 20) }
    static var headline: Font { paytone(size: 17) }
    static var body: Font { paytone(size: 17) }
    static var callout: Font { paytone(size: 16) }
    static var subheadline: Font { paytone(size: 15) }
    static var footnote: Font { paytone(size: 13) }
    static var caption: Font { paytone(size: 12) }
    static var caption2: Font { paytone(size: 11) }
    /// Tab bar item titles
    static var tabBar: Font { paytone(size: 10) }
}

#if canImport(UIKit)
import UIKit

extension AppTypography {
    static func uiFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        UIFont(name: paytonePostScriptName, size: size)
            ?? .systemFont(ofSize: size, weight: weight)
    }

    static func applyPaytoneTabBarTitles(appearance: UITabBarAppearance, titleColor: UIColor = .label) {
        let font = uiFont(size: 10)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: titleColor]
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = attrs
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = attrs
        appearance.inlineLayoutAppearance.normal.titleTextAttributes = attrs
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = attrs
        appearance.compactInlineLayoutAppearance.normal.titleTextAttributes = attrs
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = attrs
    }
}
#endif
