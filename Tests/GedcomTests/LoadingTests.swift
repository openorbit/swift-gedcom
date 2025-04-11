//
//  LoadingTests.swift
//  Gedcom
//
//  Created by Mattias Holm on 2024-11-28.
//

import Testing
import Foundation
@testable import Gedcom

@Suite("Load Gedcom Archive") struct ArchiveLoaderTests {
  @Test func testLoadMinArchive() async throws {
    let module = Bundle.module
    let resourceURL = module.url(forResource: "Gedcom7/minimal70",
                                 withExtension: "gdz")
    #expect(resourceURL != nil)

    let ged = try GedcomFile(withArchive: resourceURL!)
    #expect(ged.url == resourceURL)
    #expect(ged.familyRecords.count == 0)
    #expect(ged.individualRecords.count == 0)
    #expect(ged.multimediaRecords.count == 0)
    #expect(ged.repositoryRecords.count == 0)
    #expect(ged.sharedNoteRecords.count == 0)
    #expect(ged.sourceRecords.count == 0)
    #expect(ged.submitterRecords.count == 0)
  }


  @Test func testLoadMaxArchive() async throws {
    let module = Bundle.module

    let resourceURL = module.url(forResource: "Gedcom7/maximal70",
                                 withExtension: "gdz")
    #expect(resourceURL != nil)

    let ged = try GedcomFile(withArchive: resourceURL!)
    #expect(ged.url == resourceURL)
    #expect(ged.familyRecords.count == 2)
    #expect(ged.individualRecords.count == 4)
    #expect(ged.multimediaRecords.count == 2)
    #expect(ged.repositoryRecords.count == 2)
    #expect(ged.sharedNoteRecords.count == 2)
    #expect(ged.sourceRecords.count == 2)
    #expect(ged.submitterRecords.count == 2)
    #expect(ged.submitterRecordsMap.count == 2)

    #expect(ged.submitterRecordsMap["@U1@"]!.name == "GEDCOM Steering Committee")

    #expect(ged.submitterRecordsMap["@U1@"]!.address?.address == "Family History Department")
    #expect(ged.submitterRecordsMap["@U1@"]!.address?.adr1 == "Family History Department")
    #expect(ged.submitterRecordsMap["@U1@"]!.address?.adr2 == "15 East South Temple Street")
    #expect(ged.submitterRecordsMap["@U1@"]!.address?.adr3 == "Salt Lake City, UT 84150 USA")
    #expect(ged.submitterRecordsMap["@U1@"]!.address?.city == "Salt Lake City")
    #expect(ged.submitterRecordsMap["@U1@"]!.address?.state == "UT")
    #expect(ged.submitterRecordsMap["@U1@"]!.address?.postalCode == "84150")
    #expect(ged.submitterRecordsMap["@U1@"]!.address?.country == "USA")
    #expect(ged.submitterRecordsMap["@U1@"]!.phone == ["+1 (555) 555-1212", "+1 (555) 555-1234"])
    #expect(ged.submitterRecordsMap["@U1@"]!.email == ["GEDCOM@FamilySearch.org", "GEDCOM@example.com"])
    #expect(ged.submitterRecordsMap["@U1@"]!.fax == ["+1 (555) 555-1212", "+1 (555) 555-1234"])
    #expect(ged.submitterRecordsMap["@U1@"]!.www == [URL(string: "http://gedcom.io")!, URL(string: "http://gedcom.info")!])

    #expect(ged.submitterRecordsMap["@U1@"]!.multimediaLinks.count == 2)
    #expect(ged.submitterRecordsMap["@U1@"]!.multimediaLinks[0].xref == "@O1@")
    #expect(ged.submitterRecordsMap["@U1@"]!.multimediaLinks[0].crop!.top == 0)
    #expect(ged.submitterRecordsMap["@U1@"]!.multimediaLinks[0].crop!.left == 0)
    #expect(ged.submitterRecordsMap["@U1@"]!.multimediaLinks[0].crop!.width == 100)
    #expect(ged.submitterRecordsMap["@U1@"]!.multimediaLinks[0].crop!.height == 100)
    #expect(ged.submitterRecordsMap["@U1@"]!.multimediaLinks[0].title == "Title")

    #expect(ged.submitterRecordsMap["@U1@"]!.multimediaLinks[1].xref == "@O1@")
    #expect(ged.submitterRecordsMap["@U1@"]!.multimediaLinks[1].crop!.top == 100)
    #expect(ged.submitterRecordsMap["@U1@"]!.multimediaLinks[1].crop!.left == 100)
    #expect(ged.submitterRecordsMap["@U1@"]!.multimediaLinks[1].crop!.width == nil)
    #expect(ged.submitterRecordsMap["@U1@"]!.multimediaLinks[1].crop!.height == nil)
    #expect(ged.submitterRecordsMap["@U1@"]!.multimediaLinks[1].title == "Title")
    #expect(ged.submitterRecordsMap["@U1@"]!.languages == ["en-US", "en-GB"])
    #expect(ged.submitterRecordsMap["@U1@"]!.notes.count == 2)
    switch (ged.submitterRecordsMap["@U1@"]!.notes[0]) {
    case .Note(let note):
      #expect(note.text == "American English")
      #expect(note.mimeType == "text/plain")
      #expect(note.lang == "en-US")
      #expect(note.translation.count == 1)
      #expect(note.translation[0].text == "British English")
      #expect(note.translation[0].lang == "en-GB")
      #expect(note.citation.count == 2)
      #expect(note.citation[0].xref == "@S1@")
      #expect(note.citation[0].page == "1")
      #expect(note.citation[1].xref == "@S2@")
      #expect(note.citation[1].page == "2")
    default:
      Issue.record("unexpected note type")
    }
    switch (ged.submitterRecordsMap["@U1@"]!.notes[1]) {
    case .SNote(let note):
      #expect(note.xref == "@N1@")
    default:
      Issue.record("unexpected snote type")
    }
    #expect(ged.submitterRecordsMap["@U1@"]!.changeDate != nil)
    #expect(ged.submitterRecordsMap["@U1@"]!.changeDate!.date.date == "27 MAR 2022")
    #expect(ged.submitterRecordsMap["@U1@"]!.changeDate!.date.time == "08:56")
    #expect(ged.submitterRecordsMap["@U1@"]!.changeDate!.notes.count == 2)
    #expect(ged.submitterRecordsMap["@U1@"]!.creationDate != nil)
    #expect(ged.submitterRecordsMap["@U1@"]!.creationDate!.date.date == "27 MAR 2022")
    #expect(ged.submitterRecordsMap["@U1@"]!.creationDate!.date.time == "08:55")

    #expect(ged.submitterRecordsMap["@U2@"]!.name == "Submitter 2")

    // 0: Note
    // 1: SNote N1
    #expect(ged.submitterRecordsMap["@U1@"]!.notes.count == 2)
  }
}
