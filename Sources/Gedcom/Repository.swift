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

public class Repository : RecordProtocol {
  public var xref: String
  public var name: String = ""
  public var address: AddressStructure?
  public var phoneNumbers: [String] = []
  public var emails: [String] = []
  public var faxNumbers: [String] = []
  public var www: [String] = []
  public var notes: [NoteStructure] = []
  public var identifiers: [IdentifierStructure] = []
  public var changeDate: ChangeDate?
  public var creationDate: CreationDate?


  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "NAME" : \Repository.name,
    "ADDR" : \Repository.address,
    "PHON" : \Repository.phoneNumbers,
    "EMAIL" : \Repository.emails,
    "FAX" : \Repository.faxNumbers,
    "WWW" : \Repository.www,
    "NOTE" : \Repository.notes,
    "SNOTE" : \Repository.notes,
    "REFN" : \Repository.identifiers,
    "UID" : \Repository.identifiers,
    "EXID" : \Repository.identifiers,
    "CHAN" : \Repository.changeDate,
    "CREA" : \Repository.creationDate
  ]

  required init(record: Record) throws {
    self.xref = record.line.xref!
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Repository, String> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<Repository, [String]> {
        mutableSelf[keyPath: wkp].append(child.line.value ?? "")
      } else if let wkp = kp as? WritableKeyPath<Repository, AddressStructure?> {
        mutableSelf[keyPath: wkp] = try AddressStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<Repository, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Repository, [IdentifierStructure]> {
        mutableSelf[keyPath: wkp].append(try IdentifierStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Repository, ChangeDate?> {
        mutableSelf[keyPath: wkp] = try ChangeDate(record: child)
      } else if let wkp = kp as? WritableKeyPath<Repository, CreationDate?> {
        mutableSelf[keyPath: wkp] = try CreationDate(record: child)
      }
    }
  }

  func export() -> Record? {
    return nil
  }
}

