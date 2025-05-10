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

public class Gedc : RecordProtocol {
  required init(record: Record) throws {
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Gedc, String> {
        guard let value = child.line.value else {
          throw GedcomError.badRecord
        }
        mutableSelf[keyPath: wkp] = value
      }
    }
  }

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "VERS" : \Gedc.vers,
  ]
  public var vers: String = ""
}

public class Schema : RecordProtocol {
  required init(record: Record) throws {
    var mutableSelf = self

  }
  
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TAG" : \Schema.tags,
  ]
  public var tags: [String] = []
}

public class HeadSource : RecordProtocol {
  required init(record: Record) throws {
    var mutableSelf = self

  }
  
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TAG" : \Schema.tags,
  ]
  public var tags: [String] = []
}

public class Header : RecordProtocol {
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "GEDC" : \Header.gedc,
    "SCMA" : \Header.schema,
    "SOUR" : \Header.source,

    // "DEST"
    // "DATE"
    // "SUBM"
    "COPR" : \Header.copr,
    "LANG" : \Header.lang,
    // "PLAC"
    "NOTE" : \Header.note
  ]
  public var gedc: Gedc?
  public var schema : Schema?
  public var source: HeadSource?

  public var copr: String?
  public var lang: String?

  public var note: Note?

  required init(record: Record) throws {
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Header, Gedc?> {
        mutableSelf[keyPath: wkp] = try Gedc(record: child)
      } else if let wkp = kp as? WritableKeyPath<Header, Schema?> {
      } else if let wkp = kp as? WritableKeyPath<Header, HeadSource?> {
      } else if let wkp = kp as? WritableKeyPath<Header, String?> {
        mutableSelf[keyPath: wkp] = child.line.value
      } else if let wkp = kp as? WritableKeyPath<Header, Note?> {
      }
    }
  }
}

