//
// SPDX-License-Identifier: Apache-2.0
//
// Copyright 2026 Mattias Holm
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

public enum GedcomDialect: Equatable {
  case gedcom5(version: String)
  case gedcom7(version: String)
  case unknown(version: String?)

  public static func from(version: String?) -> GedcomDialect {
    guard let version, !version.isEmpty else {
      return .unknown(version: nil)
    }

    if version.hasPrefix("5.") {
      return .gedcom5(version: version)
    }

    if version.hasPrefix("7.") {
      return .gedcom7(version: version)
    }

    return .unknown(version: version)
  }
}
