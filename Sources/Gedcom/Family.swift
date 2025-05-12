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
  var date: DateValue?
  var temple: String?
  var place: PlaceStructure?

  var status: LdsOrdinanceStatus?

  var notes: [NoteStructure] = []
  var citations: [SourceCitation] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATE" : \LdsSpouseSealing.date,
    "TEMP" : \LdsSpouseSealing.temple,
    "PLAC" : \LdsSpouseSealing.place,

    "STAT": \LdsSpouseSealing.status,

    "NOTE" : \LdsSpouseSealing.notes,
    "SNOTE" : \LdsSpouseSealing.notes,

    "SOUR" : \LdsSpouseSealing.citations,
  ]


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


  func export() -> Record? {
    return nil
  }
}


public class SpouseAge : RecordProtocol {
  public var age: Age

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "AGE" : \SpouseAge.age,
  ]

  required init(record: Record) throws {
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

  func export() -> Record? {
    return nil
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
    "HUSB" : \FamilyAttribute.husbandInfo,
    "WIFE" : \FamilyAttribute.wifeInfo,

    // Event attributes
    "TYPE" : \FamilyAttribute.type,
    "DATE" : \FamilyAttribute.date,
    "ADDR" : \FamilyAttribute.address,
    "PLACE" : \FamilyAttribute.place,
    "PHON" : \FamilyAttribute.phone,
    "EMAIL" : \FamilyAttribute.email,
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

  func export() -> Record? {
    return nil
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

  func export() -> Record? {
    return nil
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
    "HUSB" : \FamilyEvent.husbandInfo,
    "WIFE" : \FamilyEvent.wifeInfo,

    "TYPE" : \FamilyEvent.type,

    "ADDR" : \FamilyEvent.address,
    "DATE" : \FamilyEvent.date,
    "PHON" : \FamilyEvent.phone,
    "EMAIL" : \FamilyEvent.email,
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

  func export() -> Record? {
    return nil
  }
}

public class Family : RecordProtocol {
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

  func export() -> Record? {
    return nil
  }
}
