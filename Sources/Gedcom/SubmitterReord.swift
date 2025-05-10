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
  var xref: String = ""
  var name: String = ""
  var address: AddressStructure?
  var phone: [String] = []
  var email: [String] = []
  var fax: [String] = []
  var www: [URL] = []
  var multimediaLinks: [MultimediaLink] = []
  var languages: [String] = []
  var identifiers: [IdentifierStructure] = []
  var notes: [NoteStructure] = []
  var changeDate: ChangeDate?
  var creationDate: CreationDate?

  /*
   n @XREF:SUBM@ SUBM {1:1} g7:record-SUBM
   +1 NAME <Text> {1:1} g7:NAME
   +1 <<ADDRESS_STRUCTURE>> {0:1}
   +1 PHON <Special> {0:M} g7:PHON
   +1 EMAIL <Special> {0:M} g7:EMAIL
   +1 FAX <Special> {0:M} g7:FAX
   +1 WWW <Special> {0:M} g7:WWW
   +1 <<MULTIMEDIA_LINK>> {0:M}
   +1 LANG <Language> {0:M} g7:SUBM-LANG
   +1 <<IDENTIFIER_STRUCTURE>> {0:M}
   +1 <<NOTE_STRUCTURE>> {0:M}
   +1 <<CHANGE_DATE>> {0:1}
   +1 <<CREATION_DATE>> {0:1}
   */

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
        mutableSelf[keyPath: wkp].append(URL(string: child.line.value!)!)
      } else if let wkp = kp as? WritableKeyPath<Submitter, ChangeDate?> {
        mutableSelf[keyPath: wkp] = try ChangeDate(record: child)
      } else if let wkp = kp as? WritableKeyPath<Submitter, CreationDate?> {
        mutableSelf[keyPath: wkp] = try CreationDate(record: child)
      }
    }
  }
}
