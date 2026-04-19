//
//  ColorExtension.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import SwiftUI
import UIKit

/// Extension for custom app colors
extension Color {
    // MARK: - Primary Colors
    static let appBlue = Color(red: 0.0, green: 0.48, blue: 1.0)
    static let appGreen = Color(red: 0.2, green: 0.8, blue: 0.4)
    static let appRed = Color(red: 1.0, green: 0.2, blue: 0.3)
    static let appOrange = Color(red: 1.0, green: 0.6, blue: 0.0)
    static let appPurple = Color(red: 0.7, green: 0.3, blue: 1.0)
    
    // MARK: - Neutral Colors
    static let appDark = Color(red: 0.1, green: 0.1, blue: 0.1)
    static let appLight = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let appGray = Color(red: 0.5, green: 0.5, blue: 0.5)
    
    // MARK: - Semantic Colors
    static let success = appGreen
    static let warning = appOrange
    static let error = appRed
    static let info = appBlue
    
    // MARK: - Background Colors
    static let background = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor.black : UIColor.white
    })
    
    static let secondaryBackground = Color(UIColor { traitCollection in
        traitCollection.userInterfaceStyle == .dark ? UIColor(white: 0.1, alpha: 1) : UIColor(white: 0.95, alpha: 1)
    })

    init?(hex: String) {
        let formatted = hex.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "#", with: "")
        guard formatted.count == 6, let rgb = UInt64(formatted, radix: 16) else { return nil }
        let r = Double((rgb & 0xFF0000) >> 16) / 255
        let g = Double((rgb & 0x00FF00) >> 8) / 255
        let b = Double(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b)
    }

    var hexString: String? {
        let uiColor = UIColor(self)
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return String(format: "#%02lX%02lX%02lX", lround(Double(r * 255)), lround(Double(g * 255)), lround(Double(b * 255)))
    }

    func adjusted(saturation saturationFactor: CGFloat = 1, brightness brightnessFactor: CGFloat = 1, alpha: CGFloat = 1) -> Color {
        let uiColor = UIColor(self)
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        guard uiColor.getHue(&h, saturation: &s, brightness: &b, alpha: &a) else {
            return self.opacity(alpha)
        }

        let adjustedSaturation = min(max(s * saturationFactor, 0), 1)
        let adjustedBrightness = min(max(b * brightnessFactor, 0), 1)
        return Color(
            hue: Double(h),
            saturation: Double(adjustedSaturation),
            brightness: Double(adjustedBrightness),
            opacity: Double(alpha)
        )
    }
}
