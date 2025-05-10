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

public class Translation : RecordProtocol {
  public var text: String
  public var mimeType: String?
  public var lang: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "MIME" : \Translation.mimeType,
    "LANG" : \Translation.lang,
  ]

  required init(record: Record) throws {
    self.text = record.line.value ?? ""

    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Translation, String?> {
        mutableSelf[keyPath: wkp] = child.line.value!
      }
    }
  }
}

public class Note : RecordProtocol {
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "MIME" : \Note.mimeType,
    "LANG" : \Note.lang,
    "TRAN" : \Note.translations,
    "SOUR" : \Note.citations,
 ]

  required init(record: Record) throws {
    self.text = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Note, [Translation]> {
        mutableSelf[keyPath: wkp].append(try Translation(record: child))
      } else if let wkp = kp as? WritableKeyPath<Note, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<Note, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      }
    }
  }
  
  public var text: String = ""
  public var mimeType: String?
  public var lang: String?
  public var translations: [Translation] = []
  public var citations: [SourceCitation] = []
}

public class SNoteRef : RecordProtocol {
  public var xref: String

  required convenience init(record: Record) throws {
    self.init(xref: record.line.value!)
  }

  init(xref: String) {
    self.xref = xref
  }
}

public enum NoteStructure {
  case Note(Note)
  case SNote(SNoteRef)
}

extension NoteStructure : RecordProtocol {
  init(record: Record) throws {
    switch record.line.tag {
    case "NOTE":
      self = .Note(try Gedcom.Note(record: record))
    case "SNOTE":
      self = .SNote(try SNoteRef(record: record))
    default:
      throw GedcomError.badRecord
    }
  }
}

