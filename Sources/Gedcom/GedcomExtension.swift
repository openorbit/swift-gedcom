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

import Foundation

public struct GedcomExtensionNode: Codable, Equatable {
  public var level: Int
  public var xref: String?
  public var tag: String
  public var value: String?
  public var children: [GedcomExtensionNode]

  public init(level: Int = 0,
              xref: String? = nil,
              tag: String,
              value: String? = nil,
              children: [GedcomExtensionNode] = []) {
    self.level = level
    self.xref = xref
    self.tag = tag
    self.value = value
    self.children = children
  }

  init(record: Record) {
    self.level = record.line.level
    self.xref = record.line.xref
    self.tag = record.line.tag
    self.value = record.line.value
    self.children = record.children.map(GedcomExtensionNode.init(record:))
  }

  func export() -> Record {
    let record = Record(level: level, xref: xref, tag: tag, value: value)
    record.children = children.map { $0.export() }
    return record
  }

  public var extensionTags: Set<String> {
    var tags = tag.hasPrefix("_") ? Set([tag]) : Set<String>()
    for child in children {
      tags.formUnion(child.extensionTags)
    }
    return tags
  }

  public var flattened: [GedcomExtensionNode] {
    [self] + children.flatMap(\.flattened)
  }
}

public protocol GedcomExtensionContainer {
  var extensions: [GedcomExtensionNode] { get set }
}

public extension GedcomExtensionContainer {
  func extensions(tag: String) -> [GedcomExtensionNode] {
    extensions.filter { $0.tag == tag }
  }

  func firstExtension(tag: String) -> GedcomExtensionNode? {
    extensions.first { $0.tag == tag }
  }

  var extensionTags: Set<String> {
    extensions.reduce(into: Set<String>()) { tags, node in
      tags.formUnion(node.extensionTags)
    }
  }
}

public enum GedcomExtensionURI {
  public static let synthesizedBase = "https://openorbit.org/gedcom/extensions"

  public static func synthesized(tag: String, source: String?) -> URL {
    let slug = source.flatMap(vendorSlug)
    let namespace = slug.map { "vendor-\($0)" } ?? "unknown"
    return URL(string: "\(synthesizedBase)/\(namespace)/\(tag)")!
  }

  public static func vendorSlug(from source: String) -> String? {
    let lowercased = source.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    var result = ""
    var previousWasSeparator = false

    for scalar in lowercased.unicodeScalars {
      let value = scalar.value
      let isLetter = value >= 97 && value <= 122
      let isDigit = value >= 48 && value <= 57

      if isLetter || isDigit {
        result.unicodeScalars.append(scalar)
        previousWasSeparator = false
      } else if !previousWasSeparator && !result.isEmpty {
        result.append("-")
        previousWasSeparator = true
      }
    }

    while result.last == "-" {
      result.removeLast()
    }

    return result.isEmpty ? nil : result
  }
}
