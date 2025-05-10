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
public class Crop : RecordProtocol {
  var top: Int?
  var left: Int?
  var height: Int?
  var width: Int?
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TOP" : \Crop.top,
    "LEFT" : \Crop.left,
    "HEIGHT" : \Crop.height,
    "WIDTH" : \Crop.width,
  ]
  required init(record: Record) throws {
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Crop, Int?> {
        mutableSelf[keyPath: wkp] = Int(child.line.value!)
      }
    }
  }
}
public class MultimediaLink  : RecordProtocol {
/*
 n OBJE @<XREF:OBJE>@ {1:1} g7:OBJE
 +1 CROP {0:1} g7:CROP
 +2 TOP <Integer> {0:1} g7:TOP
 +2 LEFT <Integer> {0:1} g7:LEFT
 +2 HEIGHT <Integer> {0:1} g7:HEIGHT
 +2 WIDTH <Integer> {0:1} g7:WIDTH
 +1 TITL <Text> {0:1} g7:TITL
 */
  var xref: String
  var crop: Crop?
  var title: String?
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "CROP" : \MultimediaLink.crop,
    "TITL" : \MultimediaLink.title
  ]

  required init(record: Record) throws {
    self.xref = record.line.value!

    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<MultimediaLink, Crop?> {
        mutableSelf[keyPath: wkp] = try Crop(record: child)
      } else if let wkp = kp as? WritableKeyPath<MultimediaLink, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }
}

public class FileTranslation : RecordProtocol {
  public var path: String = ""
  public var form: String = ""


  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "FORM" : \FileTranslation.form,
  ]

  required init(record: Record) throws {
    self.path = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<FileTranslation, String> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }
}

public class MultimediaFileForm : RecordProtocol {
  public var form: String
  public var medium: Medium?
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "MEDI" : \MultimediaFileForm.medium,
  ]

  required init(record: Record) throws {
    self.form = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<MultimediaFileForm, Medium?> {
        mutableSelf[keyPath: wkp] = try Medium(record: child)
      }
    }
  }
}
public class MultimediaFile : RecordProtocol {
  public var path: String
  // TODO: Should have cardinality 1
  public var form: MultimediaFileForm?
  public var title: String?
  public var translations: [FileTranslation] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "FORM" : \MultimediaFile.form,
    "TITL" : \MultimediaFile.title,
    "TRAN" : \MultimediaFile.translations,
  ]

  required init(record: Record) throws {
    self.path = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<MultimediaFile, String> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<MultimediaFile, String?> {
        mutableSelf[keyPath: wkp] = child.line.value
      } else if let wkp = kp as? WritableKeyPath<MultimediaFile, MultimediaFileForm?> {
        mutableSelf[keyPath: wkp] = try MultimediaFileForm(record: child)
      } else if let wkp = kp as? WritableKeyPath<MultimediaFile,  [FileTranslation]> {
        mutableSelf[keyPath: wkp].append(try FileTranslation(record: child))
      }
    }
  }


}
public class Multimedia  : RecordProtocol {
  /*
   n @XREF:OBJE@ OBJE {1:1} g7:record-OBJE
   +1 RESN <List:Enum> {0:1} g7:RESN
   +1 FILE <Special> {1:M} g7:FILE
   +2 FORM <MediaType> {1:1} g7:FORM
   +3 MEDI <Enum> {0:1} g7:MEDI
   +4 PHRASE <Text> {0:1} g7:PHRASE
   +2 TITL <Text> {0:1} g7:TITL
   +2 TRAN <Special> {0:M} g7:FILE-TRAN
   +3 FORM <MediaType> {1:1} g7:FORM
   +1 <<IDENTIFIER_STRUCTURE>> {0:M}
   +1 <<NOTE_STRUCTURE>> {0:M}
   +1 <<SOURCE_CITATION>> {0:M}
   +1 <<CHANGE_DATE>> {0:1}
   +1 <<CREATION_DATE>> {0:1}
   */
  public var xref: String
  public var restrictions: [Restriction] = []

  public var files: [MultimediaFile] = []

  public var citations: [SourceCitation] = []
  public var notes: [NoteStructure] = []
  public var identifiers: [IdentifierStructure] = []
  public var changeDate: ChangeDate?
  public var creationDate: CreationDate?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "RESN" : \Multimedia.restrictions,
    "FILE" : \Multimedia.files,
    "SOUR" : \Multimedia.citations,
    "NOTE" : \Multimedia.notes,
    "SNOTE" : \Multimedia.notes,
    "REFN" : \Multimedia.identifiers,
    "UID" : \Multimedia.identifiers,
    "EXID" : \Multimedia.identifiers,
    "CHAN" : \Multimedia.changeDate,
    "CREA" : \Multimedia.creationDate
  ]

  required init(record: Record) throws {
    self.xref = record.line.xref!
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<Multimedia, [String]> {
        mutableSelf[keyPath: wkp].append(child.line.value ?? "")
      } else if let wkp = kp as? WritableKeyPath<Multimedia, [Restriction]> {
        let strings : [String] = (child.line.value?.components(separatedBy: ",").map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})) ?? []
        mutableSelf[keyPath: wkp] = strings.map({Restriction(rawValue: $0)!})
      } else if let wkp = kp as? WritableKeyPath<Multimedia, [MultimediaFile]> {
        mutableSelf[keyPath: wkp].append(try MultimediaFile(record: child))
      } else if let wkp = kp as? WritableKeyPath<Multimedia, [SourceCitation]> {
        mutableSelf[keyPath: wkp].append(try SourceCitation(record: child))
      } else if let wkp = kp as? WritableKeyPath<Multimedia, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Multimedia, [IdentifierStructure]> {
        mutableSelf[keyPath: wkp].append(try IdentifierStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<Multimedia, ChangeDate?> {
        mutableSelf[keyPath: wkp] = try ChangeDate(record: child)
      } else if let wkp = kp as? WritableKeyPath<Multimedia, CreationDate?> {
        mutableSelf[keyPath: wkp] = try CreationDate(record: child)
      }
    }
  }
}
