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
public class Gedc : RecordProtocol {
  init() {

  }
  required init(record: Record) throws {
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Gedc, String> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "VERS" : \Gedc.vers,
  ]
  public var vers: String = ""
}


public class Schema : RecordProtocol {
  var tags: [String: URL] = [:]
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TAG" : \Schema.tags,
  ]

  required init(record: Record) throws {
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Schema, [String: URL]> {
        let keyValue = child.line.value?.components(separatedBy: " ").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)}) ?? []
        guard keyValue.count == 2 else {
          throw GedcomError.badSchema
        }
        guard let url = URL(string: keyValue[1]) else {
          throw GedcomError.badSchema
        }
        guard !mutableSelf[keyPath: wkp].keys.contains(keyValue[0]) else {
          throw GedcomError.badSchema
        }
        guard keyValue[0].starts(with: "_") else {
          throw GedcomError.badSchema
        }
        mutableSelf[keyPath: wkp][keyValue[0]] = url
      }
    }
  }
}


public class HeaderPlace : RecordProtocol {
  required init(record: Record) throws {
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<HeaderPlace, [String]> {
        mutableSelf[keyPath: wkp] = (child.line.value ?? "")
          .components(separatedBy: ",")
          .map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
      }
    }
  }

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "FORM" : \HeaderPlace.form,
  ]
  public var form: [String] = []
}

public class HeaderSourceCorporation : RecordProtocol {
  public var corporation: String = ""
  public var address: AddressStructure?
  public var phone: [String] = []
  public var email: [String] = []
  public var fax: [String] = []
  public var www: [URL] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "ADDR" : \HeaderSourceCorporation.address,
    "PHON" : \HeaderSourceCorporation.phone,
    "EMAIL" : \HeaderSourceCorporation.email,
    "FAX" : \HeaderSourceCorporation.fax,
    "WWW" : \HeaderSourceCorporation.www,
  ]

  required init(record: Record) throws {
    corporation = record.line.value ?? ""
    var mutableSelf = self


    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<HeaderSourceCorporation, [String]> {
        mutableSelf[keyPath: wkp].append(child.line.value ?? "")
      } else if let wkp = kp as? WritableKeyPath<HeaderSourceCorporation, AddressStructure?> {
        mutableSelf[keyPath: wkp] = try AddressStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<HeaderSourceCorporation, [URL]> {
        try mutableSelf[keyPath: wkp].append(URL(string: child.line.value ?? "") ?? { throw GedcomError.badURL } ())
      }
    }
  }
}

public class HeaderSourceData : RecordProtocol {
  public var data: String = ""
  public var date: DateTimeExact?
  public var copyright: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATE" : \HeaderSourceData.date,
    "COPR" : \HeaderSourceData.copyright,
  ]

  required init(record: Record) throws {
    data = record.line.value ?? ""
    var mutableSelf = self


    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<HeaderSourceData, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else       if let wkp = kp as? WritableKeyPath<HeaderSourceData, DateTimeExact?> {
        mutableSelf[keyPath: wkp] = try DateTimeExact(record: child)
      }
    }
  }
}

public class HeaderSource : RecordProtocol {
  public var source: String = ""
  public var version: String?
  public var name: String?
  public var corporation: HeaderSourceCorporation?
  public var data: HeaderSourceData?
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "VERS" : \HeaderSource.version,
    "NAME" : \HeaderSource.name,
    "CORP" : \HeaderSource.corporation,
    "DATA" : \HeaderSource.data,
  ]

  required init(record: Record) throws {
    source = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<HeaderSource, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<HeaderSource, HeaderSourceData?> {
        mutableSelf[keyPath: wkp] = try HeaderSourceData(record: child)
      } else if let wkp = kp as? WritableKeyPath<HeaderSource, HeaderSourceCorporation?> {
        mutableSelf[keyPath: wkp] = try HeaderSourceCorporation(record: child)
      }
    }
  }
}

public class Header : RecordProtocol {
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "GEDC" : \Header.gedc,
    "SCHMA" : \Header.schema,
    "SOUR" : \Header.source,

    "DEST" : \Header.destination,
    "DATE" : \Header.date,

    "SUBM" : \Header.submitter,
    "COPR" : \Header.copyright,
    "LANG" : \Header.lang,
    "PLAC" : \Header.place,
    "NOTE" : \Header.note,
    "SOTE" : \Header.note,
  ]
  public var gedc: Gedc
  public var schema : Schema?
  public var source: HeaderSource?
  public var date: DateTimeExact?
  public var destination: String?

  public var place: HeaderPlace?
  public var copyright: String?
  public var lang: String?
  public var submitter: String?
  public var note: NoteStructure?

  init() {
    gedc = Gedc()
  }
  required init(record: Record) throws {
    gedc = Gedc()
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Header, Gedc> {
        mutableSelf[keyPath: wkp] = try Gedc(record: child)
      } else if let wkp = kp as? WritableKeyPath<Header, Schema?> {
        mutableSelf[keyPath: wkp] = try Schema(record: child)
      } else if let wkp = kp as? WritableKeyPath<Header, HeaderSource?> {
        mutableSelf[keyPath: wkp] = try HeaderSource(record: child)
      } else if let wkp = kp as? WritableKeyPath<Header, HeaderPlace?> {
        mutableSelf[keyPath: wkp] = try HeaderPlace(record: child)
      } else if let wkp = kp as? WritableKeyPath<Header, String?> {
        mutableSelf[keyPath: wkp] = child.line.value
      } else if let wkp = kp as? WritableKeyPath<Header, DateTimeExact?> {
        mutableSelf[keyPath: wkp] = try DateTimeExact(record: child)
      } else if let wkp = kp as? WritableKeyPath<Header, NoteStructure?> {
        mutableSelf[keyPath: wkp] = try NoteStructure(record: child)
      }
    }
  }
}

