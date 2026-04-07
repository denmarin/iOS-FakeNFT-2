import UIKit

enum CatalogColors {
    static let screenBackground = UIColor.whiteUniversal
    static let textPrimary = UIColor.blackUniversal
    static let textSecondary = UIColor.greyUniversal
    static let link = UIColor.blueUniversal

    static let imagePlaceholderBackground = UIColor.greyUniversal.withAlphaComponent(0.12)
    static let overlayStrong = UIColor.blackUniversal.withAlphaComponent(0.08)
    static let overlaySoft = UIColor.blackUniversal.withAlphaComponent(0.06)

    static func applyCoverPlaceholder(to views: [UIView], seed: String) {
        let palette = placeholderPalette(seed: seed)
        zip(views, palette).forEach { view, color in
            view.backgroundColor = color
        }
    }

    private static func placeholderPalette(seed: String) -> [UIColor] {
        let base: [UIColor] = [
            UIColor.greyUniversal.withAlphaComponent(0.12),
            .whiteUniversal,
            UIColor.greyUniversal.withAlphaComponent(0.08)
        ]
        let offset = abs(seed.hashValue) % base.count
        return (0..<3).map { index in
            base[(index + offset) % base.count]
        }
    }
}
