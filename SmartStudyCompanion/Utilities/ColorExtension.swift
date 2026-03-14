//
//  ColorExtension.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import SwiftUI

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
}
