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

public class Submitter : RecordProtocol {
  public var xref: String = ""
  public var name: String = ""
  public var address: AddressStructure?
  public var phone: [String] = []
  public var email: [String] = []
  public var fax: [String] = []
  public var www: [URL] = []
  public var multimediaLinks: [MultimediaLink] = []
  public var languages: [String] = []
  public var identifiers: [IdentifierStructure] = []
  public var notes: [NoteStructure] = []
  public var changeDate: ChangeDate?
  public var creationDate: CreationDate?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "NAME" : \Submitter.name,
    "ADDR" : \Submitter.address,
    "PHON" : \Submitter.phone,
    "EMAIL" : \Submitter.email,
    "FAX" : \Submitter.fax,
    "WWW" : \Submitter.www,
    "OBJE" : \Submitter.multimediaLinks,
    "LANG" : \Submitter.languages,
    "REFN" : \Submitter.identifiers,
    "UID" : \Submitter.identifiers,
    "EXID" : \Submitter.identifiers,
    "NOTE" : \Submitter.notes,
    "SNOTE" : \Submitter.notes,
    "CHAN" : \Submitter.changeDate,
    "CREA" : \Submitter.creationDate
  ]

  init(xref: String, name: String)
  {
    self.xref = xref
    self.name = name
  }
  required init(record: Record) throws {
    xref = record.line.xref!

    var mutableSelf = self
    for child in record.children {

      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Submitter, String> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<Submitter, [String]> {
        mutableSelf[keyPath: wkp].append(child.line.value ?? "")
      } else if let wkp = kp as? WritableKeyPath<Submitter, AddressStructure?> {
        mutableSelf[keyPath: wkp] = try AddressStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<Submitter, [IdentifierStructure]> {
        mutableSelf[keyPath: wkp].append(try IdentifierStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Submitter, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Submitter, [MultimediaLink]> {
        mutableSelf[keyPath: wkp].append(try MultimediaLink(record: child))
      } else if let wkp = kp as? WritableKeyPath<Submitter, [URL]> {
        try mutableSelf[keyPath: wkp].append(URL(string: child.line.value ?? "") ?? { throw GedcomError.badURL } ())
      } else if let wkp = kp as? WritableKeyPath<Submitter, ChangeDate?> {
        mutableSelf[keyPath: wkp] = try ChangeDate(record: child)
      } else if let wkp = kp as? WritableKeyPath<Submitter, CreationDate?> {
        mutableSelf[keyPath: wkp] = try CreationDate(record: child)
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, xref: xref, tag: "SUBM")

    record.children.append(Record(level: 1, tag: "NAME", value: name))

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

    for multimediaLink in multimediaLinks {
      let child = multimediaLink.export()
        record.children.append(child)
    }

    for lang in languages {
      record.children.append(Record(level: 1, tag: "LANG", value: lang))
    }

    for identifier in identifiers {
      let child = identifier.export()
      record.children.append(child)
    }
    for note in notes {
      let child = note.export()
      record.children.append(child)
    }

    if let changeDate {
      let child = changeDate.export()
      record.children.append(child)
    }
    if let creationDate {
      let child = creationDate.export()
      record.children.append(child)
    }

    record.setLevel(0)
    return record
  }
}
