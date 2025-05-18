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

public class LdsSpouseSealing : RecordProtocol {
  public var date: DateValue?
  public var temple: String?
  public var place: PlaceStructure?

  public var status: LdsOrdinanceStatus?

  public var notes: [NoteStructure] = []
  public var citations: [SourceCitation] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATE" : \LdsSpouseSealing.date,
    "TEMP" : \LdsSpouseSealing.temple,
    "PLAC" : \LdsSpouseSealing.place,

    "STAT": \LdsSpouseSealing.status,

    "NOTE" : \LdsSpouseSealing.notes,
    "SNOTE" : \LdsSpouseSealing.notes,

    "SOUR" : \LdsSpouseSealing.citations,
  ]

  init(date: DateValue? = nil,
       temple: String? = nil,
       place: PlaceStructure? = nil,
       status: LdsOrdinanceStatus? = nil,
       notes: [NoteStructure] = [],
       citations: [SourceCitation] = []) {
    self.date = date
    self.temple = temple
    self.place = place
    self.status = status
    self.notes = notes
    self.citations = citations
  }
  required init(record: Record) throws {
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<LdsSpouseSealing, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<LdsSpouseSealing, DateValue?> {
        mutableSelf[keyPath: wkp] = try DateValue(record: child)
      } else if let wkp = kp as? WritableKeyPath<LdsSpouseSealing, PlaceStructure?> {
        mutableSelf[keyPath: wkp] = try PlaceStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<LdsSpouseSealing, LdsOrdinanceStatus?> {
        mutableSelf[keyPath: wkp] = try LdsOrdinanceStatus(record: child)
      } else if let wkp = kp as? WritableKeyPath<LdsSpouseSealing, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<LdsSpouseSealing, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      }
    }
  }


  func export() -> Record {
    let record = Record(level: 0, tag: "SLGS")

    if let date {
      record.children += [date.export()]
    }
    if let temple {
      record.children += [Record(level: 1, tag: "TEMP", value: temple)]
    }
    if let place {
      record.children += [place.export()]
    }
    if let status {
      record.children += [status.export()]
    }
    for note in notes {
      record.children += [note.export()]
    }

    for citation in citations {
      record.children += [citation.export()]
    }

    return record
  }
}


public class SpouseAge : RecordProtocol {
  var kind: String
  public var age: Age

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "AGE" : \SpouseAge.age,
  ]
  init(kind: String, age: String, phrase: String? = nil)
  {
    self.kind = kind
    self.age = Age(age: age, phrase: phrase)
  }
  required init(record: Record) throws {
    kind = record.line.tag
    age = Age()
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<SpouseAge, Age> {
        mutableSelf[keyPath: wkp] = try Age(record: child)
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: kind)

    record.children += [age.export()]

    return record
  }
}


public enum FamilyAttributeKind : String {
  case NCHI
  case RESI
  case FACT
}

public class FamilyAttribute  : RecordProtocol {
  public var kind: FamilyAttributeKind
  public var text: String?
  public var type: String?

  // Family event details
  public var husbandInfo: SpouseAge?
  public var wifeInfo: SpouseAge?

  // Event detail
  public var date: DateValue?
  public var sdate: DateValue?
  public var place: PlaceStructure?
  public var address: AddressStructure?
  public var phones: [String] = []
  public var emails: [String] = []
  public var fax: [String] = []
  public var www: [URL] = []
  public var agency: String?
  public var religion: String?
  public var cause: String?
  public var restrictions: [Restriction] = []
  public var associations: [AssoiciationStructure] = []
  public var notes: [NoteStructure] = []
  public var citations: [SourceCitation] = []
  public var multimediaLinks: [MultimediaLink] = []
  public var uid: [UUID] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "HUSB" : \FamilyAttribute.husbandInfo,
    "WIFE" : \FamilyAttribute.wifeInfo,

    // Event attributes
    "TYPE" : \FamilyAttribute.type,
    "DATE" : \FamilyAttribute.date,
    "ADDR" : \FamilyAttribute.address,
    "PLACE" : \FamilyAttribute.place,
    "PHON" : \FamilyAttribute.phones,
    "EMAIL" : \FamilyAttribute.emails,
    "FAX" : \FamilyAttribute.fax,
    "WWW" : \FamilyAttribute.www,

    "AGNC" : \FamilyAttribute.agency,
    "RELI" : \FamilyAttribute.religion,
    "CAUS" : \FamilyAttribute.cause,
    "RESN" : \FamilyAttribute.restrictions,
    "SDATE" : \FamilyAttribute.sdate,
    "ASSOC" : \FamilyAttribute.associations,
    "NOTE" : \FamilyAttribute.notes,
    "SNOTE" : \FamilyAttribute.notes,
    "SOUR" : \FamilyAttribute.citations,
    "OBJ" : \FamilyAttribute.multimediaLinks,
    "UID" : \FamilyAttribute.uid,
  ]


  init(kind: FamilyAttributeKind, text: String? = nil, type: String? = nil,
       husband: SpouseAge? = nil, wife: SpouseAge? = nil,
       agency: String? = nil, religion: String? = nil, cause: String? = nil) {
    self.kind = kind
    self.text = text
    self.type = type
    self.husbandInfo = husband
    self.wifeInfo = wife
    self.agency = agency
    self.religion = religion
    self.cause = cause
  }
  required init(record: Record) throws {
    self.kind = FamilyAttributeKind(rawValue: record.line.tag)!
    var mutableSelf = self

    if record.line.value != nil {
      text = record.line.value!
    }

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      if let wkp = kp as? WritableKeyPath<FamilyAttribute, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<FamilyAttribute, SpouseAge?> {
        mutableSelf[keyPath: wkp] = try SpouseAge(record: child)
      } else if let wkp = kp as? WritableKeyPath<FamilyAttribute, DateValue?> {
        mutableSelf[keyPath: wkp] = try DateValue(record: child)
      } else if let wkp = kp as? WritableKeyPath<FamilyAttribute, PlaceStructure?> {
        mutableSelf[keyPath: wkp] = try PlaceStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<FamilyAttribute, AddressStructure?> {
        mutableSelf[keyPath: wkp] = try AddressStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<FamilyAttribute, [String]> {
        mutableSelf[keyPath: wkp].append(child.line.value ?? "")
      } else if let wkp = kp as? WritableKeyPath<FamilyAttribute, [URL]> {
        try mutableSelf[keyPath: wkp].append(URL(string: child.line.value ?? "") ?? { throw GedcomError.badURL } ())
      } else if let wkp = kp as? WritableKeyPath<FamilyAttribute, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      } else if let wkp = kp as? WritableKeyPath<FamilyAttribute, [MultimediaLink]> {
        mutableSelf[keyPath: wkp].append(try MultimediaLink(record: child))
      } else if let wkp = kp as? WritableKeyPath<FamilyAttribute, [UUID]> {
        mutableSelf[keyPath: wkp].append(UUID(uuidString: child.line.value!)!)
      } else if let wkp = kp as? WritableKeyPath<FamilyAttribute, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<FamilyAttribute, [AssoiciationStructure]> {
        mutableSelf[keyPath: wkp].append(try AssoiciationStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<FamilyAttribute, [Restriction]> {
        // TODO: This may crash on bad restrictions
        let strings : [String] = (child.line.value?.components(separatedBy: ",").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})) ?? []
        mutableSelf[keyPath: wkp] = strings.map({Restriction(rawValue: $0)!})
      } else if let wkp = kp as? WritableKeyPath<FamilyAttribute, FamilyChildAdoption?> {
        mutableSelf[keyPath: wkp] = try FamilyChildAdoption(record: child)
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: kind.rawValue, value: text)

    if let type {
      record.children += [Record(level: 1, tag: "TYPE", value: type)]
    }

    if let husbandInfo {
      record.children += [husbandInfo.export()]
    }
    if let wifeInfo {
      record.children += [wifeInfo.export()]
    }

    if let date {
      record.children += [date.export()]
    }
    if let sdate {
      record.children += [sdate.export()]
    }
    if let place {
      record.children += [place.export()]
    }
    if let address {
      record.children += [address.export()]
    }
    for phone in phones {
      record.children += [Record(level: 1, tag: "PHON", value: phone)]
    }
    for email in emails {
      record.children += [Record(level: 1, tag: "EMAIL", value: email)]
    }
    for fax in fax {
      record.children += [Record(level: 1, tag: "FAX", value: fax)]
    }
    for www in www {
      record.children += [Record(level: 1, tag: "WWW", value: www.absoluteString)]
    }
    if let agency {
      record.children += [Record(level: 1, tag: "AGNC", value: agency)]
    }
    if let religion {
      record.children += [Record(level: 1, tag: "RELI", value: religion)]
    }
    if let cause {
      record.children += [Record(level: 1, tag: "CAUS", value: cause)]
    }

    if restrictions.count > 0 {
      record.children += [Record(level: 1, tag: "RESN", value: restrictions.map({$0.rawValue}).joined(separator: ", "))]
    }

    for association in associations {
      record.children += [association.export()]
    }

    for note in notes {
      record.children += [note.export()]
    }

    for citation in citations {
      record.children += [citation.export()]
    }

    for link in multimediaLinks {
      record.children += [link.export()]
    }

    for uuid in uid {
      record.children += [Record(level: 1, tag: "UID", value: uuid.uuidString.lowercased())]
    }

    return record
  }
}

public enum FamilyEventKind : String {
  case ANUL
  case CENS
  case DIV
  case DIVF
  case ENGA
  case MARB
  case MARC
  case MARL
  case MARR
  case MARS
  case EVEN
}

public class NonFamilyEventStructure : RecordProtocol {
  public var kind: FamilyEventKind
  public var date: DatePeriod?
  public var notes: [NoteStructure] = []
  public var citations: [SourceCitation] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATE" : \NonFamilyEventStructure.date,
    "NOTE" : \NonFamilyEventStructure.notes,
    "SNOTE" : \NonFamilyEventStructure.notes,
    "SOUR" : \NonFamilyEventStructure.citations,
  ]

  init(kind: FamilyEventKind,
       date: DatePeriod? = nil,
       notes: [NoteStructure] = [],
       citations: [SourceCitation] = []) {
    self.kind = kind
    self.date = date
    self.notes = notes
    self.citations = citations
  }
  required init(record: Record) throws {
    self.kind = FamilyEventKind(rawValue: record.line.value ?? "") ?? .EVEN

    if kind == .EVEN {
      throw GedcomError.badRecord
    }

    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<NonFamilyEventStructure, DatePeriod?> {
        mutableSelf[keyPath: wkp] = try DatePeriod(record: child)
      } else if let wkp = kp as? WritableKeyPath<NonFamilyEventStructure, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<NonFamilyEventStructure, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "NO", value: kind.rawValue)

    if let date {
      record.children += [date.export()]
    }

    for note in notes {
      record.children += [note.export()]
    }

    for citation in citations {
      record.children += [citation.export()]
    }

    return record
  }
}

public class FamilyEvent : RecordProtocol {
  public var kind: FamilyEventKind
  public var text: String?
  public var occured: Bool // Text == Y
  public var type: String?

  // Family event details
  public var husbandInfo: SpouseAge?
  public var wifeInfo: SpouseAge?

  // Event detail
  public var date: DateValue?
  public var sdate: DateValue?
  public var place: PlaceStructure?
  public var address: AddressStructure?
  public var phones: [String] = []
  public var emails: [String] = []
  public var fax: [String] = []
  public var www: [URL] = []
  public var agency: String?
  public var religion: String?
  public var cause: String?
  public var restrictions: [Restriction] = []
  public var associations: [AssoiciationStructure] = []
  public var notes: [NoteStructure] = []
  public var citations: [SourceCitation] = []
  public var multimediaLinks: [MultimediaLink] = []
  public var uid: [UUID] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "HUSB" : \FamilyEvent.husbandInfo,
    "WIFE" : \FamilyEvent.wifeInfo,

    "TYPE" : \FamilyEvent.type,

    "ADDR" : \FamilyEvent.address,
    "DATE" : \FamilyEvent.date,
    "PHON" : \FamilyEvent.phones,
    "EMAIL" : \FamilyEvent.emails,
    "FAX" : \FamilyEvent.fax,
    "WWW" : \FamilyEvent.www,
    "SDATE" : \FamilyEvent.sdate,
    "PLAC": \FamilyEvent.place,
    "AGNC": \FamilyEvent.agency,
    "RELI": \FamilyEvent.religion,
    "CAUS": \FamilyEvent.cause,
    "RESN" : \FamilyEvent.restrictions,
    "ASSO" : \FamilyEvent.associations,
    "NOTE" : \FamilyEvent.notes,
    "SNOTE" : \FamilyEvent.notes,
    "SOUR" : \FamilyEvent.citations,
    "OBJE" : \FamilyEvent.multimediaLinks,
    "UID" : \FamilyEvent.uid,
  ]

  init(kind: FamilyEventKind, occured: Bool? = nil, text: String? = nil,
       type: String? = nil,
       husband: SpouseAge? = nil,
       wife: SpouseAge? = nil,
       date: DateValue? = nil,
       sdate: DateValue? = nil,
       place: PlaceStructure? = nil,
       address: AddressStructure? = nil,
       phones: [String] = [],
       emails: [String] = [],
       faxes: [String] = [],
       urls: [URL] = [],
       agency: String? = nil,
       religion: String? = nil,
       cause: String? = nil,
       restrictions: [Restriction] = [],
       associations: [AssoiciationStructure] = [],
       notes: [NoteStructure] = [],
       citations: [SourceCitation] = [],
       multimediaLinks: [MultimediaLink] = [],
       uids: [UUID] = []
  )
  {
    self.kind = kind
    self.text = text
    self.occured = occured ?? false
    self.type = type
    self.husbandInfo = husband
    self.wifeInfo = wife
    self.date = date
    self.sdate = sdate
    self.place = place
    self.address = address
    self.phones = phones
    self.emails = emails
    self.fax = faxes
    self.www = urls
    self.agency = agency
    self.religion = religion
    self.cause = cause
    self.restrictions = restrictions
    self.associations = associations
    self.notes = notes
    self.citations = citations
    self.multimediaLinks = multimediaLinks
    self.uid = uids
  }
  required init(record: Record) throws {
    self.kind = FamilyEventKind(rawValue: record.line.tag) ?? .EVEN
    if record.line.value == "Y" {
      occured = true
    } else {
      occured = false
    }

    if kind == .EVEN {
      text = record.line.value ?? ""
    }

    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<FamilyEvent, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<FamilyEvent, SpouseAge?> {
        mutableSelf[keyPath: wkp] = try SpouseAge(record: child)
      } else if let wkp = kp as? WritableKeyPath<FamilyEvent, DateValue?> {
        mutableSelf[keyPath: wkp] = try DateValue(record: child)
      } else if let wkp = kp as? WritableKeyPath<FamilyEvent, PlaceStructure?> {
        mutableSelf[keyPath: wkp] = try PlaceStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<FamilyEvent, AddressStructure?> {
        mutableSelf[keyPath: wkp] = try AddressStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<FamilyEvent, [String]> {
        mutableSelf[keyPath: wkp].append(child.line.value ?? "")
      } else if let wkp = kp as? WritableKeyPath<FamilyEvent, [URL]> {
        try mutableSelf[keyPath: wkp].append(URL(string: child.line.value ?? "") ?? { throw GedcomError.badURL } ())
      } else if let wkp = kp as? WritableKeyPath<FamilyEvent, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      } else if let wkp = kp as? WritableKeyPath<FamilyEvent, [MultimediaLink]> {
        mutableSelf[keyPath: wkp].append(try MultimediaLink(record: child))
      } else if let wkp = kp as? WritableKeyPath<FamilyEvent, [UUID]> {
        mutableSelf[keyPath: wkp].append(UUID(uuidString: child.line.value!)!)
      } else if let wkp = kp as? WritableKeyPath<FamilyEvent, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<FamilyEvent, [AssoiciationStructure]> {
        mutableSelf[keyPath: wkp].append(try AssoiciationStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<FamilyEvent, [Restriction]> {
        // TODO: This may crash on bad restrictions
        let strings : [String] = (child.line.value?.components(separatedBy: ",").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})) ?? []
        mutableSelf[keyPath: wkp] = strings.map({Restriction(rawValue: $0)!})
      } else if let wkp = kp as? WritableKeyPath<FamilyEvent, FamilyChildAdoption?> {
        mutableSelf[keyPath: wkp] = try FamilyChildAdoption(record: child)
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: kind.rawValue)
    if kind == .EVEN {
      record.line.value = text
    } else if occured {
      record.line.value = "Y"
    }

    if let type {
      record.children += [Record(level: 1, tag: "TYPE", value: type)]
    }

    if let husbandInfo {
      record.children += [husbandInfo.export()]
    }
    if let wifeInfo {
      record.children += [wifeInfo.export()]
    }

    if let date {
      record.children += [date.export()]
    }

    if let place {
      record.children += [place.export()]
    }
    if let address {
      record.children += [address.export()]
    }
    for phone in phones {
      record.children += [Record(level: 1, tag: "PHON", value: phone)]
    }
    for email in emails {
      record.children += [Record(level: 1, tag: "EMAIL", value: email)]
    }
    for fax in fax {
      record.children += [Record(level: 1, tag: "FAX", value: fax)]
    }
    for www in www {
      record.children += [Record(level: 1, tag: "WWW", value: www.absoluteString)]
    }
    if let agency {
      record.children += [Record(level: 1, tag: "AGNC", value: agency)]
    }
    if let religion {
      record.children += [Record(level: 1, tag: "RELI", value: religion)]
    }
    if let cause {
      record.children += [Record(level: 1, tag: "CAUS", value: cause)]
    }

    if restrictions.count > 0 {
      record.children += [Record(level: 1, tag: "RESN", value: restrictions.map({$0.rawValue}).joined(separator: ", "))]
    }

    if let sdate {
      let sdate = sdate.export()
      sdate.line.tag = "SDATE" // Override default export tag
      record.children += [sdate]
    }

    for association in associations {
      record.children += [association.export()]
    }

    for note in notes {
      record.children += [note.export()]
    }

    for citation in citations {
      record.children += [citation.export()]
    }

    for link in multimediaLinks {
      record.children += [link.export()]
    }

    for uuid in uid {
      record.children += [Record(level: 1, tag: "UID", value: uuid.uuidString.lowercased())]
    }

    return record
  }
}

public class Family : RecordProtocol {
  public var xref: String
  public var restrictions: [Restriction] = []

  public var attributes: [FamilyAttribute] = []
  public var events: [FamilyEvent] = []
  public var nonEvents: [NonFamilyEventStructure] = []

  public var ldsSpouseSealings: [LdsSpouseSealing] = []

  public var husband: PhraseRef?
  public var wife: PhraseRef?
  public var children: [PhraseRef] = []

  public var associations: [AssoiciationStructure] = []
  public var submitters: [String] = []
  public var identifiers: [IdentifierStructure] = []
  public var notes: [NoteStructure] = []
  public var citations: [SourceCitation] = []
  public var multimediaLinks: [MultimediaLink] = []
  public var changeDate: ChangeDate?
  public var creationDate: CreationDate?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "RESN" : \Family.restrictions,

    "NCHI" : \Family.attributes,
    "RESI" : \Family.attributes,
    "FACT" : \Family.attributes,

    "ANUL" : \Family.events,
    "CENS" : \Family.events,
    "DIV" : \Family.events,
    "DIVF" : \Family.events,
    "ENGA" : \Family.events,
    "MARB" : \Family.events,
    "MARC" : \Family.events,
    "MARL" : \Family.events,
    "MARR" : \Family.events,
    "MARS" : \Family.events,
    "EVEN" : \Family.events,

    "NO" : \Family.nonEvents,

    "SLGS" : \Family.ldsSpouseSealings,

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


  init(xref: String) {
    self.xref = xref
  }

  required init(record: Record) throws {
    self.xref = record.line.xref ?? ""
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
      } else if let wkp = kp as? WritableKeyPath<Family, [FamilyAttribute]> {
        mutableSelf[keyPath: wkp].append(try FamilyAttribute(record: child))
      } else if let wkp = kp as? WritableKeyPath<Family, [FamilyEvent]> {
        mutableSelf[keyPath: wkp].append(try FamilyEvent(record: child))
      } else if let wkp = kp as? WritableKeyPath<Family, [NonFamilyEventStructure]> {
        mutableSelf[keyPath: wkp].append(try NonFamilyEventStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Family, [LdsSpouseSealing]> {
        mutableSelf[keyPath: wkp].append(try LdsSpouseSealing(record: child))
      } else if let wkp = kp as? WritableKeyPath<Family, [PhraseRef]> {
        mutableSelf[keyPath: wkp].append(try PhraseRef(record: child))
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

  func export() -> Record {
    let record = Record(level: 0, xref: xref, tag: "FAM")

    if restrictions.count > 0 {
      record.children += [Record(level: 1, tag: "RESN",
                                 value: restrictions.map({$0.rawValue}).joined(separator: ", "))]

    }

    for attribute in attributes {
      record.children += [attribute.export()]
    }
    for event in events {
      record.children += [event.export()]
    }
    for nonEvent in nonEvents {
      record.children += [nonEvent.export()]
    }

    if let husband {
      record.children += [husband.export()]
    }

    if let wife {
      record.children += [wife.export()]
    }

    for child in children {
      record.children += [child.export()]
    }

    for association in associations {
      record.children += [association.export()]
    }

    for submitter in submitters {
      record.children += [Record(level: 1, tag: "SUBM", value: submitter)]
    }

    for ldsSpouseSealing in ldsSpouseSealings {
      record.children += [ldsSpouseSealing.export()]
    }

    for identifier in identifiers {
      record.children += [identifier.export()]
    }

    for note in notes {
      record.children += [note.export()]
    }
    for citation in citations {
      record.children += [citation.export()]
    }
    for multimediaLink in multimediaLinks {
      record.children += [multimediaLink.export()]
    }

    if let changeDate {
      record.children += [changeDate.export()]
    }
    if let creationDate {
      record.children += [creationDate.export()]
    }

    record.setLevel(0)
    return record
  }
}
