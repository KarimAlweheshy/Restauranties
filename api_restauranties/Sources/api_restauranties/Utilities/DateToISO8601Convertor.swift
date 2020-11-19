//
//  DateToISO8601Convertor.swift
//  
//
//  Created by Karim Alweheshy on 11/16/20.
//

import Foundation

struct DateToISO8601Convertor {
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    mutating func convert(_ date: Date) -> String {
        formatter.string(from: date)
    }
}
