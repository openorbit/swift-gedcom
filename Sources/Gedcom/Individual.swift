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
  var age: String
  var phrase: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "PHRASE" : \Age.phrase,
  ]


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

public enum IndividualAttributes : String {
  case cast = "CAST"
  case physicalDescription = "DSCR"
  case education = "EDUC"
  case identifyingNumber = "IDNO"
  case nationality = "NATI"
  case numberOfChildren = "NCHI"
  case numberOfMarriages = "NMR"
  case occupation = "OCCU"
  case property = "PROP"
  case religion = "RELI"
  case residence = "RESI"
  case socialSecurityNumber = "SSN"
  case title = "TITL"
  case fact = "FACT"
}

public class IndividualAttributeStructure  : RecordProtocol {
  public var attr: IndividualAttributes
  public var type: String?

  public var date: DateValue?
  public var place: PlaceStructure?
  public var address: AddressStructure?
  public var phone: [String] = []
  public var email: [String] = []
  public var fax: [String] = []
  public var www: [String] = []

  public var agency: String?
  public var religion: String?
  public var cause: String? // TODO: Is this correct
  public var restriction : Restriction?


  public var sdate: DateValue?
  public var associations: [AssoiciationStructure] = []
  public var notes: [NoteStructure] = []
  public var citations: [SourceCitation] = []
  public var multimediaLinks: [MultimediaLink] = []
  public var uids: [UID] = []

  public var age: Age? // TODO: With phrase

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
    "RESN" : \IndividualAttributeStructure.restriction,
    "SDATE" : \IndividualAttributeStructure.sdate,
    "ASSOC" : \IndividualAttributeStructure.associations,
    "NOTE" : \IndividualAttributeStructure.notes,
    "SNOTE" : \IndividualAttributeStructure.notes,
    "SOUR" : \IndividualAttributeStructure.citations,
    "OBJ" : \IndividualAttributeStructure.multimediaLinks,
    "UID" : \IndividualAttributeStructure.uids,
    // Individual attributes
    "AGE" : \IndividualAttributeStructure.age,
  ]

  required init(record: Record) throws {
    self.attr = IndividualAttributes(rawValue: record.line.value ?? "")!
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<IndividualAttributeStructure, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }
}



enum IndividualEventKind : String {
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

public class IndividualEvent : RecordProtocol {
  var kind: IndividualEventKind
  var text: String?
  var occured: Bool // Text == Y
  var type: String?

  // ADOP specific
  var familyChild: FamilyChildAdoption?

  // Individual event detail
  var age: Age?
  // Event detail
  // n <<DATE_VALUE>>                           {0:1}
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
        mutableSelf[keyPath: wkp].append(URL(string: child.line.value!)!)
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

// Name type: AKA, BIRTH, IMMIGRANT, MAIDEN, MARRIED, PROFESSIONAL, OTHER
public class PersonalName  : RecordProtocol {
  public var name: String
  public var type: NameType? // TODO: Substructure with phrase
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


/*
 INDIVIDUAL_ATTRIBUTE_STRUCTURE :=

 n CAST <Text>                              {1:1}  g7:CAST
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n DSCR <Text>                              {1:1}  g7:DSCR
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n EDUC <Text>                              {1:1}  g7:EDUC
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n IDNO <Special>                           {1:1}  g7:IDNO
   +1 TYPE <Text>                           {1:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n NATI <Text>                              {1:1}  g7:NATI
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n NCHI <Integer>                           {1:1}  g7:INDI-NCHI
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n NMR <Integer>                            {1:1}  g7:NMR
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n OCCU <Text>                              {1:1}  g7:OCCU
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n PROP <Text>                              {1:1}  g7:PROP
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n RELI <Text>                              {1:1}  g7:INDI-RELI
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n RESI <Text>                              {1:1}  g7:INDI-RESI
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n SSN <Special>                            {1:1}  g7:SSN
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n TITL <Text>                              {1:1}  g7:INDI-TITL
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n FACT <Text>                              {1:1}  g7:INDI-FACT
   +1 TYPE <Text>                           {1:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 ]

 */

/*INDIVIDUAL_EVENT_STRUCTURE
 n ADOP [Y|<NULL>]                          {1:1}  g7:ADOP
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
   +1 FAMC @<XREF:FAM>@                     {0:1}  g7:ADOP-FAMC
      +2 ADOP <Enum>                        {0:1}  g7:FAMC-ADOP
         +3 PHRASE <Text>                   {0:1}  g7:PHRASE
 |
 n BAPM [Y|<NULL>]                          {1:1}  g7:BAPM
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n BARM [Y|<NULL>]                          {1:1}  g7:BARM
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n BASM [Y|<NULL>]                          {1:1}  g7:BASM
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n BIRT [Y|<NULL>]                          {1:1}  g7:BIRT
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
   +1 FAMC @<XREF:FAM>@                     {0:1}  g7:FAMC
 |
 n BLES [Y|<NULL>]                          {1:1}  g7:BLES
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n BURI [Y|<NULL>]                          {1:1}  g7:BURI
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n CENS [Y|<NULL>]                          {1:1}  g7:INDI-CENS
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n CHR [Y|<NULL>]                           {1:1}  g7:CHR
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
   +1 FAMC @<XREF:FAM>@                     {0:1}  g7:FAMC
 |
 n CHRA [Y|<NULL>]                          {1:1}  g7:CHRA
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n CONF [Y|<NULL>]                          {1:1}  g7:CONF
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n CREM [Y|<NULL>]                          {1:1}  g7:CREM
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n DEAT [Y|<NULL>]                          {1:1}  g7:DEAT
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n EMIG [Y|<NULL>]                          {1:1}  g7:EMIG
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n FCOM [Y|<NULL>]                          {1:1}  g7:FCOM
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n GRAD [Y|<NULL>]                          {1:1}  g7:GRAD
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n IMMI [Y|<NULL>]                          {1:1}  g7:IMMI
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n NATU [Y|<NULL>]                          {1:1}  g7:NATU
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n ORDN [Y|<NULL>]                          {1:1}  g7:ORDN
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n PROB [Y|<NULL>]                          {1:1}  g7:PROB
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n RETI [Y|<NULL>]                          {1:1}  g7:RETI
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n WILL [Y|<NULL>]                          {1:1}  g7:WILL
   +1 TYPE <Text>                           {0:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 |
 n EVEN <Text>                              {1:1}  g7:INDI-EVEN
   +1 TYPE <Text>                           {1:1}  g7:TYPE
   +1 <<INDIVIDUAL_EVENT_DETAIL>>           {0:1}
 ]
*/

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
    "PHRASE" : \NameType.phrase,
  ]

  required init(record: Record) throws {
    self.kind = RoleKind(rawValue: record.line.value ?? "OTHER") ?? .OTHER
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Role, String> {
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
  ]
  public var xref: String
  public var phrase: String?
  public var role: Role?
  public var notes: [NoteStructure] = []

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

    "CAST": \Individual.individualAttributes,
    "DSCR" : \Individual.individualAttributes,
    "EDUC" : \Individual.individualAttributes,
    "IDNO" : \Individual.individualAttributes,
    "NATI" : \Individual.individualAttributes,
    "NCHI" : \Individual.individualAttributes,
    "NMR" : \Individual.individualAttributes,
    "OCCU" : \Individual.individualAttributes,
    "PROP" : \Individual.individualAttributes,
    "RELI" : \Individual.individualAttributes,
    "RESI" : \Individual.individualAttributes,
    "SSN" : \Individual.individualAttributes,
    "TITL" : \Individual.individualAttributes,
    "FACT" : \Individual.individualAttributes,

    "ADOP" : \Individual.individualEvents,
    "BAPM" : \Individual.individualEvents,
    "BARM" : \Individual.individualEvents,
    "BASM" : \Individual.individualEvents,
    "BIRT" : \Individual.individualEvents,
    "BLES" : \Individual.individualEvents,
    "BURI" : \Individual.individualEvents,
    "CENS" : \Individual.individualEvents,
    "CHR" : \Individual.individualEvents,
    "CHRA" : \Individual.individualEvents,
    "CONF" : \Individual.individualEvents,
    "CREM" : \Individual.individualEvents,
    "DEAT" : \Individual.individualEvents,
    "EMIG" : \Individual.individualEvents,
    "FCOM" : \Individual.individualEvents,
    "GRAD" : \Individual.individualEvents,
    "IMMI" : \Individual.individualEvents,
    "NATU" : \Individual.individualEvents,
    "ORDN" : \Individual.individualEvents,
    "PROB" : \Individual.individualEvents,
    "RETI" : \Individual.individualEvents,
    "WILL" : \Individual.individualEvents,
    "EVEN" : \Individual.individualEvents,

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

  public var individualAttributes: [String] = []// TODO
  public var individualEvents: [IndividualEvent] = []
  public var nonEvents: [String] = [] // TODO
  public var ldsDetails: [String] = [] // TODO

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
      } else if let wkp = kp as? WritableKeyPath<Individual, [IndividualEvent]> {
        mutableSelf[keyPath: wkp].append(try IndividualEvent(record: child))
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
