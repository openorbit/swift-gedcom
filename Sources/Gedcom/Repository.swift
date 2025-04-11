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

public class Repository : RecordProtocol {
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

      if let wkp = kp as? WritableKeyPath<Repository, [String]?> {
      }
    }

  }
  /*
   n @XREF:REPO@ REPO {1:1} g7:record-REPO
   +1 NAME <Text> {1:1} g7:NAME
   +1 <<ADDRESS_STRUCTURE>> {0:1}
   +1 PHON <Special> {0:M} g7:PHON
   +1 EMAIL <Special> {0:M} g7:EMAIL
   +1 FAX <Special> {0:M} g7:FAX
   +1 WWW <Special> {0:M} g7:WWW
   +1 <<NOTE_STRUCTURE>> {0:M}
   +1 <<IDENTIFIER_STRUCTURE>> {0:M}
   +1 <<CHANGE_DATE>> {0:1}
   +1 <<CREATION_DATE>> {0:1}
   */
}

