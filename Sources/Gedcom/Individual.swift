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

public class Age : RecordProtocol {
  public var age: String
  public var phrase: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \Age.phrase,
  ]

  init() {
    age = ""
  }
  init(age: String, phrase: String? = nil)
  {
    self.age = age
    self.phrase = phrase
  }

  required init(record: Record) throws {
    age = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Age, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "AGE", value: age)

    if let phrase = phrase {
      record.children += [Record(level: 1, tag: "PHRASE", value: phrase)]
    }

    return record
  }
}

public enum IndividualAttributeKind : String {
  case CAST = "CAST"
  case DSCR = "DSCR"
  case EDUC = "EDUC"
  case IDNO = "IDNO"
  case NATI = "NATI"
  case NCHI = "NCHI"
  case NMR = "NMR"
  case OCCU = "OCCU"
  case PROP = "PROP"
  case RELI = "RELI"
  case RESI = "RESI"
  case SSN = "SSN"
  case TITL = "TITL"
  case FACT = "FACT"
}

public class IndividualAttributeStructure  : RecordProtocol {
  public var kind: IndividualAttributeKind
  public var text: String?
  public var type: String?

  // Individual event detail
  public var age: Age?
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
    // Event attributes
    "TYPE" : \IndividualAttributeStructure.type,
    "DATE" : \IndividualAttributeStructure.date,
    "ADDR" : \IndividualAttributeStructure.address,
    "PLACE" : \IndividualAttributeStructure.place,
    "PHON" : \IndividualAttributeStructure.phones,
    "EMAIL" : \IndividualAttributeStructure.emails,
    "FAX" : \IndividualAttributeStructure.fax,
    "WWW" : \IndividualAttributeStructure.www,

    "AGNC" : \IndividualAttributeStructure.agency,
    "RELI" : \IndividualAttributeStructure.religion,
    "CAUS" : \IndividualAttributeStructure.cause,
    "RESN" : \IndividualAttributeStructure.restrictions,
    "SDATE" : \IndividualAttributeStructure.sdate,
    "ASSOC" : \IndividualAttributeStructure.associations,
    "NOTE" : \IndividualAttributeStructure.notes,
    "SNOTE" : \IndividualAttributeStructure.notes,
    "SOUR" : \IndividualAttributeStructure.citations,
    "OBJ" : \IndividualAttributeStructure.multimediaLinks,
    "UID" : \IndividualAttributeStructure.uid,
    // Individual attributes
    "AGE" : \IndividualAttributeStructure.age,
  ]

  init(kind: IndividualAttributeKind,
       text: String? = nil,
       type: String? = nil,
       age: Age? = nil,
       date: DateValue? = nil,
       sdate: DateValue? = nil,
       place: PlaceStructure? = nil,
       address: AddressStructure? = nil,
       phones: [String] = [],
       emails: [String] = [],
       fax: [String] = [],
       www: [URL] = [],
       agency: String? = nil,
       religion: String? = nil,
       cause: String? = nil,
       restrictions: [Restriction] = [],
       associations: [AssoiciationStructure] = [],
       notes: [NoteStructure] = [],
       citations: [SourceCitation] = [],
       multimediaLinks: [MultimediaLink] = [],
       uid: [UUID] = []) {
    self.kind = kind
    self.text = text
    self.type = type
    self.age = age
    self.date = date
    self.sdate = sdate
    self.place = place
    self.address = address
    self.phones = phones
    self.emails = emails
    self.fax = fax
    self.www = www
    self.agency = agency
    self.religion = religion
    self.cause = cause
    self.restrictions = restrictions
    self.associations = associations
    self.notes = notes
    self.citations = citations
    self.multimediaLinks = multimediaLinks
    self.uid = uid
  }
  required init(record: Record) throws {
    self.kind = IndividualAttributeKind(rawValue: record.line.tag)!
    var mutableSelf = self

    if record.line.value != nil {
      text = record.line.value!
    }

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, Age?> {
        mutableSelf[keyPath: wkp] = try Age(record: child)
      } else if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, DateValue?> {
        mutableSelf[keyPath: wkp] = try DateValue(record: child)
      } else if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, PlaceStructure?> {
        mutableSelf[keyPath: wkp] = try PlaceStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, AddressStructure?> {
        mutableSelf[keyPath: wkp] = try AddressStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, [String]> {
        mutableSelf[keyPath: wkp].append(child.line.value ?? "")
      } else if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, [URL]> {
        try mutableSelf[keyPath: wkp].append(URL(string: child.line.value ?? "") ?? { throw GedcomError.badURL } ())
      } else if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      } else if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, [MultimediaLink]> {
        mutableSelf[keyPath: wkp].append(try MultimediaLink(record: child))
      } else if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, [UUID]> {
        mutableSelf[keyPath: wkp].append(UUID(uuidString: child.line.value!)!)
      } else if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, [AssoiciationStructure]> {
        mutableSelf[keyPath: wkp].append(try AssoiciationStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, [Restriction]> {
        // TODO: This may crash on bad restrictions
        let strings : [String] = (child.line.value?.components(separatedBy: ",").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})) ?? []
        mutableSelf[keyPath: wkp] = strings.map({Restriction(rawValue: $0)!})
      } else if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, FamilyChildAdoption?> {
        mutableSelf[keyPath: wkp] = try FamilyChildAdoption(record: child)
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: kind.rawValue, value: text)

    if let type {
      record.children += [Record(level: 1, tag: "TYPE", value: type)]
    }

    if let age {
      record.children += [age.export()]
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

public enum IndividualEventKind : String {
  case ADOP = "ADOP"
  case BAPM = "BAPM"
  case BARM = "BARM"
  case BASM = "BASM"
  case BIRT = "BIRT"
  case BLES = "BLES"
  case BURI = "BURI"
  case CENS = "CENS"
  case CHR = "CHR"
  case CHRA = "CHRA"
  case CONF = "CONF"
  case CREM = "CREM"
  case DEAT = "DEAT"
  case EMIG = "EMIG"
  case FCOM = "FCOM"
  case GRAD = "GRAD"
  case IMMI = "IMMI"
  case NATU = "NATU"
  case ORDN = "ORDN"
  case PROB = "PROB"
  case RETI = "RETI"
  case WILL = "WILL"
  case EVEN = "EVEN"
}

public class NonEventStructure : RecordProtocol {
  public var kind: IndividualEventKind
  public var date: DatePeriod?
  public var notes: [NoteStructure] = []
  public var citations: [SourceCitation] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATE" : \NonEventStructure.date,
    "NOTE" : \NonEventStructure.notes,
    "SNOTE" : \NonEventStructure.notes,
    "SOUR" : \NonEventStructure.citations,
  ]

  init(kind: IndividualEventKind,
       date: DatePeriod? = nil,
       notes: [NoteStructure] = [],
       citations: [SourceCitation] = []) {
    self.kind = kind
    self.date = date
    self.notes = notes
    self.citations = citations
  }
  required init(record: Record) throws {
    self.kind = IndividualEventKind(rawValue: record.line.value ?? "") ?? .EVEN

    if kind == .EVEN {
      throw GedcomError.badRecord
    }

    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<NonEventStructure, DatePeriod?> {
        mutableSelf[keyPath: wkp] = try DatePeriod(record: child)
      } else if let wkp = kp as? WritableKeyPath<NonEventStructure, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<NonEventStructure, [SourceCitation]> {
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

public class IndividualEvent : RecordProtocol {
  public var kind: IndividualEventKind
  public var text: String?
  public var occurred: Bool // Text == Y
  public var type: String?

  // ADOP specific
  public var familyChild: FamilyChildAdoption?

  // Individual event detail
  public var age: Age?
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
    "TYPE" : \IndividualEvent.type,
    "AGE" : \IndividualEvent.age,
    "ADDR" : \IndividualEvent.address,
    "DATE" : \IndividualEvent.date,
    "PHON" : \IndividualEvent.phones,
    "EMAIL" : \IndividualEvent.emails,
    "FAX" : \IndividualEvent.fax,
    "WWW" : \IndividualEvent.www,
    "SDATE" : \IndividualEvent.sdate,
    "PLAC": \IndividualEvent.place,
    "AGNC": \IndividualEvent.agency,
    "RELI": \IndividualEvent.religion,
    "CAUS": \IndividualEvent.cause,
    "RESN" : \IndividualEvent.restrictions,
    "ASSO" : \IndividualEvent.associations,
    "NOTE" : \IndividualEvent.notes,
    "SNOTE" : \IndividualEvent.notes,
    "SOUR" : \IndividualEvent.citations,
    "OBJE" : \IndividualEvent.multimediaLinks,
    "UID" : \IndividualEvent.uid,
    "FAMC" : \IndividualEvent.familyChild,
  ]

  init(kind: IndividualEventKind,
       text: String? = nil,
       occurred: Bool? = nil, // Text == Y
       type: String? = nil,
       familyChild: FamilyChildAdoption? = nil,
       age: Age? = nil,
       date: DateValue? = nil,
       sdate: DateValue? = nil,
       place: PlaceStructure? = nil,
       address: AddressStructure? = nil,
       phones: [String] = [],
       emails: [String] = [],
       fax: [String] = [],
       www: [URL] = [],
       agency: String? = nil,
       religion: String? = nil,
       cause: String? = nil,
       restrictions: [Restriction] = [],
       associations: [AssoiciationStructure] = [],
       notes: [NoteStructure] = [],
       citations: [SourceCitation] = [],
       multimediaLinks: [MultimediaLink] = [],
       uid: [UUID] = []) {

    self.kind = kind
    self.text = text
    self.occurred = occurred ?? false
    self.type = type
    self.familyChild = familyChild
    self.age = age
    self.date = date
    self.sdate = sdate
    self.place = place
    self.address = address
    self.phones = phones
    self.emails = emails
    self.fax = fax
    self.www = www
    self.agency = agency
    self.religion = religion
    self.cause = cause
    self.restrictions = restrictions
    self.associations = associations
    self.notes = notes
    self.citations = citations
    self.multimediaLinks = multimediaLinks
    self.uid = uid

  }
  required init(record: Record) throws {
    self.kind = IndividualEventKind(rawValue: record.line.tag) ?? .EVEN
    if record.line.value == "Y" {
      occurred = true
    } else {
      occurred = false
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

      if let wkp = kp as? WritableKeyPath<IndividualEvent, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<IndividualEvent, Age?> {
        mutableSelf[keyPath: wkp] = try Age(record: child)
      } else if let wkp = kp as? WritableKeyPath<IndividualEvent, DateValue?> {
        mutableSelf[keyPath: wkp] = try DateValue(record: child)
      } else if let wkp = kp as? WritableKeyPath<IndividualEvent, PlaceStructure?> {
        mutableSelf[keyPath: wkp] = try PlaceStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<IndividualEvent, AddressStructure?> {
        mutableSelf[keyPath: wkp] = try AddressStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<IndividualEvent, [String]> {
        mutableSelf[keyPath: wkp].append(child.line.value ?? "")
      } else if let wkp = kp as? WritableKeyPath<IndividualEvent, [URL]> {
        try mutableSelf[keyPath: wkp].append(URL(string: child.line.value ?? "") ?? { throw GedcomError.badURL } ())
      } else if let wkp = kp as? WritableKeyPath<IndividualEvent, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      } else if let wkp = kp as? WritableKeyPath<IndividualEvent, [MultimediaLink]> {
        mutableSelf[keyPath: wkp].append(try MultimediaLink(record: child))
      } else if let wkp = kp as? WritableKeyPath<IndividualEvent, [UUID]> {
        mutableSelf[keyPath: wkp].append(UUID(uuidString: child.line.value!)!)
      } else if let wkp = kp as? WritableKeyPath<IndividualEvent, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<IndividualEvent, [AssoiciationStructure]> {
        mutableSelf[keyPath: wkp].append(try AssoiciationStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<IndividualEvent, [Restriction]> {
        // TODO: This may crash on bad restrictions
        let strings : [String] = (child.line.value?.components(separatedBy: ",").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})) ?? []
        mutableSelf[keyPath: wkp] = strings.map({Restriction(rawValue: $0)!})
      } else if let wkp = kp as? WritableKeyPath<IndividualEvent, FamilyChildAdoption?> {
        mutableSelf[keyPath: wkp] = try FamilyChildAdoption(record: child)
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: kind.rawValue)
    if kind == .EVEN {
      record.line.value = text
    } else if occurred {
      record.line.value = "Y"
    }

    if let type {
      record.children += [Record(level: 1, tag: "TYPE", value: type)]
    }

    if let familyChild {
      record.children += [familyChild.export()]

    }

    if let date {
      record.children += [date.export()]
    }

    if let age {
      record.children += [age.export()]
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

public enum LdsIndividualOrdinanceKind : String {
  case BAPL
  case CONL
  case ENDL
  case INIL
  case SLGC
}

public enum LdsOrdinanceStatusKind : String {
  case BIC
  case CANCELED
  case CHILD
  case COMPLETED
  case EXCLUDED
  case DNS
  case DNS_CAN
  case INFANT
  case PRE_1970
  case STILLBORN
  case SUBMITTED
  case UNCLEARED
}

public class LdsOrdinanceStatus : RecordProtocol {
  public var kind: LdsOrdinanceStatusKind
  public var date: DateTime

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATE" : \LdsOrdinanceStatus.date,
  ]

  init(kind: LdsOrdinanceStatusKind, date: DateTime) {
    self.kind = kind
    self.date = date
  }
  required init(record: Record) throws {
    self.date = DateTime()
    self.kind = LdsOrdinanceStatusKind(rawValue: record.line.value ?? "")!

    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<LdsOrdinanceStatus, DateTime> {
        mutableSelf[keyPath: wkp] = try DateTime(record: child)
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "STAT", value: kind.rawValue)
    record.children += [date.export()]
    return record
  }
}

public class LdsIndividualOrdinance : RecordProtocol {
  public var kind: LdsIndividualOrdinanceKind

  public var date: DateValue?
  public var temple: String?
  public var place: PlaceStructure?

  public var status: LdsOrdinanceStatus?

  public var notes: [NoteStructure] = []
  public var citations: [SourceCitation] = []

  // Only SLGC
  var familyChild: String? // XREF

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATE" : \LdsIndividualOrdinance.date,
    "TEMP" : \LdsIndividualOrdinance.temple,
    "PLAC" : \LdsIndividualOrdinance.place,

    "STAT": \LdsIndividualOrdinance.status,

    "NOTE" : \LdsIndividualOrdinance.notes,
    "SNOTE" : \LdsIndividualOrdinance.notes,

    "SOUR" : \LdsIndividualOrdinance.citations,

    "FAMC" : \LdsIndividualOrdinance.familyChild,
  ]

  init(kind: LdsIndividualOrdinanceKind,
       date: DateValue? = nil,
       temple: String? = nil,
       familyChild: String? = nil,
       place: PlaceStructure? = nil,
       status: LdsOrdinanceStatus? = nil,
       notes: [NoteStructure] = [],
       citations: [SourceCitation] = [])
  {
    self.kind = kind
    self.date = date
    self.temple = temple
    self.familyChild = familyChild
    self.place = place
    self.status = status
    self.notes = notes
    self.citations = citations
  }

  required init(record: Record) throws {
    self.kind = LdsIndividualOrdinanceKind(rawValue: record.line.tag)!

    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<LdsIndividualOrdinance, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<LdsIndividualOrdinance, DateValue?> {
        mutableSelf[keyPath: wkp] = try DateValue(record: child)
      } else if let wkp = kp as? WritableKeyPath<LdsIndividualOrdinance, PlaceStructure?> {
        mutableSelf[keyPath: wkp] = try PlaceStructure(record: child)
      } else if let wkp = kp as? WritableKeyPath<LdsIndividualOrdinance, LdsOrdinanceStatus?> {
        mutableSelf[keyPath: wkp] = try LdsOrdinanceStatus(record: child)
      } else if let wkp = kp as? WritableKeyPath<LdsIndividualOrdinance, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<LdsIndividualOrdinance, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: kind.rawValue)

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

    if let familyChild {
      record.children += [Record(level: 1, tag: "FAMC", value: familyChild)]
    }


    return record
  }
}

public enum NameTypeKind : String {
  case AKA = "AKA"
  case BIRTH = "BIRTH"
  case IMMIGRANT = "IMMIGRANT"
  case MAIDEN = "MAIDEN"
  case MARRIED = "MARRIED"
  case PROFESSIONAL = "PROFESSIONAL"
  case OTHER = "OTHER"
}

public class NameType : RecordProtocol {
  public var kind: NameTypeKind
  public var phrase: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \NameType.phrase,
  ]

  init(kind: NameTypeKind, phrase: String? = nil) {
    self.kind = kind
    self.phrase = phrase
  }
  required init(record: Record) throws {
    self.kind = NameTypeKind(rawValue: record.line.value ?? "OTHER") ?? .OTHER
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<NameType, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "TYPE", value: kind.rawValue)

    if let phrase {
      record.children += [Record(level: 1, tag: "PHRASE", value: phrase)]
    }

    return record
  }
}

public enum PersonalNamePiece : Equatable {
  case NPFX(String)
  case GIVN(String)
  case NICK(String)
  case SPFX(String)
  case SURN(String)
  case NSFX(String)
}

extension PersonalNamePiece {
  func export() -> Record {
    switch self {
    case .NPFX(let s):
      return Record(level: 0, tag: "NPFX", value: s)
    case .GIVN(let s):
      return Record(level: 0, tag: "GIVN", value: s)
    case .NICK(let s):
      return Record(level: 0, tag: "NICK", value: s)
    case .SPFX(let s):
      return Record(level: 0, tag: "SPFX", value: s)
    case .SURN(let s):
      return Record(level: 0, tag: "SURN", value: s)
    case .NSFX(let s):
      return Record(level: 0, tag: "NSFX", value: s)
    }
  }
}

public class PersonalNameTranslation  : RecordProtocol {
  public var name: String
  public var lang: String = ""
  public var namePieces : [PersonalNamePiece] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "LANG" : \PersonalNameTranslation.lang,
    "NPFX" : \PersonalNameTranslation.namePieces,
    "GIVN" : \PersonalNameTranslation.namePieces,
    "NICK" : \PersonalNameTranslation.namePieces,
    "SPFX" : \PersonalNameTranslation.namePieces,
    "SURN" : \PersonalNameTranslation.namePieces,
    "NSFX" : \PersonalNameTranslation.namePieces,
  ]

  init(name: String, lang: String, namePieces: [PersonalNamePiece] = []) {
    self.name = name
    self.lang = lang
    self.namePieces = namePieces
  }

  required init(record: Record) throws {
    self.name = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<PersonalNameTranslation, String> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<PersonalNameTranslation, [PersonalNamePiece]> {
        switch (child.line.tag) {
        case "NPFX":
          mutableSelf[keyPath: wkp].append(.NPFX(child.line.value ?? ""))
        case "GIVN":
          mutableSelf[keyPath: wkp].append(.GIVN(child.line.value ?? ""))
        case "NICK":
          mutableSelf[keyPath: wkp].append(.NICK(child.line.value ?? ""))
        case "SPFX":
          mutableSelf[keyPath: wkp].append(.SPFX(child.line.value ?? ""))
        case "SURN":
          mutableSelf[keyPath: wkp].append(.SURN(child.line.value ?? ""))
        case "NSFX":
          mutableSelf[keyPath: wkp].append(.NSFX(child.line.value ?? ""))
        default:
          throw GedcomError.badNamePiece
        }
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "TRAN", value: name)
    record.children += [Record(level: 1, tag: "LANG", value: lang)]

    for namePiece in namePieces {
      record.children += [namePiece.export()]
    }

    return record
  }
}

public class PersonalName  : RecordProtocol {
  public var name: String
  public var type: NameType?
  public var namePieces : [PersonalNamePiece] = []
  public var translations : [PersonalNameTranslation] = []
  public var notes: [NoteStructure] = []
  public var citations: [SourceCitation] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TYPE" : \PersonalName.type,
    "NPFX" : \PersonalName.namePieces,
    "GIVN" : \PersonalName.namePieces,
    "NICK" : \PersonalName.namePieces,
    "SPFX" : \PersonalName.namePieces,
    "SURN" : \PersonalName.namePieces,
    "NSFX" : \PersonalName.namePieces,
    "TRAN" : \PersonalName.translations,
    "NOTE" : \PersonalName.notes,
    "SNOTE" : \PersonalName.notes,
    "SOUR" : \PersonalName.citations,
  ]

  init(name: String, type: NameType? = nil,
       namePieces : [PersonalNamePiece] = [],
       translations : [PersonalNameTranslation] = [],
       notes: [NoteStructure] = [],
       citations: [SourceCitation] = []) {
    self.name = name
    self.type = type
    self.namePieces = namePieces
    self.translations = translations
    self.notes = notes
    self.citations = citations    
  }
  required init(record: Record) throws {
    self.name = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<PersonalName, [PersonalNamePiece]> {
        switch (child.line.tag) {
        case "NPFX":
          mutableSelf[keyPath: wkp].append(.NPFX(child.line.value ?? ""))
        case "GIVN":
          mutableSelf[keyPath: wkp].append(.GIVN(child.line.value ?? ""))
        case "NICK":
          mutableSelf[keyPath: wkp].append(.NICK(child.line.value ?? ""))
        case "SPFX":
          mutableSelf[keyPath: wkp].append(.SPFX(child.line.value ?? ""))
        case "SURN":
          mutableSelf[keyPath: wkp].append(.SURN(child.line.value ?? ""))
        case "NSFX":
          mutableSelf[keyPath: wkp].append(.NSFX(child.line.value ?? ""))
        default:
          throw GedcomError.badNamePiece
        }
      } else if let wkp = kp as? WritableKeyPath<PersonalName, [PersonalNameTranslation]> {
        mutableSelf[keyPath: wkp].append(try PersonalNameTranslation(record: child))
      } else if let wkp = kp as? WritableKeyPath<PersonalName, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<PersonalName, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      } else if let wkp = kp as? WritableKeyPath<PersonalName, NameType?> {
        mutableSelf[keyPath: wkp] = try NameType(record: child)
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "NAME", value: name)

    if let type {
      record.children += [type.export()]
    }

    for namePiece in namePieces {
      record.children += [namePiece.export()]
    }

    for translation in translations {
      record.children += [translation.export()]
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


public enum PedigreeKind : String {
  case ADOPTED
  case BIRTH
  case FOSTER
  case SEALING
  case OTHER // TODO: Needs payload
}

public class Pedigree : RecordProtocol {
  public var kind: PedigreeKind
  public var phrase: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \Pedigree.phrase,
  ]
  init(kind: PedigreeKind,
       phrase: String? = nil) {
    self.kind = kind
    self.phrase = phrase
  }

  required init(record: Record) throws {
    self.kind = PedigreeKind(rawValue: record.line.value ?? "OTHER") ?? .OTHER
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Pedigree, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "PEDI", value: kind.rawValue)
    if let phrase {
      record.children += [Record(level: 1, tag: "PHRASE", value: phrase)]
    }
    return record
  }
}

public enum ChildStatusKind : String {
  case CHALLENGED
  case DISPROVEN
  case PROVEN
}
public enum AdoptionKind : String {
  case HUSB
  case WIFE
  case BOTH
}
public class FamilyChildAdoptionKind : RecordProtocol {
  public var kind: AdoptionKind
  public var phrase: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \FamilyChildAdoptionKind.phrase,
  ]

  init(kind: AdoptionKind, phrase: String? = nil) {
    self.kind = kind
    self.phrase = phrase
  }
  required init(record: Record) throws {
    self.kind = AdoptionKind(rawValue: record.line.value ?? "") ?? .BOTH
    var mutableSelf = self
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<FamilyChildAdoptionKind, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "ADOP", value: kind.rawValue)
    if let phrase {
      record.children += [Record(level: 1, tag: "PHRASE", value: phrase)]
    }
    return record
  }
}

public class FamilyChildAdoption : RecordProtocol {
  public var xref: String
  public var adoption: FamilyChildAdoptionKind?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "ADOP" : \FamilyChildAdoption.adoption,
  ]

  init(xref: String, adoption: FamilyChildAdoptionKind? = nil) {
    self.xref = xref
    self.adoption = adoption
  }
  required init(record: Record) throws {
    self.xref = record.line.value ?? ""
    var mutableSelf = self
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<FamilyChildAdoption, FamilyChildAdoptionKind?> {
        mutableSelf[keyPath: wkp] = try FamilyChildAdoptionKind(record: child)
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "FAMC", value: xref)
    if let adoption {
      record.children += [adoption.export()]
    }
    return record
  }
}

public class ChildStatus : RecordProtocol {
  public var kind: ChildStatusKind
  public var phrase: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \ChildStatus.phrase,
  ]

  init(kind: ChildStatusKind, phrase: String? = nil) {
    self.kind = kind
    self.phrase = phrase
  }
  required init(record: Record) throws {
    self.kind = ChildStatusKind(rawValue: record.line.value ?? "") ?? .CHALLENGED
    var mutableSelf = self
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<ChildStatus, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "STAT", value: kind.rawValue)
    if let phrase {
      record.children += [Record(level: 1, tag: "PHRASE", value: phrase)]
    }
    return record
  }
}

public class FamilyChild : RecordProtocol {
  public var xref: String
  public var pedigree: Pedigree?
  public var status: ChildStatus?
  public var notes: [NoteStructure] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PEDI" : \FamilyChild.pedigree,
    "STAT" : \FamilyChild.status,

    "NOTE" : \FamilyChild.notes,
    "SNOTE" : \FamilyChild.notes,
  ]

  init(xref: String,
       pedigree: Pedigree? = nil,
       status: ChildStatus? = nil,
       notes: [NoteStructure] = []) {
    self.xref = xref
    self.pedigree = pedigree
    self.status = status
    self.notes = notes
  }
  required init(record: Record) throws {
    self.xref = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<FamilyChild, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<FamilyChild, Pedigree?> {
        mutableSelf[keyPath: wkp] = try Pedigree(record: child)
      } else if let wkp = kp as? WritableKeyPath<FamilyChild, ChildStatus?> {
        mutableSelf[keyPath: wkp] = try ChildStatus(record: child)
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "FAMC", value: xref)

    if let pedigree {
      record.children += [pedigree.export()]
    }
    if let status {
      record.children += [status.export()]
    }

    for note in notes  {
      record.children += [note.export()]
    }
    return record
  }
}
public class FamilySpouse : RecordProtocol {
  public var xref: String
  public var notes: [NoteStructure] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "NOTE" : \FamilySpouse.notes,
    "SNOTE" : \FamilySpouse.notes,
  ]

  init(xref: String, notes: [NoteStructure] = [])
  {
    self.xref = xref
    self.notes = notes
  }
  required init(record: Record) throws {
    self.xref = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<FamilySpouse, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "FAMS", value: xref)
    for note in notes  {
      record.children += [note.export()]
    }
    return record
  }
}

public enum RoleKind : String {
  case CHIL
  case CLERGY
  case FATH
  case FRIEND
  case GODP
  case HUSB
  case MOTH
  case MULTIPLE
  case NGHBR
  case OFFICIATOR
  case PARENT
  case SPOU
  case WIFE
  case WITN
  case OTHER
}

public class Role : RecordProtocol {
  public var kind: RoleKind
  public var phrase: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \Role.phrase,
  ]

  init(kind: RoleKind, phrase: String? = nil) {
    self.kind = kind
    self.phrase = phrase
  }
  required init(record: Record) throws {
    self.kind = RoleKind(rawValue: record.line.value ?? "OTHER") ?? .OTHER
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Role, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "ROLE", value: kind.rawValue)
    if let phrase = phrase {
      record.children += [Record(level: 1, tag: "PHRASE", value: phrase)]
    }
    return record
  }
}

public class AssoiciationStructure : RecordProtocol {
  public var xref: String
  public var phrase: String?
  public var role: Role?
  public var notes: [NoteStructure] = []
  public var citations: [SourceCitation] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \AssoiciationStructure.phrase,
    "ROLE" : \AssoiciationStructure.role,
    "NOTE" : \AssoiciationStructure.notes,
    "SNOTE" : \AssoiciationStructure.notes,
    "SOUR" : \AssoiciationStructure.citations,
  ]

  init(xref: String, phrase: String? = nil,
       role: Role? = nil,
       notes: [NoteStructure] = [],
       citations: [SourceCitation] = []) {
    self.xref = xref
    self.phrase = phrase
    self.role = role
    self.notes = notes
    self.citations = citations
  }

  required init(record: Record) throws {
    self.xref = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<AssoiciationStructure, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<AssoiciationStructure, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<AssoiciationStructure, Role?> {
        mutableSelf[keyPath: wkp] = try Role(record: child)
      } else if let wkp = kp as? WritableKeyPath<AssoiciationStructure, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: "ASSO", value: xref)

    if let phrase {
      record.children += [Record(level: 1, tag: "PHRASE", value: phrase)]
    }

    if let role {
      record.children += [role.export()]

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
public class PhraseRef : RecordProtocol {
  public var tag: String
  public var xref: String
  public var phrase: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \PhraseRef.phrase,
  ]

  init(tag: String, xref: String, phrase: String? = nil) {
    self.tag = tag
    self.xref = xref
    self.phrase = phrase
  }
  required init(record: Record) throws {
    self.tag = record.line.tag
    self.xref = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<PhraseRef, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record {
    let record = Record(level: 0, tag: tag, value: xref)

    if let phrase {
      record.children += [Record(level: 1, tag: "PHRASE", value: phrase)]
    }

    return record
  }
}

public enum Sex : String {
  case male = "M"
  case female = "F"
  case other = "X"
  case unknown = "U"
}

public class Individual : RecordProtocol {
  public var xref: String

  public var restrictions: [Restriction] = []
  public var names: [PersonalName] = []
  public var sex: Sex?

  public var attributes: [IndividualAttributeStructure] = []
  public var events: [IndividualEvent] = []
  public var nonEvents: [NonEventStructure] = []
  public var ldsDetails: [LdsIndividualOrdinance] = []

  public var childOfFamilies: [FamilyChild] = []
  public var spouseFamilies: [FamilySpouse] = []

  public var submitters: [String] = []
  public var associations: [AssoiciationStructure] = []
  public var aliases: [PhraseRef] = []
  public var ancestorInterest: [String] = []
  public var decendantInterest: [String] = []

  public var identifiers: [IdentifierStructure] = []
  public var notes: [NoteStructure] = []
  public var citations: [SourceCitation] = []
  public var multimediaLinks: [MultimediaLink] = []
  public var changeDate: ChangeDate?
  public var creationDate: CreationDate?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "RESN" : \Individual.restrictions,
    "NAME" : \Individual.names,
    "SEX" : \Individual.sex,

    "CAST": \Individual.attributes,
    "DSCR" : \Individual.attributes,
    "EDUC" : \Individual.attributes,
    "IDNO" : \Individual.attributes,
    "NATI" : \Individual.attributes,
    "NCHI" : \Individual.attributes,
    "NMR" : \Individual.attributes,
    "OCCU" : \Individual.attributes,
    "PROP" : \Individual.attributes,
    "RELI" : \Individual.attributes,
    "RESI" : \Individual.attributes,
    "SSN" : \Individual.attributes,
    "TITL" : \Individual.attributes,
    "FACT" : \Individual.attributes,

    "ADOP" : \Individual.events,
    "BAPM" : \Individual.events,
    "BARM" : \Individual.events,
    "BASM" : \Individual.events,
    "BIRT" : \Individual.events,
    "BLES" : \Individual.events,
    "BURI" : \Individual.events,
    "CENS" : \Individual.events,
    "CHR" : \Individual.events,
    "CHRA" : \Individual.events,
    "CONF" : \Individual.events,
    "CREM" : \Individual.events,
    "DEAT" : \Individual.events,
    "EMIG" : \Individual.events,
    "FCOM" : \Individual.events,
    "GRAD" : \Individual.events,
    "IMMI" : \Individual.events,
    "NATU" : \Individual.events,
    "ORDN" : \Individual.events,
    "PROB" : \Individual.events,
    "RETI" : \Individual.events,
    "WILL" : \Individual.events,
    "EVEN" : \Individual.events,

    "NO" : \Individual.nonEvents,

    "BAPL" : \Individual.ldsDetails,
    "CONL" : \Individual.ldsDetails,
    "ENDL" : \Individual.ldsDetails,
    "INIL" : \Individual.ldsDetails,
    "SLGC" : \Individual.ldsDetails,

    "FAMC" : \Individual.childOfFamilies,
    "FAMS" : \Individual.spouseFamilies,

    "SUBM" : \Individual.submitters,
    "ASSO" : \Individual.associations,

    "ALIA" : \Individual.aliases,
    "ANCI" : \Individual.ancestorInterest,
    "DESI" : \Individual.decendantInterest,

    "REFN" : \Individual.identifiers,
    "UID" : \Individual.identifiers,
    "EXID" : \Individual.identifiers,

    "NOTE" : \Individual.notes,
    "SNOTE" : \Individual.notes,

    "SOUR" : \Individual.citations,
    "OBJE" : \Individual.multimediaLinks,

    "CHAN" : \Individual.changeDate,
    "CREA" : \Individual.creationDate

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

      if let wkp = kp as? WritableKeyPath<Individual, [String]> {
        mutableSelf[keyPath: wkp].append(child.line.value ?? "")
      } else if let wkp = kp as? WritableKeyPath<Individual, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<Individual, [LdsIndividualOrdinance]> {
        mutableSelf[keyPath: wkp].append(try LdsIndividualOrdinance(record: child))
      } else if let wkp = kp as? WritableKeyPath<Individual, [IndividualAttributeStructure]> {
        mutableSelf[keyPath: wkp].append(try IndividualAttributeStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Individual, [IndividualEvent]> {
        mutableSelf[keyPath: wkp].append(try IndividualEvent(record: child))
      } else if let wkp = kp as? WritableKeyPath<Individual, [NonEventStructure]> {
        mutableSelf[keyPath: wkp].append(try NonEventStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Individual, [Restriction]> {
        // TODO: This may crash on bad restrictions
        let strings : [String] = (child.line.value?.components(separatedBy: ",").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})) ?? []
        mutableSelf[keyPath: wkp] = strings.map({Restriction(rawValue: $0)!})
      } else if let wkp = kp as? WritableKeyPath<Individual, Sex?> {
        mutableSelf[keyPath: wkp] = Sex(rawValue: child.line.value ?? "") ?? .unknown
      } else if let wkp = kp as? WritableKeyPath<Individual, [PersonalName]> {
        mutableSelf[keyPath: wkp].append(try PersonalName(record: child))
      } else if let wkp = kp as? WritableKeyPath<Individual, [FamilyChild]> {
        mutableSelf[keyPath: wkp].append(try FamilyChild(record: child))
      } else if let wkp = kp as? WritableKeyPath<Individual, [FamilySpouse]> {
        mutableSelf[keyPath: wkp].append(try FamilySpouse(record: child))
      } else if let wkp = kp as? WritableKeyPath<Individual, [AssoiciationStructure]> {
        mutableSelf[keyPath: wkp].append(try AssoiciationStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Individual, [PhraseRef]> {
        mutableSelf[keyPath: wkp].append(try PhraseRef(record: child))
      } else if let wkp = kp as? WritableKeyPath<Individual, [IdentifierStructure]> {
        mutableSelf[keyPath: wkp].append(try IdentifierStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Individual, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Individual, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      } else if let wkp = kp as? WritableKeyPath<Individual, [MultimediaLink]> {
        mutableSelf[keyPath: wkp].append(try MultimediaLink(record: child))
      } else if let wkp = kp as? WritableKeyPath<Individual, CreationDate?> {
        mutableSelf[keyPath: wkp] = try CreationDate(record: child)
      } else if let wkp = kp as? WritableKeyPath<Individual, ChangeDate?> {
        mutableSelf[keyPath: wkp] = try ChangeDate(record: child)
      }
    }
  }


  func export() -> Record {
    let record = Record(level: 0, xref: xref, tag: "INDI")


    if restrictions.count > 0 {
      record.children += [Record(level: 1, tag: "RESN",
                                 value: restrictions.map({$0.rawValue}).joined(separator: ", "))]

    }

    for name in names {
      record.children += [name.export()]
    }

    if let sex {
      record.children += [Record(level: 0, tag: "SEX", value: sex.rawValue)]
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

    for ldsDetail in ldsDetails {
      record.children += [ldsDetail.export()]
    }

    for childOfFamily in childOfFamilies {
      record.children += [childOfFamily.export()]
    }

    for spouseOfFamily in spouseFamilies {
      record.children += [spouseOfFamily.export()]
    }

    for submitter in submitters {
      record.children += [Record(level: 0, tag: "SUBM", value: submitter)]
    }

    for association in associations {
      record.children += [association.export()]
    }

    for alias in aliases {
      record.children += [alias.export()]
    }

    for ancestorInterest in ancestorInterest {
      record.children += [Record(level: 0, tag: "ANCI", value: ancestorInterest)]
    }

    for decendantInterest in decendantInterest {
      record.children += [Record(level: 0, tag: "DESI", value: decendantInterest)]
    }

    for identifier in identifiers {
      record.children += [identifier.export()]
    }

    for note in notes {
      record.children += [note.export()]
    }

    for multimediaLink in multimediaLinks {
      record.children += [multimediaLink.export()]
    }

    for citation in citations {
      record.children += [citation.export()]
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
