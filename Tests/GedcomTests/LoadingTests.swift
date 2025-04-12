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
    #expect(ged.submitterRecordsMap["@U1@"]!.identifiers.count == 6)
    switch (ged.submitterRecordsMap["@U1@"]!.identifiers[0]) {
    case .Refn(let refn):
      #expect(refn.refn == "1")
      #expect(refn.type == "User-generated identifier")
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.submitterRecordsMap["@U1@"]!.identifiers[0]) {
    case .Refn(let refn):
      #expect(refn.refn == "1")
      #expect(refn.type == "User-generated identifier")
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.submitterRecordsMap["@U1@"]!.identifiers[1]) {
    case .Refn(let refn):
      #expect(refn.refn == "10")
      #expect(refn.type == "User-generated identifier")
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.submitterRecordsMap["@U1@"]!.identifiers[2]) {
    case .Uuid(let uid):
      #expect(uid.uid == UUID(uuidString: "24132fe0-26f6-4f87-9924-389a4f40f0ec"))
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.submitterRecordsMap["@U1@"]!.identifiers[3]) {
    case .Uuid(let uid):
      #expect(uid.uid == UUID(uuidString: "b451c8df-5550-473b-a55c-ed31e65c60c8"))
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.submitterRecordsMap["@U1@"]!.identifiers[4]) {
    case .Exid(let exid):
      #expect(exid.exid == "123")
      #expect(exid.type == "http://example.com")
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.submitterRecordsMap["@U1@"]!.identifiers[5]) {
    case .Exid(let exid):
      #expect(exid.exid == "456")
      #expect(exid.type == "http://example.com")
    default:
      Issue.record("unexpected identifier type")
    }

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

    // Shared notes loading
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.text == "Shared note 1")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.mimeType == "text/plain")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.lang == "en-US")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.translation.count == 2)
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.translation[0].text == "Shared note 1")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.translation[0].mimeType == "text/plain")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.translation[0].lang == "en-GB")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.translation[1].text == "Shared note 1")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.translation[1].mimeType == "text/plain")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.translation[1].lang == "en-CA")

    #expect(ged.sharedNoteRecordsMap["@N1@"]!.citation.count == 2)
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.citation[0].xref == "@S1@")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.citation[0].page == "1")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.citation[1].xref == "@S2@")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.citation[1].page == "2")

    #expect(ged.sharedNoteRecordsMap["@N1@"]!.identifiers.count == 6)
    switch (ged.sharedNoteRecordsMap["@N1@"]!.identifiers[0]) {
    case .Refn(let refn):
      #expect(refn.refn == "1")
      #expect(refn.type == "User-generated identifier")
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.sharedNoteRecordsMap["@N1@"]!.identifiers[1]) {
    case .Refn(let refn):
      #expect(refn.refn == "10")
      #expect(refn.type == "User-generated identifier")
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.sharedNoteRecordsMap["@N1@"]!.identifiers[2]) {
    case .Uuid(let uid):
      #expect(uid.uid == UUID(uuidString: "6efbee0b-96a1-43ea-83c8-828ec71c54d7"))
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.sharedNoteRecordsMap["@N1@"]!.identifiers[3]) {
    case .Uuid(let uid):
      #expect(uid.uid == UUID(uuidString: "4094d92a-5525-44ec-973d-6c527aa5535a"))
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.sharedNoteRecordsMap["@N1@"]!.identifiers[4]) {
    case .Exid(let exid):
      #expect(exid.exid == "123")
      #expect(exid.type == "http://example.com")
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.sharedNoteRecordsMap["@N1@"]!.identifiers[5]) {
    case .Exid(let exid):
      #expect(exid.exid == "456")
      #expect(exid.type == "http://example.com")
    default:
      Issue.record("unexpected identifier type")
    }

    #expect(ged.sharedNoteRecordsMap["@N1@"]!.changeDate?.date.date == "27 MAR 2022")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.changeDate?.date.time == "08:56")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.changeDate?.notes.count == 2)
    switch (ged.sharedNoteRecordsMap["@N1@"]!.changeDate?.notes[0]) {
    case .Note(let note):
      #expect(note.text == "Change date note 1")
    default:
      Issue.record("unexpected note type")
    }
    switch (ged.sharedNoteRecordsMap["@N1@"]!.changeDate?.notes[1]) {
    case .Note(let note):
      #expect(note.text == "Change date note 2")
    default:
      Issue.record("unexpected note type")
    }
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.creationDate?.date.date == "27 MAR 2022")
    #expect(ged.sharedNoteRecordsMap["@N1@"]!.creationDate?.date.time == "08:55")
    #expect(ged.sharedNoteRecordsMap["@N2@"]!.text == "Shared note 2")
  }
}
