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
  n CHAN {1:1} g7:CHAN
  +1 DATE <DateExact> {1:1} g7:DATE-exact
  +2 TIME <Time> {0:1} g7:TIME
  +1 <<NOTE_STRUCTURE>> {0:M}
*/

public class DateTime : RecordProtocol {
  public var date: String = ""
  public var time: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TIME" : \DateTime.time,
  ]

  init()
  {
    
  }

  init(date: String, time: String? = nil)
  {
    self.date = date
    self.time = time
  }

  required init(record: Record) throws {
    date = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      if let wkp = kp as? WritableKeyPath<DateTime, String> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<DateTime, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record? {
    let record = Record(level: 0, tag: "DATE", value: date)
    if let time {
      let timeRecord = Record(level: 1, tag: "TIME", value: time)
      record.children.append(timeRecord)
    }
    return record
  }
}

public class DateTimeExact : RecordProtocol {
  public var date: String = ""
  public var time: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TIME" : \DateTimeExact.time,
  ]

  init()
  {

  }
  init(date: String, time: String? = nil)
  {
    self.date = date
    self.time = time
  }
  required init(record: Record) throws {
    date = record.line.value ?? ""
    var mutableSelf = self

    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }
      if let wkp = kp as? WritableKeyPath<DateTimeExact, String> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      } else if let wkp = kp as? WritableKeyPath<DateTimeExact, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record? {
    var record = Record(level: 0, tag: "DATE", value: date)
    if let time {
      var timeRecord = Record(level: 1, tag: "TIME", value: time)
      record.children.append(timeRecord)
    }
    return record
  }
}

public class DateValue : RecordProtocol {
  public var date: String = ""
  public var time: String?
  public var phrase: String?
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TIME" : \DateValue.time,
    "PHRASE" : \DateValue.phrase,
  ]
  required init(record: Record) throws {
    date = record.line.value ?? ""
    var mutableSelf = self
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<DateValue, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record? {
    var record = Record(level: 0, tag: "DATE", value: date)
    if let time {
      var timeRecord = Record(level: 1, tag: "TIME", value: time)
      record.children.append(timeRecord)
    }
    if let phrase {
      var phraseRecord = Record(level: 1, tag: "PHRASE", value: time)
      record.children.append(phraseRecord)
    }
    return record
  }
}

public class DatePeriod : RecordProtocol {
  public var date: String = ""
  public var time: String?
  public var phrase: String?
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "TIME" : \DatePeriod.time,
    "PHRASE" : \DatePeriod.phrase,
  ]
  required init(record: Record) throws {
    date = record.line.value ?? ""
    var mutableSelf = self
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<DatePeriod, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record? {
    var record = Record(level: 0, tag: "DATE", value: date)
    if let time {
      var timeRecord = Record(level: 1, tag: "TIME", value: time)
      record.children.append(timeRecord)
    }
    if let phrase {
      var phraseRecord = Record(level: 1, tag: "PHRASE", value: time)
      record.children.append(phraseRecord)
    }
    return record
  }
}


public class CreationDate : RecordProtocol {
  public var date: DateTime = DateTime()
  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATE" : \CreationDate.date,
  ]

  init(date: String, time: String? = nil)
  {
    self.date = DateTime(date: date, time: time)
  }
  required init(record: Record) throws {
    var mutableSelf = self
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<CreationDate, DateTime> {
        mutableSelf[keyPath: wkp] = try DateTime(record: child)
      }
    }
  }

  func export() -> Record? {
    let record = Record(level: 0, tag: "CREA")
    if let exportedDate = date.export() {
      record.children.append(exportedDate)
    }
    return record
  }
}
public class ChangeDate : RecordProtocol {
  public var date: DateTime = DateTime()
  public var notes: [NoteStructure] = []

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "DATE" : \ChangeDate.date,
    "NOTE" : \ChangeDate.notes,
    "SNOTE" : \ChangeDate.notes,
  ]

  init(date: String, time: String? = nil) {
    self.date = DateTime(date: date, time: time)
  }
  required init(record: Record) throws {
    var mutableSelf = self
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<ChangeDate, DateTime> {
        mutableSelf[keyPath: wkp] = try DateTime(record: child)
      } else if let wkp = kp as? WritableKeyPath<ChangeDate, [NoteStructure]> {
        mutableSelf[keyPath: wkp].append(try NoteStructure(record: child))
      }
    }
  }

  func export() -> Record? {
    let record = Record(level: 0, tag: "CHAN")
    if let exportedDate = date.export() {
      record.children.append(exportedDate)
    }
    for note in notes {
      if let exportedNote = note.export() {
        record.children.append(exportedNote)
      }
    }
    return record
  }
}
