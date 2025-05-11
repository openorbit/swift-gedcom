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

public class Family : RecordProtocol {
  public var restrictions: [Restriction] = []
  // public var familyAttributes: []
  // public var familyEvents: []
  // public var nonEvents: []
  public var husband: PhraseRef?
  public var wife: PhraseRef?
  public var children: [PhraseRef] = []

  public var associations: [AssoiciationStructure] = []
  public var submitters: [String] = []
  //+1 <<LDS_SPOUSE_SEALING>> {0:M}
  public var identifiers: [IdentifierStructure] = []
  public var notes: [NoteStructure] = []
  public var citations: [SourceCitation] = []
  public var multimediaLinks: [MultimediaLink] = []
  public var changeDate: ChangeDate?
  public var creationDate: CreationDate?

  //+1 <<IDENTIFIER_STRUCTURE>> {0:M}
  //+1 <<NOTE_STRUCTURE>> {0:M}
  //+1 <<SOURCE_CITATION>> {0:M}
  //+1 <<MULTIMEDIA_LINK>> {0:M}
  //+1 <<CHANGE_DATE>> {0:1}
  //+1 <<CREATION_DATE>> {0:1}

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "RESN" : \Family.restrictions,
    "HUSB" : \Family.husband,
    "WIFE" : \Family.wife,
    "CHIL" : \Family.children,

    "ASSO" : \Family.associations,
    "SUBM" : \Family.submitters,

    "REFN" : \Family.identifiers,
    "UID" : \Family.identifiers,
    "EXID" : \Family.identifiers,

    "NOTE" : \Family.notes,
    "SNOTE" : \Family.notes,

    "SOUR" : \Family.citations,
    "OBJE" : \Family.multimediaLinks,

    "CHAN" : \Family.changeDate,
    "CREA" : \Family.creationDate
  ]

  required init(record: Record) throws {
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Family, [String]> {
        mutableSelf[keyPath: wkp].append(child.line.value ?? "")
      } else if let wkp = kp as? WritableKeyPath<Family, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<Family, PhraseRef?> {
        mutableSelf[keyPath: wkp] = try PhraseRef(record: child)
      } else if let wkp = kp as? WritableKeyPath<Family, [PhraseRef]> {
        mutableSelf[keyPath: wkp].append(try PhraseRef(record: child))
      } else if let wkp = kp as? WritableKeyPath<Family, [AssoiciationStructure]> {
        mutableSelf[keyPath: wkp].append(try AssoiciationStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Family, [Restriction]> {
        // TODO: This may crash on bad restrictions
        let strings : [String] = (child.line.value?.components(separatedBy: ",").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})) ?? []
        mutableSelf[keyPath: wkp] = strings.map({Restriction(rawValue: $0)!})
      } else if let wkp = kp as? WritableKeyPath<Family, [IdentifierStructure]> {
        mutableSelf[keyPath: wkp].append(try IdentifierStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Family, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Family, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      } else if let wkp = kp as? WritableKeyPath<Family, [MultimediaLink]> {
        mutableSelf[keyPath: wkp].append(try MultimediaLink(record: child))
      } else if let wkp = kp as? WritableKeyPath<Family, CreationDate?> {
        mutableSelf[keyPath: wkp] = try CreationDate(record: child)
      } else if let wkp = kp as? WritableKeyPath<Family, ChangeDate?> {
        mutableSelf[keyPath: wkp] = try ChangeDate(record: child)
      }
    }
  }

}
