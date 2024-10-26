//
//  QuoteFrequencyOptionEnum.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-10-25.
//

import Foundation
import Combine

enum QuoteFrequencyOption: String, CaseIterable {
    case eightHours = "8 hours"
    case twelveHours = "12 hours"
    case oneDay = "1 day"
    case twoDays = "2 days"
    case fourDays = "4 days"
    case oneWeek = "1 week"

    var displayName: String {
        switch self {
            case .oneDay:
                return "day"
            case .oneWeek:
                return "week"
            default:
                return self.rawValue
        }
    }
}
