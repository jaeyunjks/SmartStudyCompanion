import Foundation
import SwiftUI

enum StudySpaceStatus: String, Codable, CaseIterable, Hashable, Identifiable {
    case active = "Active"
    case inactive = "Inactive"

    var id: String { rawValue }

    init(normalizing rawValue: String?) {
        let trimmed = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ?? ""
        switch trimmed {
        case "inactive":
            self = .inactive
        default:
            self = .active
        }
    }

    var displayName: String {
        rawValue
    }

    var foregroundColor: Color {
        switch self {
        case .inactive:
            return Color(red: 0.76, green: 0.25, blue: 0.30)
        case .active:
            return Color(red: 0.22, green: 0.58, blue: 0.38)
        }
    }

    var backgroundColor: Color {
        foregroundColor.opacity(0.14)
    }
}

enum StudySpaceFilterStatus: String, Codable, CaseIterable, Hashable, Identifiable {
    case all = "All"
    case active = "Active"
    case inactive = "Inactive"

    var id: String { rawValue }

    var displayName: String {
        rawValue
    }

    func matches(_ status: StudySpaceStatus) -> Bool {
        switch self {
        case .all:
            return true
        case .active:
            return status == .active
        case .inactive:
            return status == .inactive
        }
    }
}

enum LibrarySortOption: String, Codable, CaseIterable, Hashable, Identifiable {
    case recentlyUpdated = "Recently Updated"
    case alphabetical = "Alphabetical"

    var id: String { rawValue }

    var displayName: String {
        rawValue
    }
}
