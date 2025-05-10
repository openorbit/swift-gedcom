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

public class Family : RecordProtocol {
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "RESN" : \Family.resn,
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
      } else if let wkp = kp as? WritableKeyPath<Family, Individual?> {
      } else if let wkp = kp as? WritableKeyPath<Family, [Individual]> {
      }
    }
  }

  public var resn: [String] = []
  // public var familyAttributes: []
  // public var familyEvents: []
  // public var nonEvents: []
  public var husband: Individual?
  public var wife: Individual?
  public var children: [Individual] = []
  public var multimediaLinks: [MultimediaLink] = []

  // public var associations: [] = []
  // public var submitter: Submitter?
  //+1 <<LDS_SPOUSE_SEALING>> {0:M}
  //+1 <<IDENTIFIER_STRUCTURE>> {0:M}
  //+1 <<NOTE_STRUCTURE>> {0:M}
  //+1 <<SOURCE_CITATION>> {0:M}
  //+1 <<MULTIMEDIA_LINK>> {0:M}
  //+1 <<CHANGE_DATE>> {0:1}
  //+1 <<CREATION_DATE>> {0:1}
}
