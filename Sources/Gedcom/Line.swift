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

public struct Line {
  public var level: Int
  public var xref: String?
  public var tag: String
  public var value: String?

  // Level ' ' [Xref ' '] Tag [' ' LineVal] EOL
  init?(_ line: String) {
    guard let endOfLevel = line.firstIndex(of: " ") else {
      return nil
    }
    guard let level = Int(String(line[..<endOfLevel])) else {
      return nil
    }
    self.level = level

    let nextTokenIndex = line.index(endOfLevel, offsetBy: 1)

    var remainingLine = line[nextTokenIndex...]
    var tagPosition = remainingLine.startIndex

    if remainingLine.first == "@" {
      guard let endOfXref = remainingLine.firstIndex(of: " ") else {
        return nil
      }

      xref = String(remainingLine[..<endOfXref])
      tagPosition = remainingLine.index(endOfXref, offsetBy: 1)
    }
    remainingLine = remainingLine[tagPosition...]
    let endOfTag = remainingLine.firstIndex(of: " ") ?? remainingLine.endIndex

    tag = String(remainingLine[..<endOfTag])

    if endOfTag != remainingLine.endIndex {
      let valueIndex = remainingLine.index(endOfTag, offsetBy: 1)
      value = String(remainingLine[valueIndex...])
    }
  }
}

