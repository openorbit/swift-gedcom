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

public class Source : RecordProtocol {
  public var multimediaLinks: [MultimediaLink] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    :
  ]

  required init(record: Record) throws {
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      print("\(child.line.tag)")

      if let wkp = kp as? WritableKeyPath<Source, [String]?> {
      }
    }
  }

  /*
   n @XREF:SOUR@ SOUR {1:1} g7:record-SOUR
   +1 DATA {0:1} g7:DATA
   +2 EVEN <List:Enum> {0:M} g7:DATA-EVEN
   +3 DATE <DatePeriod> {0:1} g7:DATA-EVEN-DATE
   +4 PHRASE <Text> {0:1} g7:PHRASE
   +3 <<PLACE_STRUCTURE>> {0:1}
   +2 AGNC <Text> {0:1} g7:AGNC
   +2 <<NOTE_STRUCTURE>> {0:M}
   +1 AUTH <Text> {0:1} g7:AUTH
   +1 TITL <Text> {0:1} g7:TITL
   +1 ABBR <Text> {0:1} g7:ABBR
   +1 PUBL <Text> {0:1} g7:PUBL
   +1 TEXT <Text> {0:1} g7:TEXT
   +2 MIME <MediaType> {0:1} g7:MIME
   +2 LANG <Language> {0:1} g7:LANG
   +1 <<SOURCE_REPOSITORY_CITATION>> {0:M}
   +1 <<IDENTIFIER_STRUCTURE>> {0:M}
   +1 <<NOTE_STRUCTURE>> {0:M}
   +1 <<MULTIMEDIA_LINK>> {0:M}
   +1 <<CHANGE_DATE>> {0:1}
   +1 <<CREATION_DATE>> {0:1}
   */
}
