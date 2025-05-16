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
  public var top: Int?
  public var left: Int?
  public var height: Int?
  public var width: Int?
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TOP" : \Crop.top,
    "LEFT" : \Crop.left,
    "HEIGHT" : \Crop.height,
    "WIDTH" : \Crop.width,
  ]

  init(top: Int? =  nil, left: Int? =  nil, height: Int? =  nil, width: Int? =  nil)
  {
    self.top = top
    self.left = left
    self.height = height
    self.width = width
  }
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
  func export() -> Record? {
    let record = Record(level: 0, tag: "CROP")

    if let top {
      record.children.append(Record(level: 1, tag: "TOP", value: "\(top)"))
    }
    if let left {
      record.children.append(Record(level: 1, tag: "LEFT", value: "\(left)"))
    }
    if let height {
      record.children.append(Record(level: 1, tag: "HEIGHT", value: "\(height)"))
    }
    if let width {
      record.children.append(Record(level: 1, tag: "WIDTH", value: "\(width)"))
    }

    return record
  }
}
public class MultimediaLink  : RecordProtocol {
  public var xref: String
  public var crop: Crop?
  public var title: String?
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "CROP" : \MultimediaLink.crop,
    "TITL" : \MultimediaLink.title
  ]

  init(xref: String, crop: Crop? = nil, title: String? = nil)
  {
    self.xref = xref
    self.crop = crop
    self.title = title
  }
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

  func export() -> Record? {
    let record = Record(level: 0, tag: "OBJE", value: xref)

    if let crop {
      record.children.append(crop.export()!)
    }
    if let title {
      record.children.append(Record(level: 1, tag: "TITL", value: title))
    }

    return record
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

  func export() -> Record? {
    return nil
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
  func export() -> Record? {
    return nil
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

  func export() -> Record? {
    return nil
  }
}
public class Multimedia  : RecordProtocol {
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

  func export() -> Record? {
    return nil
  }
}
