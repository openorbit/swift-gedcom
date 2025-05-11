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

enum Calendar {
  case gregorian
  case julian
  case frenchRevolutionary
  case hebrew
  case other
}


enum Epoch {
  case bce
  case ce
}


func parseMonth(monthString: Substring) -> Int? {
  let monthNumbers: [String:Int] = [
    "JAN" : 1, "FEB" : 2, "MAR" : 3, "APR" : 4, "MAY" : 5, "JUN" : 6,
    "JUL" : 7, "AUG" : 8, "SEP" : 9, "OCT" : 10, "NOV": 11, "DEC": 12,
    // French revolutionary months
    "VEND" : 1, "BRUM" : 2, "FRIM" : 3, "NIVO" : 4, "PLUV" : 5,
    "VENT" : 6, "GERM" : 7, "FLOR" : 8, "PRAI" : 9, "MESS" : 10,
    "THER" : 11, "FRUC" : 12, "COMP" : 13,
    // Hebrew months
    "TSH" : 1, "CSH" : 2, "KSL" : 3, "TVT" : 4, "SHV" : 5, "ADR" : 6,
    "ADS" : 7, "NSN" : 8, "IYR" : 9, "SVN" : 10, "TMZ" : 11, "AAV" : 12,
    "ELL" : 13,
  ]
  return monthNumbers[String(monthString)]
}

