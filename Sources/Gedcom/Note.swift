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
      print("\(child.line.tag)")

      if let wkp = kp as? WritableKeyPath<Translation, String?> {
        mutableSelf[keyPath: wkp] = child.line.value!
      }
    }
  }
}

/*
 n SOUR @<XREF:SOUR>@ {1:1} g7:SOUR
 +1 PAGE <Text> {0:1} g7:PAGE
 +1 DATA {0:1} g7:SOUR-DATA
  +2 <<DATE_VALUE>> {0:1}
  +2 TEXT <Text> {0:M} g7:TEXT
    +3 MIME <MediaType> {0:1} g7:MIME
    +3 LANG <Language> {0:1} g7:LANG
 +1 EVEN <Enum> {0:1} g7:SOUR-EVEN
  +2 PHRASE <Text> {0:1} g7:PHRASE
  +2 ROLE <Enum> {0:1} g7:ROLE
    +3 PHRASE <Text> {0:1} g7:PHRASE
 +1 QUAY <Enum> {0:1} g7:QUAY
 +1 <<MULTIMEDIA_LINK>> {0:M}
 +1 <<NOTE_STRUCTURE>> {0:M}
*/
public class SourceData : RecordProtocol {
  var date: DateValue?
  var text: Translation?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATE" : \SourceData.date,
    "TEXT" : \SourceData.text,
  ]

  required init(record: Record) throws {
    var mutableSelf = self
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      if let wkp = kp as? WritableKeyPath<SourceData, DateValue?> {
        mutableSelf[keyPath: wkp] = try DateValue(record: child)
      } else if let wkp = kp as? WritableKeyPath<SourceData,Translation?> {
        mutableSelf[keyPath: wkp] = try Translation(record: child)
      }
    }
  }

}
public class SourceCitation : RecordProtocol {
  var xref: String
  var page: String?
  var data: SourceData?
  var quality: Int?
  var notes: [NoteStructure] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PAGE" : \SourceCitation.page,

    "DATA" : \SourceCitation.data,
    //"EVEN" : \SourceCitation.page,

    "QUAY" : \SourceCitation.quality,
    //"OBJE" : \SourceCitation.page, // Multimedia

    "NOTE" : \SourceCitation.notes,
    "SNOTE" : \SourceCitation.notes,
  ]

  required init(record: Record) throws {
    xref = record.line.value ?? ""
    var mutableSelf = self
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      if let wkp = kp as? WritableKeyPath<SourceCitation, String> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<SourceCitation, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<SourceCitation, SourceData?> {
        mutableSelf[keyPath: wkp] = try SourceData(record: child)
      } else if let wkp = kp as? WritableKeyPath<SourceCitation, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      }
    }
  }
}

public class Note : RecordProtocol {
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "MIME" : \Note.mimeType,
    "LANG" : \Note.lang,
    "TRAN" : \Note.translation,
    "SOUR" : \Note.citation,
 ]

  required init(record: Record) throws {
    self.text = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      print("\(child.line.tag)")

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
  public var translation: [Translation] = []
  public var citation: [SourceCitation] = []
}

public class SNoteRef {
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

