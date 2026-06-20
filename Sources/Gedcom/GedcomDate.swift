//
// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2025 Mattias Holm
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

public enum GedcomDateCalendar: String, Codable {
    case gregorian = "GREG"
    case julian = "JULI"
    case hebrew = "HEBR"
    case french = "FRENCH" // @#DFRENCH R@
    case roman = "ROMAN"   // User extension example? Standards vary.
    case unknown = "UNKNOWN"
}

public struct GedcomSimpleDate: Codable, Equatable {
    public let calendar: GedcomDateCalendar
    public let year: Int?
    public let month: String?
    public let day: Int?
    public let epoch: String? // BC, BCE...

    public init(calendar: GedcomDateCalendar = .gregorian, year: Int? = nil, month: String? = nil, day: Int? = nil, epoch: String? = nil) {
        self.calendar = calendar
        self.year = year
        self.month = month
        self.day = day
        self.epoch = epoch
    }
}

public enum GedcomDate: Codable, Equatable {
    case exact(GedcomSimpleDate)
    case approx(kind: ApproxKind, date: GedcomSimpleDate)
    case between(start: GedcomSimpleDate, end: GedcomSimpleDate)
    case range(start: GedcomSimpleDate?, end: GedcomSimpleDate?) // FROM.. or TO.. or FROM..TO..
    case phrase(String)
    
    public enum ApproxKind: String, Codable {
        case about = "ABT"
        case calculated = "CAL"
        case estimated = "EST"
    }
}

public enum GedcomDateParser {
    public static func parse(_ raw: String) -> GedcomDate? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }
        if trimmed.hasPrefix("(") && trimmed.hasSuffix(")") {
            return .phrase(String(trimmed.dropFirst().dropLast()))
        }
        
        let upper = trimmed.uppercased()
        let parts = upper.components(separatedBy: .whitespaces) // Simple tokenization

        // Check Range Keywords
        if parts.first == "BET" {
            // Expect BET <Date> AND <Date>
            if let andIndex = parts.firstIndex(of: "AND") {
                let startStr = parts[1..<andIndex].joined(separator: " ")
                let endStr = parts[parts.index(after: andIndex)...].joined(separator: " ")
                if let s = parseSimple(startStr), let e = parseSimple(endStr) {
                    return .between(start: s, end: e)
                }
            }
        }
        
        if parts.first == "FROM" {
            // FROM <Date> [TO <Date>]
            if let toIndex = parts.firstIndex(of: "TO") {
                let startStr = parts[1..<toIndex].joined(separator: " ")
                let endStr = parts[parts.index(after: toIndex)...].joined(separator: " ")
                let s = parseSimple(startStr)
                let e = parseSimple(endStr)
                if s != nil || e != nil {
                     // FROM X TO Y
                     // If one is missing, it's still a range? strict G7 says "FROM <Date> TO <Date>" is RangePeriod.
                     // But "FROM <Date>" is also valid.
                     return .range(start: s, end: e)
                }
            } else {
                // FROM <Date>
                let startStr = parts.dropFirst().joined(separator: " ")
                if let s = parseSimple(startStr) {
                    return .range(start: s, end: nil)
                }
            }
        }
        
        if parts.first == "TO" {
            let endStr = parts.dropFirst().joined(separator: " ")
            if let e = parseSimple(endStr) {
                return .range(start: nil, end: e)
            }
        }
        
        // Approx
        if let k = GedcomDate.ApproxKind(rawValue: parts.first ?? "") {
            let dateStr = parts.dropFirst().joined(separator: " ")
            if let d = parseSimple(dateStr) {
                return .approx(kind: k, date: d)
            }
        }
        
        // Exact
        if let d = parseSimple(upper) {
            return .exact(d)
        }
        
        return nil
    }
    
    // Parses: [Escape] [Day] Month Year [Epoch]
    private static func parseSimple(_ raw: String) -> GedcomSimpleDate? {
        var tokens = raw.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if tokens.isEmpty { return nil }
        
        var calendar: GedcomDateCalendar = .gregorian
        
        // Check calendar escape
        if let first = tokens.first, first.hasPrefix("@#"), first.hasSuffix("@") {
            // @#DHEBREW@
            if first.contains("HEBR") { calendar = .hebrew }
            else if first.contains("FRENCH") { calendar = .french }
            else if first.contains("JULI") { calendar = .julian } // Sometimes GREG/JULI are explicitly set? G7 uses @#DHEBREW@ etc. Standard Gregorian is default.
            else { calendar = .unknown } // or roman
            tokens.removeFirst()
        }
        
        // Epoch at end?
        var epoch: String? = nil
        if let last = tokens.last, (last == "BC" || last == "BCE" || last == "B.C.") {
            epoch = last
            tokens.removeLast()
        }
        
        // Format: Day Month Year or Month Year or Year
        // Day is digits. Month is String (or digits in some loose impls, but G7 struct is text).
        // Year is digits (or double dating 1600/01).
        
        var day: Int? = nil
        var month: String? = nil
        var year: Int? = nil
        
        if tokens.isEmpty { return nil }
        
        // Try parsing first token as Day (digits)
        if let d = Int(tokens[0]) {
            day = d
            tokens.removeFirst()
        }
        
        if tokens.isEmpty {
            // Just a Day? Invalid. "Year" is mandatory in simple date?
            // "Date := [Day] Month Year" or just "Year"?
            // GEDCOM allow: "MAY 1990" or "1990".
            // If tokens[0] was 1990, we assigned it to `day`. Oops.
            if let d = day, d > 31 {
                 // Likely a year
                 year = d
                 day = nil
            }
        }
        
        // Next token: Month?
        if !tokens.isEmpty {
            let t = tokens[0]
            // If it's alphanumeric and not digits
            if Int(t) == nil {
                month = t
                tokens.removeFirst()
            }
        }
        
        // Next token: Year?
        if !tokens.isEmpty {
            let t = tokens[0]
            if let y = Int(t) {
                year = y
                tokens.removeFirst()
            }
        }
        
        // Re-evaluate logic if Year was missing but we parsed a Day that looks like Year
        if year == nil && day != nil && day! > 1000 && month == nil {
            year = day
            day = nil
        }
        
        // Minimal valid date must have Year or Month+Year?
        // Actually, just Year is valid.
        if year != nil || (month != nil) {
            return GedcomSimpleDate(calendar: calendar, year: year, month: month, day: day, epoch: epoch)
        }
        
        return nil
    }
}
