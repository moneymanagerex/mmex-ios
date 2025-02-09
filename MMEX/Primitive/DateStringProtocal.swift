//
//  DateStringProtocal.swift
//  MMEX
//
//  2024-09-22: Created by George Ef (george.a.ef@gmail.com)
//

import Foundation

protocol DateStringProtocal: Codable {
    var string  : String { get set }
    static var formatter: DateFormatter { get }
    init(string: String)
}

extension DateStringProtocal {
    init(_ string: String) {
        self.init(string: string)
    }

    init(_ date: Date) {
        self.init(string: Self.dateToString(date))
    }

    init(_ optDate: Date?) {
        self.init(string: Self.optDateToString(optDate))
    }

    static func dateToString(_ date: Date) -> String {
        Self.formatter.string(from: date)
    }

    static func optDateToString(_ optDate: Date?) -> String {
        if let date = optDate { dateToString(date) } else { "" }
    }

    static func stringToOptDate(_ string: String) -> Date? {
        if !string.isEmpty { Self.formatter.date(from: string) } else { nil }
    }

    static func stringToDate(_ string: String) -> Date {
        stringToOptDate(string) ?? Date()
    }

    var date: Date {
        get { Self.stringToDate(self.string) }
        set { self.string = Self.dateToString(newValue) }
    }
    var optDate: Date? {
        get { Self.stringToOptDate(self.string) }
        set { self.string = Self.optDateToString(newValue) }
    }
}

struct DateString: DateStringProtocal {
    var string: String

    static var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }
}

struct DateTimeString: DateStringProtocal {
    var string: String

    static var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return df
    }
}

struct TimestampString: DateStringProtocal {
    var string: String

    static var formatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmssSSS"
        return df
    }
}

extension Date {
    func daysAgo(_ days: Int) -> Date? {
        return Calendar.current.date(byAdding: .day, value: -days, to: self)
    }

    func weeksAgo(_ weeks: Int) -> Date? {
        return Calendar.current.date(byAdding: .weekOfYear, value: -weeks, to: self)
    }
}
