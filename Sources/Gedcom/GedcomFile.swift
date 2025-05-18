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

import Foundation
import ZIPFoundation

class GedcomFile {
  let url: URL
  let archive: Archive?
  var data: Data
  var recordLines: [Record] = []

  var header: Header = Header()
  var familyRecords: [Family] = []
  var individualRecords: [Individual] = []
  var multimediaRecords: [Multimedia] = []
  var repositoryRecords: [Repository] = []
  var sharedNoteRecords: [SharedNote] = []
  var sourceRecords: [Source] = []
  var submitterRecords: [Submitter] = []

  var familyRecordsMap: [String: Family] = [:]
  var individualRecordsMap: [String: Individual] = [:]
  var multimediaRecordsMap: [String: Multimedia] = [:]
  var repositoryRecordsMap: [String: Repository] = [:]
  var sharedNoteRecordsMap: [String: SharedNote] = [:]
  var sourceRecordsMap: [String: Source] = [:]
  var submitterRecordsMap: [String: Submitter] = [:]

  init(withArchive path: URL, encoding: String.Encoding = .utf8) throws {
    self.url = path
    self.archive = try Archive(url: path, accessMode: .read, pathEncoding: nil)

    guard let archive = self.archive else {
      throw GedcomError.badArchive
    }
    guard let entry = archive["gedcom.ged"] else {
      throw GedcomError.missingManifest
    }

    data = Data()
    try _ = archive.extract(entry) { data in
      self.data.append(data)
    }

    if data.starts(with: [0xef, 0xbb, 0xbf]) {
      // File starts with a BOM, drop it
      data.removeFirst(3)
    }

    try parse(encoding: encoding)
    try build()
  }

  init(withFile path: URL, encoding: String.Encoding = .utf8) throws {
    self.url = path
    self.archive = nil
    self.data = try Data(contentsOf: path)

    if data.starts(with: [0xef, 0xbb, 0xbf]) {
      // File starts with a BOM, drop it
      data.removeFirst(3)
    }

    try parse(encoding: encoding)
    try build()
  }

  func parse(encoding: String.Encoding) throws {
    let gedcom = String(data: self.data, encoding: encoding)!
    var recordStack: [Record] = []

    var errorOnLine: Int?
    var lineNumber = 1
    gedcom.enumerateLines() { (line, stop) in
      do {
        guard let gedLine = Line(line) else {
          throw GedcomError.badLine(lineNumber)
        }

        let record = Record(line: gedLine)

        if gedLine.level == 0 {
          self.recordLines.append(record)
          recordStack = [record]
        } else {
          if recordStack.last!.line.level == gedLine.level - 1 && gedLine.tag == "CONT" {
            //
            if recordStack[recordStack.count - 1].line.value == nil {
              recordStack[recordStack.count - 1].line.value = ""
            }
            recordStack[recordStack.count - 1].line.value!.append("\n\(gedLine.value!)")

          } else if recordStack.last!.line.level < gedLine.level {
            recordStack.last!.children.append(record)
            recordStack.append(record)
          } else {
            while recordStack.last!.line.level >= gedLine.level {
              recordStack.removeLast()
            }
            recordStack.last!.children.append(record)
            recordStack.append(record)
          }
        }
      } catch {
        stop = true
        errorOnLine = lineNumber
        return
      }
      lineNumber += 1
    }

    if let errorOnLine {
      throw GedcomError.badLine(errorOnLine)
    }
  }

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "HEAD" : \GedcomFile.header,
    "INDI" : \GedcomFile.individualRecords,
    "FAM" : \GedcomFile.familyRecords,
    "OBJE" : \GedcomFile.multimediaRecords,
    "REPO" : \GedcomFile.repositoryRecords,
    "SNOTE" : \GedcomFile.sharedNoteRecords,
    "SOUR" : \GedcomFile.sourceRecords,
    "SUBM" : \GedcomFile.submitterRecords,
  ]

  func build() throws {
    var mutableSelf = self
    for record in recordLines {
      guard let kp = Self.keys[record.line.tag] else {
        continue
      }
      if let wkp = kp as? WritableKeyPath<GedcomFile, Header> {
        mutableSelf[keyPath: wkp] = try Header(record: record)
      } else if let wkp = kp as? WritableKeyPath<GedcomFile, [Family]> {
        mutableSelf[keyPath: wkp].append(try Family(record: record))
        if let xref = record.line.xref {
          familyRecordsMap[xref] = mutableSelf[keyPath: wkp].last!
        }
      } else if let wkp = kp as? WritableKeyPath<GedcomFile, [Individual]> {
        mutableSelf[keyPath: wkp].append(try Individual(record: record))
        if let xref = record.line.xref {
          individualRecordsMap[xref] = mutableSelf[keyPath: wkp].last!
        }
      } else if let wkp = kp as? WritableKeyPath<GedcomFile, [Multimedia]> {
        mutableSelf[keyPath: wkp].append(try Multimedia(record: record))
        if let xref = record.line.xref {
          multimediaRecordsMap[xref] = mutableSelf[keyPath: wkp].last!
        }
      } else if let wkp = kp as? WritableKeyPath<GedcomFile, [Repository]> {
        mutableSelf[keyPath: wkp].append(try Repository(record: record))
        if let xref = record.line.xref {
          repositoryRecordsMap[xref] = mutableSelf[keyPath: wkp].last!
        }
      } else if let wkp = kp as? WritableKeyPath<GedcomFile, [SharedNote]> {
        mutableSelf[keyPath: wkp].append(try SharedNote(record: record))
        if let xref = record.line.xref {
          sharedNoteRecordsMap[xref] = mutableSelf[keyPath: wkp].last!
        }
      } else if let wkp = kp as? WritableKeyPath<GedcomFile, [Source]> {
        mutableSelf[keyPath: wkp].append(try Source(record: record))
        if let xref = record.line.xref {
          sourceRecordsMap[xref] = mutableSelf[keyPath: wkp].last!
        }
      } else if let wkp = kp as? WritableKeyPath<GedcomFile, [Submitter]> {
        mutableSelf[keyPath: wkp].append(try Submitter(record: record))
        assert(record.line.xref != nil)
        if let xref = record.line.xref {
          submitterRecordsMap[xref] = mutableSelf[keyPath: wkp].last!
        }
      }
    }
  }

  func export() -> String {
    var records: [Record] = []

    records += [header.export()]

    for fam in familyRecords {
      records += [fam.export()]
    }

    for ind in individualRecords {
      records += [ind.export()]
    }

    for multi in multimediaRecords {
      records += [multi.export()]
    }

    for repo in repositoryRecords {
      records += [repo.export()]
    }

    for note in sharedNoteRecords {
      records += [note.export()]
    }

    for source in sourceRecords {
      records += [source.export()]
    }

    for submitter in submitterRecords {
      records += [submitter.export()]
    }

    records += [Record(level: 0, tag: "TRLR")]

    var result = ""
    for record in records {
      result += record.export()
    }

    return result
  }
}

