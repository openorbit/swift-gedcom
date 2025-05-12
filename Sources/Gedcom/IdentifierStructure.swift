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

public class REFN : RecordProtocol {
  public var refn: String = ""
  public var type: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TYPE" : \REFN.type,
  ]

  required init(record: Record) throws {
    self.refn = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<REFN, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record? {
    return nil
  }
}

public class UID : RecordProtocol {
  public var uid: UUID

  required init(record: Record) throws {
    self.uid = UUID(uuidString: record.line.value ?? "") ?? UUID()
  }

  func export() -> Record? {
    return nil
  }
}

public class EXID : RecordProtocol {
  public var exid: String = ""
  public var type: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TYPE" : \EXID.type,
  ]

  required init(record: Record) throws {
    self.exid = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<EXID, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }


  func export() -> Record? {
    return nil
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

  func export() -> Record? {
    return nil
  }
}

