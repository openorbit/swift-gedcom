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

public class SourceCitationData : RecordProtocol {
  public var date: DateValue?
  public var text: [Translation] = []

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

  func export() -> Record? {
    return nil
  }
}
public class SourceEventRole : RecordProtocol {
  public var role: String
  public var phrase: String?

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

  func export() -> Record? {
    return nil
  }
}

public class SourceEventData : RecordProtocol {
  public var event: String
  public var phrase: String?
  public var role: SourceEventRole?

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

  func export() -> Record? {
    return nil
  }
}

public class SourceCitation : RecordProtocol {
  public var xref: String
  public var page: String?
  public var data: SourceCitationData?
  public var events: [SourceEventData] = []
  public var quality: Int?
  public var links: [MultimediaLink] = []
  public var notes: [NoteStructure] = []

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

  func export() -> Record? {
    return nil
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

  func export() -> Record? {
    return nil
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

      if let wkp = kp as? WritableKeyPath<SourceDataEvents, PlaceStructure?> {
        mutableSelf[keyPath: wkp] = try PlaceStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<SourceDataEvents, SourceDataEventPeriod?> {
        mutableSelf[keyPath: wkp] = try SourceDataEventPeriod(record: child)
      }
    }
  }

  func export() -> Record? {
    return nil
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

      if let wkp = kp as? WritableKeyPath<SourceData, [SourceDataEvents]> {
        mutableSelf[keyPath: wkp].append(try SourceDataEvents(record: child))
      } else if let wkp = kp as? WritableKeyPath<SourceData, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<SourceData, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record? {
    return nil
  }
}

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
  public var kind: MediumKind
  public var phrase: String?
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

      if let wkp = kp as? WritableKeyPath<Medium, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record? {
    return nil
  }
}

public class CallNumber : RecordProtocol {
  public var callNumber: String
  public var medium: Medium?
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

      if let wkp = kp as? WritableKeyPath<CallNumber, Medium?> {
        mutableSelf[keyPath: wkp] = try Medium(record: child)
      }
    }
  }

  func export() -> Record? {
    return nil
  }
}

public class SourceRepositoryCitation : RecordProtocol {
  public var xref: String
  public var notes: [NoteStructure] = []
  public var callNumbers: [CallNumber] = []

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

      if let wkp = kp as? WritableKeyPath<SourceRepositoryCitation, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<SourceRepositoryCitation, [CallNumber]> {
        mutableSelf[keyPath: wkp].append(try CallNumber(record: child))
      }
    }
  }

  func export() -> Record? {
    return nil
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
      if let wkp = kp as? WritableKeyPath<SourceText, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record? {
    return nil
  }
}

public class Source : RecordProtocol {
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

  func export() -> Record? {
    return nil
  }
}
