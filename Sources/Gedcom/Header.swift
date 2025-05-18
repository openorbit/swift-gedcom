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
  public var vers: String = "7.0"

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "VERS" : \Gedc.vers,
  ]
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

  func export() -> Record {
    let record = Record(level: 0, tag: "GEDC")
    record.children.append(Record(level: 1, tag: "VERS", value: vers))
    return record
  }
}


public class Schema : RecordProtocol {
  public var tags: [String: URL] = [:]
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TAG" : \Schema.tags,
  ]

  init() {}

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

  func export() -> Record {
    let record = Record(level: 0, tag: "SCHMA")
    for key in tags.keys.sorted() {
      record.children.append(Record(level: 1, tag: "TAG", value: key + " " + tags[key]!.absoluteString))
    }
    return record
  }
}


public class HeaderPlace : RecordProtocol {
  public var form: [String] = []
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "FORM" : \HeaderPlace.form,
  ]

  init(form: [String]) {
    self.form = form
  }
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

  func export() -> Record {
    let record = Record(level: 0, tag: "PLAC")
    let formString = form.reduce("") { (acc, token) in
      return acc + ((acc.count > 1) ? ", " : "") + token
    }
    record.children.append(Record(level: 1, tag: "FORM", value: formString))
    return record
  }
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

  init(corp: String) {
    corporation = corp
  }
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

  func export() -> Record {
    let record = Record(level: 0, tag: "CORP", value: corporation)

    if let address = address {
      let child = address.export()
      record.children.append(child)
    }

    for phone in phone {
      record.children.append(Record(level: 1, tag: "PHON", value: phone))
    }
    for email in email {
      record.children.append(Record(level: 1, tag: "EMAIL", value: email))
    }
    for fax in fax {
      record.children.append(Record(level: 1, tag: "FAX", value: fax))
    }
    for www in www {
      record.children.append(Record(level: 1, tag: "WWW", value: www.absoluteString))
    }
    return record
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

  init(data: String) {
    self.data = data
  }

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

  func export() -> Record {
    let record = Record(level: 0, tag: "DATA", value: data)

    if let date = date {
      let exportedDate = date.export()
      record.children.append(exportedDate)
    }

    if let copyright {
      let copyrightRecord = Record(level: 1, tag: "COPR", value: copyright)
      record.children.append(copyrightRecord)
    }
    return record
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

  init(source: String) {
    self.source = source
  }

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

  func export() -> Record {
    let record = Record(level: 0, tag: "SOUR", value: source)

    if let version = version {
      record.children.append(Record(level: 1, tag: "VERS", value: version))
    }
    if let name = name {
      record.children.append(Record(level: 1, tag: "NAME", value: name))
    }

    if let corporation = corporation {
      let child = corporation.export()
      record.children.append(child)
    }
    if let data = data {
      let child = data.export()
      record.children.append(child)
    }
    return record
  }
}

public class Header : RecordProtocol {
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

  func export() -> Record {
    let record = Record(level: 0, tag: "HEAD")

    record.children.append(gedc.export())

    if let schema {
      let child = schema.export()
      record.children.append(child)
    }

    if let source {
      let child = source.export()
      record.children.append(child)
    }

    if let destination {
      record.children.append(Record(level: 1, tag: "DEST", value: destination))
    }

    if let date {
      let child = date.export()
      record.children.append(child)
    }

    if let submitter {
      record.children.append(Record(level: 1, tag: "SUBM", value: submitter))
    }
    if let copyright {
      record.children.append(Record(level: 1, tag: "COPR", value: copyright))
    }
    if let lang {
      record.children.append(Record(level: 1, tag: "LANG", value: lang))
    }

    if let place {
      let child = place.export()
      record.children.append(child)
    }

    if let note {
      let note = note.export()
      record.children.append(note)
    }

    record.setLevel(0)
    return record
  }
}

