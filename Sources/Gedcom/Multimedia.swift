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
      print("\(child.line.tag)")

      if let wkp = kp as? WritableKeyPath<MultimediaLink, Crop?> {
        mutableSelf[keyPath: wkp] = try Crop(record: child)
      } else if let wkp = kp as? WritableKeyPath<MultimediaLink, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }
}

public class Multimedia  : RecordProtocol {
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    :
  ]

  required init(record: Record) throws {
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      print("\(child.line.tag)")

      if let wkp = kp as? WritableKeyPath<Multimedia, [String]?> {
      }
    }

  }


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
}
