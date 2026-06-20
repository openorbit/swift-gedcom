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

public class GedcomFile {
  var url: URL?
  var archive: Archive?
  var data: Data?
  var recordLines: [Record] = []

  public var header: Header = Header()
  public var familyRecords: [Family] = []
  public var individualRecords: [Individual] = []
  public var multimediaRecords: [Multimedia] = []
  public var repositoryRecords: [Repository] = []
  public var sharedNoteRecords: [SharedNote] = []
  public var sourceRecords: [Source] = []
  public var submitterRecords: [Submitter] = []
  public var extensionRecords: [GedcomExtensionNode] = []

  public var familyRecordsMap: [String: Family] = [:]
  public var individualRecordsMap: [String: Individual] = [:]
  public var multimediaRecordsMap: [String: Multimedia] = [:]
  public var repositoryRecordsMap: [String: Repository] = [:]
  public var sharedNoteRecordsMap: [String: SharedNote] = [:]
  public var sourceRecordsMap: [String: Source] = [:]
  public var submitterRecordsMap: [String: Submitter] = [:]

  public init(withArchive path: URL, encoding: String.Encoding = .utf8) throws {
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
      self.data!.append(data)
    }

    if data!.starts(with: [0xef, 0xbb, 0xbf]) {
      // File starts with a BOM, drop it
      data!.removeFirst(3)
    }

    try parse(encoding: encoding)
    try build()
  }

  public init(withFile path: URL, encoding: String.Encoding = .utf8) throws {
    self.url = path
    self.archive = nil
    self.data = try Data(contentsOf: path)

    if data!.starts(with: [0xef, 0xbb, 0xbf]) {
      // File starts with a BOM, drop it
      data!.removeFirst(3)
    }

    try parse(encoding: encoding)
    try build()
  }

  public init() {
  }

  func dataAsString(encoding: String.Encoding) -> String? {
    guard let data else {
      return nil
    }
    return String(data: data, encoding: encoding)
  }
  func parse(encoding: String.Encoding) throws {
    let gedcom = dataAsString(encoding: encoding)!
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
            if recordStack[recordStack.count - 1].line.value == nil {
              recordStack[recordStack.count - 1].line.value = ""
            }
            let value = gedLine.value ?? ""
            recordStack[recordStack.count - 1].line.value!.append("\n\(value)")

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
        if record.line.tag != "TRLR" {
          extensionRecords.append(GedcomExtensionNode(record: record))
        }
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

  public var extensionSchema: [String: URL] {
    header.schema?.tags ?? [:]
  }

  public func uri(forExtensionTag tag: String) -> URL? {
    header.schema?.uri(forExtensionTag: tag)
  }

  public func extensionNodes(tag: String) -> [GedcomExtensionNode] {
    extensionNodes(tag: tag, in: [header.export()] + exportBodyRecords())
  }

  public func extensionNodes(uri: URL) -> [GedcomExtensionNode] {
    guard let tag = header.schema?.extensionTag(forURI: uri) else { return [] }
    return extensionNodes(tag: tag)
  }

  public func discoveredExtensionTags() -> Set<String> {
    extensionTags(in: [header.export()] + exportBodyRecords())
  }

  private func extensionNodes(tag: String, in records: [Record]) -> [GedcomExtensionNode] {
    records.flatMap { extensionNodes(tag: tag, in: $0) }
  }

  private func extensionNodes(tag: String, in record: Record) -> [GedcomExtensionNode] {
    var nodes: [GedcomExtensionNode] = record.line.tag == tag ? [GedcomExtensionNode(record: record)] : []
    for child in record.children {
      nodes += extensionNodes(tag: tag, in: child)
    }
    return nodes
  }

  private func extensionTags(in records: [Record]) -> Set<String> {
    records.reduce(into: Set<String>()) { tags, record in
      tags.formUnion(extensionTags(in: record))
    }
  }

  private func extensionTags(in record: Record) -> Set<String> {
    var tags = record.line.tag.hasPrefix("_") ? Set([record.line.tag]) : Set<String>()
    for child in record.children {
      tags.formUnion(extensionTags(in: child))
    }
    return tags
  }

  private func ensureExtensionSchemaDeclarations(for tags: Set<String>) {
    guard !tags.isEmpty else { return }
    if header.schema == nil {
      header.schema = Schema()
    }
    header.schema?.ensureDeclarations(for: tags, source: header.source?.source)
  }

  private func exportBodyRecords() -> [Record] {
    var records: [Record] = []

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

    for node in extensionRecords {
      records += [node.export()]
    }

    return records
  }

  public func exportContent() -> String {
    let bodyRecords = exportBodyRecords()
    ensureExtensionSchemaDeclarations(for: extensionTags(in: [header.export()] + bodyRecords))

    var records: [Record] = []

    records += [header.export()]
    records += bodyRecords

    records += [Record(level: 0, tag: "TRLR")]

    var result = ""
    for record in records {
      result += record.export()
    }

    return result
  }

  public func export(archive path: URL, encoding: String.Encoding = .utf8) throws {
    let content = exportContent()
    let data = content.data(using: encoding)!

    let archive = try Archive(url: path, accessMode: .create)

    try archive.addEntry(with: "gedcom.ged", type: .file, uncompressedSize: Int64(data.count), bufferSize: 4, provider: { (position, size) -> Data in
      // This will be called until `data` is exhausted (3x in this case).
      return data.subdata(in: Data.Index(position)..<Int(position)+size)
    })
  }

  public func export(file path: URL, encoding: String.Encoding = .utf8) throws {
    let content = exportContent()
    let data = content.data(using: encoding)!
    try data.write(to: path)
  }

  public func add(individual: Individual) {
    individualRecords += [individual]
    individualRecordsMap[individual.xref] = individual
  }

  public func add(family: Family) {
    familyRecords += [family]
    familyRecordsMap[family.xref] = family
  }
  public func add(media: Multimedia) {
    multimediaRecords += [media]
    multimediaRecordsMap[media.xref] = media
  }

  public func add(repo: Repository) {
    repositoryRecords += [repo]
    repositoryRecordsMap[repo.xref] = repo
  }

  public func add(note: SharedNote) {
    sharedNoteRecords += [note]
    sharedNoteRecordsMap[note.xref] = note
  }

  public func add(source: Source) {
    sourceRecords += [source]
    sourceRecordsMap[source.xref] = source
  }

  public func add(submitter: Submitter) {
    submitterRecords += [submitter]
    submitterRecordsMap[submitter.xref] = submitter
  }

  public func data(forRelativePath path: String) throws -> Data? {
    if let archive = archive {
      // GEDZ: Look in ZIP
      // Note: GEDZ requires paths to be relative.
      // Normalize path separators?
      let cleanPath = path.replacingOccurrences(of: "\\", with: "/")
      guard let entry = archive[cleanPath] else { return nil }
      var res = Data()
      _ = try archive.extract(entry) { d in res.append(d) }
      return res
    } else if let baseUrl = url {
      // GED: Relative to file
      let fileUrl = baseUrl.deletingLastPathComponent().appendingPathComponent(path)
      return try Data(contentsOf: fileUrl)
    }
    return nil
  }

  public func data(for media: MultimediaFile) throws -> Data? {
    return try data(forRelativePath: media.path)
  }
}
