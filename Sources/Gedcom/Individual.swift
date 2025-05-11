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
  public var phone: [String] = []
  public var email: [String] = []
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
    "PHON" : \IndividualAttributeStructure.phone,
    "EMAIL" : \IndividualAttributeStructure.email,
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
}

public class IndividualEvent : RecordProtocol {
  public var kind: IndividualEventKind
  public var text: String?
  public var occured: Bool // Text == Y
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
  public var phone: [String] = []
  public var email: [String] = []
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
    "PHON" : \IndividualEvent.phone,
    "EMAIL" : \IndividualEvent.email,
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


  required init(record: Record) throws {
    self.kind = IndividualEventKind(rawValue: record.line.tag) ?? .EVEN
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
  var kind: LdsOrdinanceStatusKind

  // TODO: date should be non-optional
  var date: DateTime
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATE" : \LdsOrdinanceStatus.date,
  ]

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
}

public class LdsIndividualOrdinance : RecordProtocol {
  var kind: LdsIndividualOrdinanceKind

  var date: DateValue?
  var temple: String?
  var place: PlaceStructure?

  var status: LdsOrdinanceStatus?

  var notes: [NoteStructure] = []
  var citations: [SourceCitation] = []

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
  var kind: NameTypeKind
  var phrase: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \NameType.phrase,
  ]

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
}

public enum PersonalNamePiece : Equatable {
  case NPFX(String)
  case GIVN(String)
  case NICK(String)
  case SPFX(String)
  case SURN(String)
  case NSFX(String)
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

  required init(record: Record) throws {
    self.name = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<PersonalName, [String]?> {
      } else if let wkp = kp as? WritableKeyPath<PersonalName, String?> {
      } else if let wkp = kp as? WritableKeyPath<PersonalName, [PersonalNamePiece]> {
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
}


public enum PedigreeKind : String {
  case ADOPTED
  case BIRTH
  case FOSTER
  case SEALING
  case OTHER // TODO: Needs payload
}

public class Pedigree : RecordProtocol {
  var kind: PedigreeKind
  var phrase: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \Pedigree.phrase,
  ]

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
}

public class FamilyChildAdoption : RecordProtocol {
  public var xref: String
  public var adoption: FamilyChildAdoptionKind?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "ADOP" : \FamilyChildAdoption.adoption,
  ]

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
}

public class ChildStatus : RecordProtocol {
  public var kind: ChildStatusKind
  public var phrase: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \ChildStatus.phrase,
  ]

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
}

public class FamilyChild : RecordProtocol {
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PEDI" : \FamilyChild.pedigree,
    "STAT" : \FamilyChild.status,

    "NOTE" : \FamilyChild.notes,
    "SNOTE" : \FamilyChild.notes,
  ]
  public var xref: String
  public var pedigree: Pedigree?
  public var status: ChildStatus?
  public var notes: [NoteStructure] = []

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
}
public class FamilySpouse : RecordProtocol {
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "NOTE" : \FamilySpouse.notes,
    "SNOTE" : \FamilySpouse.notes,
  ]
  public var xref: String
  public var notes: [NoteStructure] = []

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
  var kind: RoleKind
  var phrase: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \Role.phrase,
  ]

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
}

/*
n ASSO @<XREF:INDI>@                       {1:1}  g7:ASSO
  +1 PHRASE <Text>                         {0:1}  g7:PHRASE
  +1 ROLE <Enum>                           {1:1}  g7:ROLE
     +2 PHRASE <Text>                      {0:1}  g7:PHRASE
  +1 <<NOTE_STRUCTURE>>                    {0:M}
  +1 <<SOURCE_CITATION>>                   {0:M}
*/
public class AssoiciationStructure : RecordProtocol {
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \AssoiciationStructure.phrase,
    "ROLE" : \AssoiciationStructure.role,
    "NOTE" : \AssoiciationStructure.notes,
    "SNOTE" : \AssoiciationStructure.notes,
    "SOUR" : \AssoiciationStructure.citations,
  ]
  public var xref: String
  public var phrase: String?
  public var role: Role?
  public var notes: [NoteStructure] = []
  public var citations: [SourceCitation] = []

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
}
public class PhraseRef : RecordProtocol {
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \PhraseRef.phrase,
  ]
  public var xref: String
  public var phrase: String?

  required init(record: Record) throws {
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
}

public enum Sex : String {
  case male = "M"
  case female = "F"
  case other = "X"
  case unknown = "U"
}

public class Individual : RecordProtocol {
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

  required init(record: Record) throws {
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


/*
  n @XREF:INDI@ INDI {1:1} g7:record-INDI
  +1 <<INDIVIDUAL_ATTRIBUTE_STRUCTURE>> {0:M}
  +1 <<INDIVIDUAL_EVENT_STRUCTURE>> {0:M}
  +1 <<NON_EVENT_STRUCTURE>> {0:M}
  +1 <<LDS_INDIVIDUAL_ORDINANCE>> {0:M}
*/
}
