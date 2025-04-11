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

enum IndividualAttributes : String {
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

enum IndividualEvent : String {
  case adoption = "ADOP"
  case baptism = "BAPM"
  case barMitzvah = "BARM"
  case masMitzvah = "BASM"
  case birth = "BIRT"
  case blessing = "BLES"
  case burial = "BURI"
  case census = "CENS"
  case christening = "CHR"
  case adultChristening = "CHRA"
  case confirmation = "CONF"
  case cremation = "CREM"
  case death = "DEAT"
  case emigration = "EMIG"
  case firstCommunion = "FCOM"
  case graduation = "GRAD"
  case immigration = "IMMI"
  case naturalization = "NATU"
  case ordination = "ORDN"
  case probate = "PROB"
  case retirement = "RETI"
  case will = "WILL"
  case event = "EVEN"
}


// Name type: AKA, BIRTH, IMMIGRANT, MAIDEN, MARRIED, PROFESSIONAL, OTHER
public class PersonalName {
  public var type: String?
}


public class Individual : RecordProtocol {
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "RESN" : \Individual.resn,
    "SEX" : \Individual.sex
  ]
  public var resn: [String]?
  // name structures
  public var sex: String?
  public var multimediaLinks: [MultimediaLink] = []

  required init(record: Record) throws {
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      print("\(child.line.tag)")

      if let wkp = kp as? WritableKeyPath<Individual, [String]?> {
      } else if let wkp = kp as? WritableKeyPath<Individual, String?> {
      }
    }

  }

/*
  n @XREF:INDI@ INDI {1:1} g7:record-INDI
  +1 RESN <List:Enum> {0:1} g7:RESN
  +1 <<PERSONAL_NAME_STRUCTURE>> {0:M}
  +1 SEX <Enum> {0:1} g7:SEX
  +1 <<INDIVIDUAL_ATTRIBUTE_STRUCTURE>> {0:M}
  +1 <<INDIVIDUAL_EVENT_STRUCTURE>> {0:M}
  +1 <<NON_EVENT_STRUCTURE>> {0:M}
  +1 <<LDS_INDIVIDUAL_ORDINANCE>> {0:M}
  +1 FAMC @<XREF:FAM>@ {0:M} g7:INDI-FAMC
  +2 PEDI <Enum> {0:1} g7:PEDI
  +3 PHRASE <Text> {0:1} g7:PHRASE
  +2 STAT <Enum> {0:1} g7:FAMC-STAT
  +3 PHRASE <Text> {0:1} g7:PHRASE
  +2 <<NOTE_STRUCTURE>> {0:M}
  +1 FAMS @<XREF:FAM>@ {0:M} g7:FAMS
  +2 <<NOTE_STRUCTURE>> {0:M}
  +1 SUBM @<XREF:SUBM>@ {0:M} g7:SUBM
  +1 <<ASSOCIATION_STRUCTURE>> {0:M}
  +1 ALIA @<XREF:INDI>@ {0:M} g7:ALIA
  +2 PHRASE <Text> {0:1} g7:PHRASE
  +1 ANCI @<XREF:SUBM>@ {0:M} g7:ANCI
  +1 DESI @<XREF:SUBM>@ {0:M} g7:DESI
  +1 <<IDENTIFIER_STRUCTURE>> {0:M}
  +1 <<NOTE_STRUCTURE>> {0:M}
  +1 <<SOURCE_CITATION>> {0:M}
  +1 <<MULTIMEDIA_LINK>> {0:M}
  +1 <<CHANGE_DATE>> {0:1}
  +1 <<CREATION_DATE>> {0:1}
*/
}
