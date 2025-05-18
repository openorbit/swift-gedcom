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

class Record {
  var line: Line
  var children: [Record] = []

  init?(string: String) {
    let line = Line(string)
    guard let line else { return nil }
    self.line = line
  }
  init(line: Line) {
    self.line = line
  }

  init(level: Int, xref: String? = nil, tag: String, value: String? = nil) {
    let line = Line(level: level, xref: xref, tag: tag, value: value)
    self.line = line
  }

  func setLevel(_ level: Int) {
    line.level = level
    for child in children {
      child.setLevel(level + 1)
    }
  }

  func export() -> String {
    var string = line.export()
    for child in children {
      string += child.export()
    }
    return string
  }
}

protocol RecordProtocol {
  init(record: Record) throws
  func export() -> Record
}
