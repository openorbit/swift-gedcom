//
// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2024 Mattias Holm
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

public class REFN : RecordProtocol, GedcomExtensionContainer {
  public var extensions: [GedcomExtensionNode] = []
  public var refn: String = ""
  public var type: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TYPE" : \REFN.type,
  ]

  init(ident: String, type: String? = nil) {
    self.refn = ident
    self.type = type
  }
  required init(record: Record) throws {
    self.refn = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        extensions.append(GedcomExtensionNode(record: child))
        continue
      }

      if let wkp = kp as? WritableKeyPath<REFN, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "REFN", value: refn)
    if let type {
      record.children.append(Record(level: 1, tag: "TYPE", value: type))
    }
    for node in extensions {
      record.children.append(node.export())
    }
    return record
  }
}

public class UID : RecordProtocol, GedcomExtensionContainer {
  public var extensions: [GedcomExtensionNode] = []
  public var uid: UUID

  init(ident: String) {
    self.uid = UUID(uuidString: ident) ?? UUID()
  }

  required init(record: Record) throws {
    self.uid = UUID(uuidString: record.line.value ?? "") ?? UUID()
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "UID", value: uid.uuidString.lowercased())
    for node in extensions {
      record.children.append(node.export())
    }
    return record
  }
}

public class EXID : RecordProtocol, GedcomExtensionContainer {
  public var extensions: [GedcomExtensionNode] = []
  public var exid: String = ""
  public var type: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TYPE" : \EXID.type,
  ]

  init(ident: String, type: String? = nil) {
    self.exid = ident
    self.type = type
  }

  required init(record: Record) throws {
    self.exid = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        extensions.append(GedcomExtensionNode(record: child))
        continue
      }

      if let wkp = kp as? WritableKeyPath<EXID, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }


  func export() -> Record {
    let record = Record(level: 0, tag: "EXID", value: exid)
    if let type {
      record.children.append(Record(level: 1, tag: "TYPE", value: type))
    }
    for node in extensions {
      record.children.append(node.export())
    }
    return record
  }
}


public enum IdentifierStructure {
  case Refn(REFN)
  case Uuid(UID)
  case Exid(EXID)
}

extension IdentifierStructure : RecordProtocol {
  init(record: Record) throws {
    switch record.line.tag {
    case "REFN":
      self = .Refn(try REFN(record: record))
    case "UID":
      self = .Uuid(try UID(record: record))
    case "EXID":
      self = .Exid(try EXID(record: record))
    default:
      throw GedcomError.badRecord
    }
  }

  func export() -> Record {
    switch self {
    case .Exid(let ident):
      return ident.export()
    case .Refn(let ident):
      return ident.export()
    case .Uuid(let ident):
      return ident.export()
    }
  }
}

