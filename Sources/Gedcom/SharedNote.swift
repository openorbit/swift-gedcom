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

/*
 n @XREF:SNOTE@ SNOTE <Text> {1:1} g7:record-SNOTE
 +1 MIME <MediaType> {0:1} g7:MIME
 +1 LANG <Language> {0:1} g7:LANG
 +1 TRAN <Text> {0:M} g7:NOTE-TRAN
 +2 MIME <MediaType> {0:1} g7:MIME
 +2 LANG <Language> {0:1} g7:LANG
 +1 <<SOURCE_CITATION>> {0:M}
 +1 <<IDENTIFIER_STRUCTURE>> {0:M}
 +1 <<CHANGE_DATE>> {0:1}
 +1 <<CREATION_DATE>> {0:1}

 */

public class SharedNote : RecordProtocol {
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "MIME" : \SharedNote.mimeType,
    "LANG" : \SharedNote.lang,
    "TRAN" : \SharedNote.translation,
    "SOUR" : \SharedNote.citation,
    "REFN" : \SharedNote.identifiers,
    "UID" : \SharedNote.identifiers,
    "EXID" : \SharedNote.identifiers,
    "CHAN" : \SharedNote.changeDate,
    "CREA" : \SharedNote.creationDate
  ]
  public var text: String = ""
  public var mimeType: String?
  public var lang: String?
  public var translation: [Translation] = []
  public var citation: [SourceCitation] = []
  public var identifiers: [IdentifierStructure] = []
  public var changeDate: ChangeDate?
  public var creationDate: CreationDate?

  required init(record: Record) throws {
    self.text = record.line.value ?? ""

    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<SharedNote, [Translation]> {
        mutableSelf[keyPath: wkp].append(try Translation(record: child))
      } else if let wkp = kp as? WritableKeyPath<SharedNote, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<SharedNote, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      } else if let wkp = kp as? WritableKeyPath<SharedNote, [IdentifierStructure]> {
        mutableSelf[keyPath: wkp].append(try IdentifierStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<SharedNote, ChangeDate?> {
        mutableSelf[keyPath: wkp] = try ChangeDate(record: child)
      } else if let wkp = kp as? WritableKeyPath<SharedNote, CreationDate?> {
        mutableSelf[keyPath: wkp] = try CreationDate(record: child)
      }

    }

  }

}
