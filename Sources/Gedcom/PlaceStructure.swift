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

/*
n PLAC <List:Text>                         {1:1}  g7:PLAC
  +1 FORM <List:Text>                      {0:1}  g7:PLAC-FORM
  +1 LANG <Language>                       {0:1}  g7:LANG
  +1 TRAN <List:Text>                      {0:M}  g7:PLAC-TRAN
     +2 LANG <Language>                    {1:1}  g7:LANG
  +1 MAP                                   {0:1}  g7:MAP
     +2 LATI <Special>                     {1:1}  g7:LATI
     +2 LONG <Special>                     {1:1}  g7:LONG
  +1 EXID <Special>                        {0:M}  g7:EXID
     +2 TYPE <Special>                     {0:1}  g7:EXID-TYPE
  +1 <<NOTE_STRUCTURE>>                    {0:M}
*/

public class PlaceTranslation : RecordProtocol {
  public var place: [String] = []
  public var lang: String = ""

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "LANG" : \PlaceTranslation.lang
  ]

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
    return nil
  }
}

public class PlaceCoordinates : RecordProtocol {
  public var lat: Double = Double.nan
  public var lon: Double = Double.nan

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "LATI" : \PlaceCoordinates.lat,
    "LONG" : \PlaceCoordinates.lon,
  ]

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
    return nil
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
    return nil
  }
}
