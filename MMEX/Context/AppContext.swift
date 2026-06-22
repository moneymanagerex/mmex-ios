//
//  AppContext.swift
//  MMEX
//
//  Created by Lisheng Guan on 2026/6/22.
//

import SwiftUI
import Combine

enum DateRangePreset: String, ChoiceProtocol {
    case today     = "Today"
    case thisWeek  = "This Week"
    case thisMonth = "This Month"
    case thisYear  = "This Year"
    case all       = "All"
    case custom    = "Custom"
    static let defaultValue = Self.thisMonth
}

class AppContext: ObservableObject {
    static let shared = AppContext()

    @StoredPreference(key: "app.selectedAccountId", wrappedValue: .void) private var _selectedAccountId: DataId
    @StoredPreference(key: "app.dateRangePreset", wrappedValue: .thisMonth) private var _dateRangePreset: DateRangePreset
    @StoredPreference(key: "app.customStartDate", wrappedValue: "") private var _customStartDate: String
    @StoredPreference(key: "app.customEndDate", wrappedValue: "") private var _customEndDate: String

    var selectedAccountId: DataId {
        get { _selectedAccountId }
        set {
            if _selectedAccountId != newValue {
                _selectedAccountId = newValue
                objectWillChange.send()
            }
        }
    }

    var dateRangePreset: DateRangePreset {
        get { _dateRangePreset }
        set {
            if _dateRangePreset != newValue {
                _dateRangePreset = newValue
                objectWillChange.send()
            }
        }
    }

    var customStartDate: String {
        get { _customStartDate }
        set {
            if _customStartDate != newValue {
                _customStartDate = newValue
                objectWillChange.send()
            }
        }
    }

    var customEndDate: String {
        get { _customEndDate }
        set {
            if _customEndDate != newValue {
                _customEndDate = newValue
                objectWillChange.send()
            }
        }
    }

    var effectiveStartDate: Date? {
        switch dateRangePreset {
        case .today:      return Calendar.current.startOfDay(for: Date())
        case .thisWeek:   return Calendar.current.date(byAdding: .day, value: -7, to: Date())
        case .thisMonth:  return Calendar.current.date(byAdding: .month, value: -1, to: Date())
        case .thisYear:   return Calendar.current.date(byAdding: .year, value: -1, to: Date())
        case .all:        return nil
        case .custom:     return DateString(customStartDate).optDate
        }
    }

    var effectiveEndDate: Date? {
        switch dateRangePreset {
        case .today, .thisWeek, .thisMonth, .thisYear: return Date()
        case .all:        return nil
        case .custom:     return DateString(customEndDate).optDate
        }
    }

    var isAllAccounts: Bool { selectedAccountId.isVoid }

    var previousPeriodStart: Date? {
        guard let start = effectiveStartDate else { return nil }
        switch dateRangePreset {
        case .today:
            return Calendar.current.date(byAdding: .day, value: -1, to: start)
        case .thisWeek:
            return Calendar.current.date(byAdding: .day, value: -7, to: start)
        case .thisMonth:
            return Calendar.current.date(byAdding: .month, value: -1, to: start)
        case .thisYear:
            return Calendar.current.date(byAdding: .year, value: -1, to: start)
        default:
            return nil
        }
    }

    var previousPeriodEnd: Date? {
        guard let start = previousPeriodStart else { return nil }
        switch dateRangePreset {
        case .today:
            return start
        case .thisWeek:
            return Calendar.current.date(byAdding: .day, value: 6, to: start)
        case .thisMonth:
            return Calendar.current.date(byAdding: .month, value: 1, to: start)?.addingTimeInterval(-1)
        case .thisYear:
            return Calendar.current.date(byAdding: .year, value: 1, to: start)?.addingTimeInterval(-1)
        default:
            return nil
        }
    }
}
