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
  public var sourceDialect: GedcomDialect = .unknown(version: nil)
  public private(set) var sourceEncoding: String.Encoding?
  public private(set) var sourceEncodingLabel: String?
  public var exportDialect: GedcomDialect { .gedcom7(version: "7.0") }

  public var familyRecordsMap: [String: Family] = [:]
  public var individualRecordsMap: [String: Individual] = [:]
  public var multimediaRecordsMap: [String: Multimedia] = [:]
  public var repositoryRecordsMap: [String: Repository] = [:]
  public var sharedNoteRecordsMap: [String: SharedNote] = [:]
  public var sourceRecordsMap: [String: Source] = [:]
  public var submitterRecordsMap: [String: Submitter] = [:]

  private var generatedMultimediaRecordIndex = 1
  private var generatedSourceRecordIndex = 1
  private var liftedGedcom5Records: [Record] = []

  public init(withArchive path: URL, encoding: String.Encoding? = nil) throws {
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

    try parse(encoding: resolveImportEncoding(preferred: encoding))
    try prepareRecordsForBuild()
    try build()
  }

  public init(withFile path: URL, encoding: String.Encoding? = nil) throws {
    self.url = path
    self.archive = nil
    self.data = try Data(contentsOf: path)

    try parse(encoding: resolveImportEncoding(preferred: encoding))
    try prepareRecordsForBuild()
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

  private func resolveImportEncoding(preferred encoding: String.Encoding?) throws -> String.Encoding {
    if let encoding {
      removeUTF8ByteOrderMarkIfNeeded(for: encoding)
      sourceEncoding = encoding
      sourceEncodingLabel = "explicit"
      return encoding
    }

    guard let data else {
      throw GedcomError.badEncoding
    }

    if data.starts(with: [0xef, 0xbb, 0xbf]) {
      self.data?.removeFirst(3)
      sourceEncoding = .utf8
      sourceEncodingLabel = "UTF-8"
      return .utf8
    }

    if data.starts(with: [0xff, 0xfe]) || data.starts(with: [0xfe, 0xff]) {
      sourceEncoding = .utf16
      sourceEncodingLabel = "UNICODE"
      return .utf16
    }

    if let characterEncoding = declaredCharacterEncoding(in: data) {
      guard let encoding = swiftEncoding(forGedcomCharacterEncoding: characterEncoding) else {
        throw GedcomError.unsupportedEncoding(characterEncoding)
      }
      sourceEncoding = encoding
      sourceEncodingLabel = characterEncoding
      return encoding
    }

    sourceEncoding = .utf8
    sourceEncodingLabel = "UTF-8"
    return .utf8
  }

  private func removeUTF8ByteOrderMarkIfNeeded(for encoding: String.Encoding) {
    guard encoding == .utf8, data?.starts(with: [0xef, 0xbb, 0xbf]) == true else {
      return
    }
    data?.removeFirst(3)
  }

  private func declaredCharacterEncoding(in data: Data) -> String? {
    let prefix = data.prefix(8192)
    var lineStart = prefix.startIndex

    func scanLine(upTo lineEnd: Data.Index) -> String? {
      let line = prefix[lineStart..<lineEnd]
      defer {
        lineStart = lineEnd < prefix.endIndex ? prefix.index(after: lineEnd) : prefix.endIndex
      }

      guard let asciiLine = String(bytes: line.filter { $0 < 0x80 }, encoding: .ascii) else {
        return nil
      }

      let parts = asciiLine.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
      guard parts.count >= 3, parts[0] == "1", parts[1] == "CHAR" else {
        return nil
      }
      return parts[2].trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    var index = prefix.startIndex
    while index < prefix.endIndex {
      let byte = prefix[index]
      if byte == 0x0a || byte == 0x0d {
        if let encoding = scanLine(upTo: index) {
          return encoding
        }
        if byte == 0x0d {
          let nextIndex = prefix.index(after: index)
          if nextIndex < prefix.endIndex, prefix[nextIndex] == 0x0a {
            index = nextIndex
            lineStart = prefix.index(after: nextIndex)
          }
        }
      }
      index = prefix.index(after: index)
    }

    if lineStart < prefix.endIndex {
      return scanLine(upTo: prefix.endIndex)
    }

    return nil
  }

  private func swiftEncoding(forGedcomCharacterEncoding encoding: String) -> String.Encoding? {
    switch encoding
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .uppercased()
      .replacingOccurrences(of: "_", with: "-") {
    case "UTF-8", "UTF8":
      return .utf8
    case "UNICODE", "UTF-16", "UTF16":
      return .utf16
    case "ASCII", "US-ASCII":
      return usableEncoding(.ascii, sample: [0x41])
    case "ANSI", "WINDOWS-1252", "CP1252":
      return firstUsableEncoding([.windowsCP1252, .isoLatin1], sample: [0xe9])
    case "MACROMAN", "MAC-ROMAN", "MACOSROMAN":
      return usableEncoding(.macOSRoman, sample: [0x8e])
    default:
      return nil
    }
  }

  private func firstUsableEncoding(_ encodings: [String.Encoding], sample: [UInt8]) -> String.Encoding? {
    encodings.first { usableEncoding($0, sample: sample) != nil }
  }

  private func usableEncoding(_ encoding: String.Encoding, sample: [UInt8]) -> String.Encoding? {
    String(data: Data(sample), encoding: encoding) == nil ? nil : encoding
  }

  func parse(encoding: String.Encoding) throws {
    guard let gedcom = dataAsString(encoding: encoding) else {
      throw GedcomError.badEncoding
    }
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

  func prepareRecordsForBuild() throws {
    sourceDialect = GedcomDialect.from(version: gedcomVersion(in: recordLines))

    switch sourceDialect {
    case .gedcom5:
      convertGedcom5RecordsToGedcom7()
    case .gedcom7, .unknown:
      if containsTag("CONC", in: recordLines) {
        throw GedcomError.badRecord
      }
    }
  }

  private func gedcomVersion(in records: [Record]) -> String? {
    guard let header = records.first(where: { $0.line.tag == "HEAD" }),
          let gedc = header.children.first(where: { $0.line.tag == "GEDC" }),
          let vers = gedc.children.first(where: { $0.line.tag == "VERS" }) else {
      return nil
    }
    return vers.line.value
  }

  private func containsTag(_ tag: String, in records: [Record]) -> Bool {
    records.contains { record in
      record.line.tag == tag || containsTag(tag, in: record.children)
    }
  }

  private func convertGedcom5RecordsToGedcom7() {
    generatedMultimediaRecordIndex = 1
    generatedSourceRecordIndex = 1
    liftedGedcom5Records = []

    for record in recordLines {
      convertGedcom5RecordToGedcom7(record)
      if record.line.level == 0 && record.line.tag == "NOTE" {
        record.line.tag = "SNOTE"
      }
    }

    if !liftedGedcom5Records.isEmpty {
      if let trailerIndex = recordLines.firstIndex(where: { $0.line.tag == "TRLR" }) {
        recordLines.insert(contentsOf: liftedGedcom5Records, at: trailerIndex)
      } else {
        recordLines.append(contentsOf: liftedGedcom5Records)
      }
    }
  }

  private func convertGedcom5RecordToGedcom7(_ record: Record, parentTag: String?) {
    var convertedChildren: [Record] = []

    for child in record.children {
      if child.line.tag == "CONC" || child.line.tag == "CONT" {
        if record.line.value == nil {
          record.line.value = ""
        }
        if child.line.tag == "CONT" {
          record.line.value?.append("\n\(child.line.value ?? "")")
        } else {
          record.line.value?.append(child.line.value ?? "")
        }
      } else {
        convertGedcom5RecordToGedcom7(child, parentTag: record.line.tag)
        convertedChildren.append(child)
      }
    }

    record.children = convertedChildren

    if record.line.tag == "DATE" {
      convertGedcom5DateRecordToGedcom7(record)
    } else if record.line.tag == "OBJE" && record.line.level > 0 && !isPointerValue(record.line.value) {
      liftGedcom5InlineMultimedia(record)
    } else if record.line.tag == "SOUR" && parentTag != "HEAD" && record.line.level > 0 && !isPointerValue(record.line.value) {
      liftGedcom5InlineSource(record)
    } else if record.line.tag == "ROMN" || record.line.tag == "FONE" {
      convertGedcom5NameVariationToTranslation(record)
    } else if record.line.tag == "RELA" {
      convertGedcom5RelationshipToRole(record)
    } else if record.line.tag == "AFN" || record.line.tag == "RFN" || record.line.tag == "RIN" {
      convertGedcom5IdentifierToExternalIdentifier(record)
    } else if record.line.tag == "WAC" {
      record.line.tag = "INIL"
      convertGedcom5PayloadValueToGedcom7(record, parentTag: parentTag)
    } else if record.line.tag == "SUBN" {
      record.line.tag = "_SUBN"
    } else {
      convertGedcom5PayloadValueToGedcom7(record, parentTag: parentTag)
    }
  }

  private func convertGedcom5IdentifierToExternalIdentifier(_ record: Record) {
    let originalTag = record.line.tag
    record.line.tag = "EXID"

    if record.children.first(where: { $0.line.tag == "TYPE" }) == nil {
      record.children.insert(
        Record(level: record.line.level + 1,
               tag: "TYPE",
               value: "GEDCOM 5.5.1 \(originalTag)"),
        at: 0
      )
    }
  }

  private func convertGedcom5RecordToGedcom7(_ record: Record) {
    convertGedcom5RecordToGedcom7(record, parentTag: nil)
  }

  private func convertGedcom5PayloadValueToGedcom7(_ record: Record, parentTag: String?) {
    switch record.line.tag {
    case "AGE":
      convertGedcom5AgeValue(record)
    case "SEX":
      convertGedcom5SexValue(record)
    case "STAT":
      convertGedcom5StatusValue(record)
    case "PEDI":
      record.line.value = record.line.value?.uppercased()
    case "RESN":
      record.line.value = record.line.value?
        .components(separatedBy: ",")
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }
        .joined(separator: ", ")
    case "TYPE" where parentTag == "NAME":
      record.line.value = record.line.value?.uppercased()
    default:
      break
    }
  }

  private func convertGedcom5AgeValue(_ record: Record) {
    guard let value = record.line.value?.trimmingCharacters(in: .whitespacesAndNewlines),
          !value.isEmpty else {
      return
    }

    switch value.uppercased() {
    case "CHILD":
      record.line.value = "< 8y"
      appendPhrase("Child", to: record)
    case "INFANT":
      record.line.value = "< 1y"
      appendPhrase("Infant", to: record)
    case "STILLBORN":
      record.line.value = "0y"
      appendPhrase("Stillborn", to: record)
    default:
      break
    }
  }

  private func convertGedcom5SexValue(_ record: Record) {
    guard let value = record.line.value?.trimmingCharacters(in: .whitespacesAndNewlines),
          let first = value.first else {
      record.line.value = "U"
      return
    }

    switch String(first).uppercased() {
    case "M":
      record.line.value = "M"
    case "F":
      record.line.value = "F"
    case "X":
      record.line.value = "X"
    default:
      record.line.value = "U"
    }
  }

  private func convertGedcom5StatusValue(_ record: Record) {
    guard let value = record.line.value?.trimmingCharacters(in: .whitespacesAndNewlines),
          !value.isEmpty else {
      return
    }

    switch value.uppercased() {
    case "DNS/CAN":
      record.line.value = "DNS_CAN"
    case "PRE-1970":
      record.line.value = "PRE_1970"
    default:
      record.line.value = value.uppercased()
    }
  }

  private func convertGedcom5NameVariationToTranslation(_ record: Record) {
    let originalTag = record.line.tag
    var convertedChildren: [Record] = []
    var language: String?

    for child in record.children {
      if child.line.tag == "TYPE" {
        language = gedcom7Language(forGedcom5NameVariation: child.line.value, tag: originalTag)
      } else {
        convertedChildren.append(child)
      }
    }

    record.line.tag = "TRAN"
    record.children = convertedChildren
    record.children.insert(
      Record(level: record.line.level + 1,
             tag: "LANG",
             value: language ?? defaultLanguage(forGedcom5NameVariation: originalTag)),
      at: 0
    )
  }

  private func gedcom7Language(forGedcom5NameVariation type: String?, tag: String) -> String {
    guard let type else {
      return defaultLanguage(forGedcom5NameVariation: tag)
    }

    switch type.lowercased() {
    case "hangul":
      return "ko-hang"
    case "kana":
      return "ja-hrkt"
    case "pinyin":
      return "und-Latn-pinyin"
    case "romaji":
      return "ja-Latn"
    case "wadegiles":
      return "zh-Latn-wadegile"
    default:
      return defaultLanguage(forGedcom5NameVariation: tag)
    }
  }

  private func defaultLanguage(forGedcom5NameVariation tag: String) -> String {
    tag == "ROMN" ? "und-Latn" : "und"
  }

  private func convertGedcom5RelationshipToRole(_ record: Record) {
    let phrase = record.line.value?.trimmingCharacters(in: .whitespacesAndNewlines)

    record.line.tag = "ROLE"
    record.line.value = "OTHER"

    if let phrase, !phrase.isEmpty {
      appendPhrase(phrase, to: record)
    }
  }

  private func liftGedcom5InlineMultimedia(_ record: Record) {
    let xref = nextGeneratedXref(prefix: "O", existing: existingXrefs())
    let multimediaRecord = Record(level: 0, xref: xref, tag: "OBJE")
    var linkChildren: [Record] = []
    var fileChildren: [Record] = []

    for child in record.children {
      switch child.line.tag {
      case "FILE":
        let file = clonedRecord(child, level: 1)
        multimediaRecord.children.append(file)
      case "FORM":
        fileChildren.append(clonedRecord(child, level: 2))
      case "TITL":
        fileChildren.append(clonedRecord(child, level: 2))
      case "CROP":
        linkChildren.append(child)
      default:
        multimediaRecord.children.append(clonedRecord(child, level: 1))
      }
    }

    if let file = multimediaRecord.children.first(where: { $0.line.tag == "FILE" }) {
      file.children.append(contentsOf: fileChildren)
    } else if let path = record.line.value,
              !path.isEmpty {
      let file = Record(level: 1, tag: "FILE", value: path)
      file.children = fileChildren
      multimediaRecord.children.insert(file, at: 0)
    }

    convertGedcom5MultimediaFormValues(in: multimediaRecord)
    record.line.value = xref
    record.children = linkChildren
    liftedGedcom5Records.append(multimediaRecord)
  }

  private func liftGedcom5InlineSource(_ record: Record) {
    let xref = nextGeneratedXref(prefix: "S", existing: existingXrefs())
    let sourceRecord = Record(level: 0, xref: xref, tag: "SOUR")
    var citationChildren: [Record] = []

    if let title = record.line.value, !title.isEmpty {
      sourceRecord.children.append(Record(level: 1, tag: "TITL", value: title))
    }

    for child in record.children {
      switch child.line.tag {
      case "PAGE", "DATA", "EVEN", "QUAY", "OBJE", "NOTE", "SNOTE":
        citationChildren.append(child)
      default:
        sourceRecord.children.append(clonedRecord(child, level: 1))
      }
    }

    record.line.value = xref
    record.children = citationChildren
    liftedGedcom5Records.append(sourceRecord)
  }

  private func convertGedcom5MultimediaFormValues(in record: Record) {
    if record.line.tag == "FORM", let value = record.line.value {
      record.line.value = gedcom7MediaType(forGedcom5Form: value)
    }

    for child in record.children {
      convertGedcom5MultimediaFormValues(in: child)
    }
  }

  private func gedcom7MediaType(forGedcom5Form form: String) -> String {
    switch form.lowercased() {
    case "bmp":
      return "image/bmp"
    case "gif":
      return "image/gif"
    case "jpg", "jpeg":
      return "image/jpeg"
    case "ole":
      return "application/ole"
    case "pcx":
      return "image/vnd.zbrush.pcx"
    case "tif", "tiff":
      return "image/tiff"
    case "wav":
      return "audio/wav"
    default:
      return form
    }
  }

  private func isPointerValue(_ value: String?) -> Bool {
    guard let value else {
      return false
    }
    return value.hasPrefix("@") && value.hasSuffix("@") && value.count > 2
  }

  private func existingXrefs() -> Set<String> {
    Set(recordLines.compactMap(\.line.xref) + liftedGedcom5Records.compactMap(\.line.xref))
  }

  private func nextGeneratedXref(prefix: String, existing: Set<String>) -> String {
    if prefix == "O" {
      defer { generatedMultimediaRecordIndex += 1 }
      var xref = "@O\(generatedMultimediaRecordIndex)@"
      while existing.contains(xref) {
        generatedMultimediaRecordIndex += 1
        xref = "@O\(generatedMultimediaRecordIndex)@"
      }
      return xref
    }

    defer { generatedSourceRecordIndex += 1 }
    var xref = "@S\(generatedSourceRecordIndex)@"
    while existing.contains(xref) {
      generatedSourceRecordIndex += 1
      xref = "@S\(generatedSourceRecordIndex)@"
    }
    return xref
  }

  private func clonedRecord(_ record: Record, level: Int) -> Record {
    let clone = Record(level: level, xref: record.line.xref, tag: record.line.tag, value: record.line.value)
    clone.children = record.children.map { clonedRecord($0, level: level + 1) }
    return clone
  }

  private func convertGedcom5DateRecordToGedcom7(_ record: Record) {
    guard let value = record.line.value?.trimmingCharacters(in: .whitespacesAndNewlines),
          !value.isEmpty else {
      return
    }

    if let calendar = convertGedcom5CalendarEscape(value) {
      record.line.value = calendar
      return
    }

    if let interpreted = convertGedcom5InterpretedDate(value) {
      record.line.value = interpreted.date
      appendPhrase(interpreted.phrase, to: record)
      return
    }

    if let dualYear = convertGedcom5DualYearDate(value) {
      record.line.value = dualYear.date
      appendPhrase(dualYear.phrase, to: record)
      return
    }

    if let range = convertGedcom5DateRange(value) {
      record.line.value = range
    }
  }

  private func convertGedcom5CalendarEscape(_ value: String) -> String? {
    if value.hasPrefix("@#ROMAN@") {
      return value.replacingOccurrences(of: "@#ROMAN@", with: "_ROMAN", options: [.anchored])
    }
    if value.hasPrefix("@#UNKNOWN@") {
      return value.replacingOccurrences(of: "@#UNKNOWN@", with: "_UNKNOWN", options: [.anchored])
    }
    return nil
  }

  private func convertGedcom5InterpretedDate(_ value: String) -> (date: String, phrase: String)? {
    let prefix = "INT "
    guard value.hasPrefix(prefix),
          let phraseStart = value.firstIndex(of: "("),
          value.last == ")",
          phraseStart > value.index(value.startIndex, offsetBy: prefix.count) else {
      return nil
    }

    let date = value[value.index(value.startIndex, offsetBy: prefix.count)..<phraseStart]
      .trimmingCharacters(in: .whitespacesAndNewlines)
    let phrase = value[value.index(after: phraseStart)..<value.index(before: value.endIndex)]
      .trimmingCharacters(in: .whitespacesAndNewlines)

    guard !date.isEmpty, !phrase.isEmpty else {
      return nil
    }

    if let dualYear = convertGedcom5DualYearDate(date) {
      return (dualYear.date, "\(phrase); original date: \(value)")
    }
    return (date, phrase)
  }

  private func convertGedcom5DualYearDate(_ value: String) -> (date: String, phrase: String)? {
    let parts = value.split(separator: " ", omittingEmptySubsequences: false)
    var convertedParts: [String] = []
    var converted = false

    for part in parts {
      if !converted,
         let slash = part.firstIndex(of: "/") {
        let firstYear = part[..<slash]
        let secondYear = part[part.index(after: slash)...]

        if !firstYear.isEmpty,
           !secondYear.isEmpty,
           firstYear.allSatisfy(\.isNumber),
           secondYear.allSatisfy(\.isNumber) {
          convertedParts.append(String(firstYear))
          converted = true
          continue
        }
      }
      convertedParts.append(String(part))
    }

    guard converted else {
      return nil
    }

    return (convertedParts.joined(separator: " "), value)
  }

  private func convertGedcom5DateRange(_ value: String) -> String? {
    let prefix = "BET "
    guard value.hasPrefix(prefix),
          let separatorRange = value.range(of: " AND ") else {
      return nil
    }

    let start = value[value.index(value.startIndex, offsetBy: prefix.count)..<separatorRange.lowerBound]
      .trimmingCharacters(in: .whitespacesAndNewlines)
    let end = value[separatorRange.upperBound...]
      .trimmingCharacters(in: .whitespacesAndNewlines)

    guard let startYear = trailingYear(in: start),
          let endYear = trailingYear(in: end),
          startYear > endYear else {
      return nil
    }

    return "BET \(end) AND \(start)"
  }

  private func trailingYear(in value: String) -> Int? {
    value
      .split(separator: " ")
      .last
      .flatMap { Int($0) }
  }

  private func appendPhrase(_ phrase: String, to record: Record) {
    guard !phrase.isEmpty else {
      return
    }

    if let existingPhrase = record.children.first(where: { $0.line.tag == "PHRASE" }) {
      if existingPhrase.line.value?.isEmpty ?? true {
        existingPhrase.line.value = phrase
      }
      return
    }

    record.children.append(Record(level: record.line.level + 1, tag: "PHRASE", value: phrase))
  }

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
    header.gedc.vers = "7.0"
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
