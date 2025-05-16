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

public class PlaceTranslation : RecordProtocol {
  public var place: [String] = []
  public var lang: String = ""

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "LANG" : \PlaceTranslation.lang
  ]

  init(place: [String], lang: String) {
    self.place = place
    self.lang = lang
  }

  required init(record: Record) throws {
    self.place = (record.line.value ?? "")
      .components(separatedBy: ",")
      .map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})

    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<PlaceTranslation, String> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record? {
    let record = Record(level: 0, tag: "TRAN", value: place.joined(separator: ", "))
    record.children += [Record(level: 1, tag: "LANG", value: lang)]
    return record
  }
}

public class PlaceCoordinates : RecordProtocol {
  public var lat: Double = Double.nan
  public var lon: Double = Double.nan

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "LATI" : \PlaceCoordinates.lat,
    "LONG" : \PlaceCoordinates.lon,
  ]

  init(lat: Double, lon: Double) {
    self.lat = lat
    self.lon = lon
  }
  required init(record: Record) throws {
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<PlaceCoordinates, Double> {
        var valueStr = child.line.value ?? ""
        var coord: Double?
        var isNegative = false
        if valueStr.starts(with: "N") || valueStr.starts(with: "E"){
          isNegative = false
        } else if valueStr.starts(with: "S") || valueStr.starts(with: "W"){
          isNegative = true
        }
        valueStr.removeFirst()
        coord = Double(valueStr)

        if coord != nil {
          if isNegative {
            coord! *= -1
          }
          mutableSelf[keyPath: wkp] = coord!
        }
      }
    }
  }

  func export() -> Record? {
    let record = Record(level: 0, tag: "MAP")
    record.children += [
      Record(level: 1, tag: "LATI", value: "\(lat >= 0 ? "N\(lat)" : "S\(lat * -1)")"),
      Record(level: 1, tag: "LONG", value: "\(lon >= 0 ? "E\(lon)" : "W\(lon * -1)")")
    ]
    return record
  }
}

public class PlaceStructure : RecordProtocol {
  public var place: [String] = []
  public var form: [String] = []
  public var lang: String?
  public var translations: [PlaceTranslation] = []
  public var map: PlaceCoordinates?
  public var exids: [EXID] = []
  public var notes: [NoteStructure] = []


  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "FORM" : \PlaceStructure.form,
    "LANG" : \PlaceStructure.lang,
    "TRAN" : \PlaceStructure.translations,
    "MAP" : \PlaceStructure.map,
    "EXID" : \PlaceStructure.exids,
    "NOTE" : \PlaceStructure.notes,
    "SNOTE" : \PlaceStructure.notes,

  ]

  init(place: [String], form: [String] = [], lang: String?) {
    self.place = place
    self.form = form
    self.lang = lang
  }

  required init(record: Record) throws {
    self.place = (record.line.value ?? "")
      .components(separatedBy: ",")
      .map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})

    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<PlaceStructure, [String]> {
        mutableSelf[keyPath: wkp] = (child.line.value ?? "")
          .components(separatedBy: ",")
          .map({$0.trimmingCharacters(in: .whitespacesAndNewlines)})
      } else if let wkp = kp as? WritableKeyPath<PlaceStructure, [PlaceTranslation]> {
        mutableSelf[keyPath: wkp].append(try PlaceTranslation(record: child))
      } else if let wkp = kp as? WritableKeyPath<PlaceStructure, PlaceCoordinates?> {
        mutableSelf[keyPath: wkp] = try PlaceCoordinates(record: child)
      } else if let wkp = kp as? WritableKeyPath<PlaceStructure, [EXID]> {
        mutableSelf[keyPath: wkp].append(try EXID(record: child))
      } else if let wkp = kp as? WritableKeyPath<PlaceStructure, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      } else if let wkp = kp as? WritableKeyPath<PlaceStructure, String?> {
        mutableSelf[keyPath: wkp] = child.line.value!
      }
    }
  }

  func export() -> Record? {
    let record = Record(level: 0, tag: "PLAC", value: place.joined(separator: ", "))

    if form.count > 0 {
      record.children += [Record(level: 1, tag: "FORM", value: form.joined(separator: ", "))]
    }

    if let lang {
      record.children += [Record(level: 1, tag: "LANG", value: lang)]
    }

    for translation in translations {
      record.children += [translation.export()!]
    }

    if let map {
      record.children += [map.export()!]
    }

    for exid in exids {
      record.children += [exid.export()!]
    }
    for note in notes {
      record.children += [note.export()!]
    }

    return record
  }
}
