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

/// Errors that can occur when parsing a GEDCOM 7 PersonalName.
public enum GedcomNameError: Error, CustomStringConvertible, Equatable {
  case empty
  case invalidSlashCount(Int)

  public var description: String {
    switch self {
    case .empty: return "PersonalName must contain at least one character."
    case .invalidSlashCount(let n):
      return "PersonalName may have either 0 or exactly 2 slashes; found \(n)."
    }
  }
}

/// Parsed representation of a GEDCOM 7 PersonalName payload.
/// See GEDCOM 7 §2.8 Personal Name (g7:type-Name).
public struct GedcomPersonalName: Equatable, Codable {
  /// Original payload, unchanged.
  public let raw: String

  /// Portion before the first slash (if present and non-empty), trimmed of outer spaces.
  public let beforeSurname: String?
  /// Portion delimited by slashes (if present and non-empty), trimmed of outer spaces.
  public let surname: String?
  /// Portion after the second slash (if present and non-empty), trimmed of outer spaces.
  public let afterSurname: String?

  /// True if the payload used the slash form.
  public var usesSlashForm: Bool { slashCount == 2 }

  /// Reconstruct a canonical GEDCOM PersonalName string.
  /// - Note: Preserves the three-part structure if originally present; otherwise returns `rawTrimmed`.
  public func serialize() -> String {
    if usesSlashForm {
      return "\(beforeSurname ?? "")/\(surname ?? "")/\(afterSurname ?? "")"
        .trimmingCharacters(in: .whitespaces)
    } else {
      return rawTrimmed
    }
  }

  /// Initialize from raw string (GEDCOM payload).
  /// Will parse components or throw if invalid.
  public init(raw: String) {
    self = GedcomPersonalNameParser.parse(raw)
  }

  /// Initialize from components.
  /// - Parameters:
  ///   - beforeSurname: Optional given names, prefixes, etc.
  ///   - surname: Optional surname string.
  ///   - afterSurname: Optional suffix string.
  /// - Note: If `surname` is nil, this will produce a raw string without slashes.
  public init(beforeSurname: String? = nil,
              surname: String? = nil,
              afterSurname: String? = nil) {
    self.beforeSurname = beforeSurname?.trimmedOrNil()
    self.surname = surname?.trimmedOrNil()
    self.afterSurname = afterSurname?.trimmedOrNil()

    if let s = self.surname {
      // Slash form
      self.slashCount = 2
      let rawBuilt = "\(self.beforeSurname ?? "")/\(s)/\(self.afterSurname ?? "")"
      self.rawTrimmed = rawBuilt.trimmingCharacters(in: .whitespaces)
      self.raw = rawBuilt
    } else {
      // Free-text form
      self.slashCount = 0
      let rawBuilt = (self.beforeSurname ?? "") + (self.afterSurname ?? "")
      self.rawTrimmed = rawBuilt.trimmingCharacters(in: .whitespaces)
      self.raw = rawBuilt
    }
  }

  fileprivate init(raw: String,
                   beforeSurname: String?,
                   surname: String?,
                   afterSurname: String?,
                   slashCount: Int,
                   rawTrimmed: String) {
    self.raw = raw
    self.beforeSurname = beforeSurname
    self.surname = surname
    self.afterSurname = afterSurname
    self.slashCount = slashCount
    self.rawTrimmed = rawTrimmed
  }


  let slashCount: Int
  let rawTrimmed: String
}

/// Parser/validator per GEDCOM 7 §2.8.
public enum GedcomPersonalNameParser {

  /// Parse a GEDCOM 7 PersonalName payload.
  /// - Parameter s: The raw payload string from a `NAME` line.
  /// - Returns: A validated, structured `GedcomPersonalName`.
  public static func parse(_ s: String) -> GedcomPersonalName {
    let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)

    guard !trimmed.isEmpty else {
      return GedcomPersonalName(raw: s,
                                beforeSurname: nil,
                                surname: nil,
                                afterSurname: nil,
                                slashCount: 0,
                                rawTrimmed: trimmed)
    }

    let slashIndices = trimmed.indicesOf(character: "/")
    let slashCount = slashIndices.count

    switch slashCount {
    case 0:
      // Free-text personal name (no explicit surname slice).
      return GedcomPersonalName(
        raw: s,
        beforeSurname: nil,
        surname: nil,
        afterSurname: nil,
        slashCount: 0,
        rawTrimmed: trimmed
      )

    case 2:
      // Three-part form: [before] "/" [surname] "/" [after]
      let parts = trimmed.split(separator: "/", maxSplits: 2, omittingEmptySubsequences: false)
      // Guaranteed 3 parts because we had exactly 2 slashes and we didn't omit empties
      let before = parts[0].trimmedOrNil()
      let between = parts[1].trimmedOrNil()
      let after = parts[2].trimmedOrNil()

      // At least one of the components must be non-empty overall (the input is non-empty already).
      return GedcomPersonalName(
        raw: s,
        beforeSurname: before,
        surname: between,
        afterSurname: after,
        slashCount: 2,
        rawTrimmed: trimmed
      )

    default:
      // GEDCOM 7 ABNF only allows 0 or exactly 2 slashes in PersonalName.
      // However, to allow more gedcom to be parsed we ignore this
      // and simply create a raw value.
      return GedcomPersonalName(raw: s,
                                beforeSurname: nil,
                                surname: nil,
                                afterSurname: nil,
                                slashCount: slashCount,
                                rawTrimmed: trimmed)
    }
  }
}

fileprivate extension StringProtocol {
  func trimmedOrNil() -> String? {
    let t = trimmingCharacters(in: .whitespaces)
    return t.isEmpty ? nil : t
  }
}

fileprivate extension String {
  func indicesOf(character: Character) -> [String.Index] {
    var idxs: [String.Index] = []
    var i = startIndex
    while i < endIndex {
      if self[i] == character { idxs.append(i) }
      i = index(after: i)
    }
    return idxs
  }
}
