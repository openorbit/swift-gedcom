//
// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Mattias Holm
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

public enum GedcomAgeBound: String, Codable, Equatable {
  case lessThan = "<"
  case greaterThan = ">"
}

public struct GedcomAgeDuration: Codable, Equatable {
  public let years: Int?
  public let months: Int?
  public let weeks: Int?
  public let days: Int?

  public init(years: Int? = nil, months: Int? = nil, weeks: Int? = nil, days: Int? = nil) {
    self.years = years
    self.months = months
    self.weeks = weeks
    self.days = days
  }
}

public struct GedcomAge: Codable, Equatable {
  public let bound: GedcomAgeBound?
  public let duration: GedcomAgeDuration?

  public init(bound: GedcomAgeBound? = nil, duration: GedcomAgeDuration? = nil) {
    self.bound = bound
    self.duration = duration
  }

  public var isEmpty: Bool {
    bound == nil && duration == nil
  }
}

public enum GedcomAgeParser {
  public static func parse(_ raw: String) -> GedcomAge? {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
      return GedcomAge()
    }

    var tokens = trimmed.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
    var bound: GedcomAgeBound?

    if let first = tokens.first, let parsedBound = GedcomAgeBound(rawValue: first) {
      bound = parsedBound
      tokens.removeFirst()
    }

    guard !tokens.isEmpty else { return nil }

    var years: Int?
    var months: Int?
    var weeks: Int?
    var days: Int?
    var lastUnitOrder = 0

    for token in tokens {
      guard let unit = token.last else { return nil }
      let valueText = token.dropLast()
      guard !valueText.isEmpty, valueText.allSatisfy({ $0 >= "0" && $0 <= "9" }), let value = Int(valueText) else {
        return nil
      }

      let unitOrder: Int
      switch unit {
      case "y":
        guard years == nil else { return nil }
        years = value
        unitOrder = 1
      case "m":
        guard months == nil else { return nil }
        months = value
        unitOrder = 2
      case "w":
        guard weeks == nil else { return nil }
        weeks = value
        unitOrder = 3
      case "d":
        guard days == nil else { return nil }
        days = value
        unitOrder = 4
      default:
        return nil
      }

      guard unitOrder > lastUnitOrder else { return nil }
      lastUnitOrder = unitOrder
    }

    return GedcomAge(bound: bound, duration: GedcomAgeDuration(years: years, months: months, weeks: weeks, days: days))
  }
}
