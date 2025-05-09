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
public class SourceCitationData : RecordProtocol {
  var date: DateValue?
  var text: [Translation] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATE" : \SourceCitationData.date,
    "TEXT" : \SourceCitationData.text,
  ]

  required init(record: Record) throws {
    var mutableSelf = self
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      if let wkp = kp as? WritableKeyPath<SourceCitationData, DateValue?> {
        mutableSelf[keyPath: wkp] = try DateValue(record: child)
      } else if let wkp = kp as? WritableKeyPath<SourceCitationData,[Translation]> {
        mutableSelf[keyPath: wkp].append(try Translation(record: child))
      }
    }
  }

}
public class SourceEventRole : RecordProtocol {
  var role: String
  var phrase: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \SourceEventRole.phrase,
  ]

  required init(record: Record) throws {
    self.role = record.line.value ?? ""
    var mutableSelf = self
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      if let wkp = kp as? WritableKeyPath<SourceEventRole, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

}

public class SourceEventData : RecordProtocol {
  var event: String
  var phrase: String?
  var role: SourceEventRole?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \SourceEventData.phrase,
    "ROLE" : \SourceEventData.role,
  ]

  required init(record: Record) throws {
    self.event = record.line.value ?? ""
    var mutableSelf = self
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      if let wkp = kp as? WritableKeyPath<SourceEventData, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<SourceEventData, SourceEventRole?> {
        mutableSelf[keyPath: wkp] = try SourceEventRole(record: child)
      }
    }
  }
}

public class SourceCitation : RecordProtocol {
  var xref: String
  var page: String?
  var data: SourceCitationData?
  var events: [SourceEventData] = []
  var quality: Int?
  var links: [MultimediaLink] = []
  var notes: [NoteStructure] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PAGE" : \SourceCitation.page,

    "DATA" : \SourceCitation.data,
    "EVEN" : \SourceCitation.events,

    "QUAY" : \SourceCitation.quality,
    "OBJE" : \SourceCitation.links,

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
      } else if let wkp = kp as? WritableKeyPath<SourceCitation, Int?> {
        mutableSelf[keyPath: wkp] = Int(child.line.value ?? "0")
      } else if let wkp = kp as? WritableKeyPath<SourceCitation, SourceCitationData?> {
        mutableSelf[keyPath: wkp] = try SourceCitationData(record: child)
      } else if let wkp = kp as? WritableKeyPath<SourceCitation, [SourceEventData]> {
        mutableSelf[keyPath: wkp].append(try SourceEventData(record: child))
      } else if let wkp = kp as? WritableKeyPath<SourceCitation, [MultimediaLink]> {
        mutableSelf[keyPath: wkp].append(try MultimediaLink(record: child))
      } else if let wkp = kp as? WritableKeyPath<SourceCitation, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      }
    }
  }
}

public class SourceDataEventPeriod : RecordProtocol {
  public var date: String
  public var phrase: String?
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE": \SourceDataEventPeriod.phrase,
  ]

  required init(record: Record) throws {
    self.date = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<SourceDataEventPeriod, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }
}

public class SourceDataEvents : RecordProtocol {
  public var period: SourceDataEventPeriod?
  public var eventTypes: [String] = []
  public var place: PlaceStructure?
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATE": \SourceDataEvents.period,
    "PLAC": \SourceDataEvents.place,
  ]

  required init(record: Record) throws {
    self.eventTypes = (record.line.value ?? "")
      .components(separatedBy: ",")
      .map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})

    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      print("\(child.line.tag)")

      if let wkp = kp as? WritableKeyPath<SourceDataEvents, PlaceStructure?> {
        mutableSelf[keyPath: wkp] = try PlaceStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<SourceDataEvents, SourceDataEventPeriod?> {
        mutableSelf[keyPath: wkp] = try SourceDataEventPeriod(record: child)
      }
    }
  }
}

public class SourceData : RecordProtocol {
  public var events: [SourceDataEvents] = []
  public var agency: String?
  public var notes: [NoteStructure] = []
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "EVEN": \SourceData.events,
    "AGNC": \SourceData.agency,
    "NOTE": \SourceData.notes,
    "SNOTE": \SourceData.notes
  ]

  required init(record: Record) throws {
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      print("\(child.line.tag)")

      if let wkp = kp as? WritableKeyPath<SourceData, [SourceDataEvents]> {
        mutableSelf[keyPath: wkp].append(try SourceDataEvents(record: child))
      } else if let wkp = kp as? WritableKeyPath<SourceData, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<SourceData, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }
}

/*
REPO @<XREF:REPO>@                       {1:1}  g7:REPO
  +1 <<NOTE_STRUCTURE>>                    {0:M}
  +1 CALN <Special>                        {0:M}  g7:CALN
     +2 MEDI <Enum>                        {0:1}  g7:MEDI
        +3 PHRASE <Text>
*/

public enum MediumKind : String {
  case AUDIO //  An audio recording
  case BOOK  // A bound book
  case CARD  // A card or file entry
  case ELECTRONIC // A digital artifact
  case FICHE  // Microfiche
  case FILM // Microfilm
  case MAGAZINE  // Printed periodical
  case MANUSCRIPT // Written pages
  case MAP  // Cartographic map
  case NEWSPAPER  // Printed newspaper
  case PHOTO  // Photograph
  case TOMBSTONE  // Burial marker or related memorial
  case VIDEO  // Motion picture recording
  case OTHER  // A value not listed here; should have a PHRASE substructure
}

public class Medium : RecordProtocol {
  var kind: MediumKind
  var phrase: String?
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \Medium.phrase,
  ]
  required init(record: Record) throws {
    kind = MediumKind(rawValue: record.line.value ?? "OTHER") ?? .OTHER
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      print("\(child.line.tag)")

      if let wkp = kp as? WritableKeyPath<Medium, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }
}

public class CallNumber : RecordProtocol {
  var callNumber: String
  var medium: Medium?
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "MEDI" : \CallNumber.medium,
  ]
  required init(record: Record) throws {
    callNumber = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      print("\(child.line.tag)")

      if let wkp = kp as? WritableKeyPath<CallNumber, Medium?> {
        mutableSelf[keyPath: wkp] = try Medium(record: child)
      }
    }
  }
}

public class SourceRepositoryCitation : RecordProtocol {
  var xref: String
  var notes: [NoteStructure] = []
  var callNumbers: [CallNumber] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "NOTE" : \SourceRepositoryCitation.notes,
    "SNOTE" : \SourceRepositoryCitation.notes,
    "CALN" : \SourceRepositoryCitation.callNumbers
  ]
  required init(record: Record) throws {
    xref = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      print("\(child.line.tag)")

      if let wkp = kp as? WritableKeyPath<SourceRepositoryCitation, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<SourceRepositoryCitation, [CallNumber]> {
        mutableSelf[keyPath: wkp].append(try CallNumber(record: child))
      }
    }
  }
}

public class SourceText : RecordProtocol {
  public var text: String
  public var mimeType: String?
  public var lang: String?
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "MIME": \SourceText.mimeType,
    "LANG": \SourceText.lang,
  ]

  required init(record: Record) throws {
    text = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      print("\(child.line.tag)")
      if let wkp = kp as? WritableKeyPath<SourceText, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

}

public class Source : RecordProtocol {
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
  public var data: SourceData?
  public var author: String?
  public var title: String?
  public var abbreviation: String?
  public var publication: String?
  public var text: SourceText?
  public var sourceRepoCitation: [SourceRepositoryCitation] = []

  public var identifiers: [IdentifierStructure] = []
  public var notes: [NoteStructure] = []
  public var multimediaLinks: [MultimediaLink] = []
  public var changeDate: ChangeDate?
  public var creationDate: CreationDate?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATA" : \Source.data,
    "AUTH" : \Source.author,
    "TITL" : \Source.title,
    "ABBR" : \Source.abbreviation,
    "PUBL" : \Source.publication,
    "TEXT" : \Source.text,
    "REPO" : \Source.sourceRepoCitation,
    "REFN" : \Source.identifiers,
    "UID" : \Source.identifiers,
    "EXID" : \Source.identifiers,
    "NOTE" : \Source.notes,
    "SNOTE" : \Source.notes,
    "OBJE" : \Source.multimediaLinks,
    "CHAN" : \Source.changeDate,
    "CREA" : \Source.creationDate
  ]

  required init(record: Record) throws {
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      print("\(child.line.tag)")

      if let wkp = kp as? WritableKeyPath<Source, SourceData?> {
        mutableSelf[keyPath: wkp] = try SourceData(record: child)
      } else if let wkp = kp as? WritableKeyPath<Source, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<Source, SourceText?> {
        mutableSelf[keyPath: wkp] = try SourceText(record: child)
      } else if let wkp = kp as? WritableKeyPath<Source, [SourceRepositoryCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceRepositoryCitation(record: child))
      } else if let wkp = kp as? WritableKeyPath<Source, [IdentifierStructure]> {
        mutableSelf[keyPath: wkp].append(try IdentifierStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Source, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Source, [MultimediaLink]> {
        mutableSelf[keyPath: wkp].append(try MultimediaLink(record: child))
      } else if let wkp = kp as? WritableKeyPath<Source, ChangeDate?> {
        mutableSelf[keyPath: wkp] = try ChangeDate(record: child)
      } else if let wkp = kp as? WritableKeyPath<Source, CreationDate?> {
        mutableSelf[keyPath: wkp] = try CreationDate(record: child)
      }
    }
  }
}
