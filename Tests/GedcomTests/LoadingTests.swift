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
      #expect(note.translations.count == 1)
      #expect(note.translations[0].text == "British English")
      #expect(note.translations[0].lang == "en-GB")
      #expect(note.citations.count == 2)
      #expect(note.citations[0].xref == "@S1@")
      #expect(note.citations[0].page == "1")
      #expect(note.citations[1].xref == "@S2@")
      #expect(note.citations[1].page == "2")
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


    // Sources
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events.count == 2)
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].eventTypes
            == ["BIRT", "DEAT"])
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].period!.date
            == "FROM 1701 TO 1800")
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].period!.phrase
            == "18th century")

    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place?.place
            == ["Some City", "Some County", "Some State", "Some Country"])
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place?.form
            == ["City", "County", "State", "Country"])
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place?.lang == "en-US")
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place?.translations.count == 2)
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place?.translations.count == 2)
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place?.translations[0].place
            == ["Some City", "Some County", "Some State", "Some Country"])
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place?.translations[0].lang
            == "en-GB")
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place?.translations[1].place
            == ["Some City", "Some County", "Some State", "Some Country"])
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place!.translations[1].lang
            == "en")
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place!.map!.lat == 18.150944)
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place!.map!.lon == 168.150944)
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place!.exids.count == 2)
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place!.exids[0].exid == "123")
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place!.exids[0].type == "http://example.com")
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place!.exids[1].exid == "456")
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place!.exids[1].type == "http://example.com")
    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[0].place!.notes.count ==  2)
    switch ged.sourceRecordsMap["@S1@"]!.data!.events[0].place!.notes[0] {
    case .Note(let note):
      #expect(note.text == "American English")
      #expect(note.mimeType == "text/plain")
      #expect(note.lang == "en-US")
      #expect(note.translations.count == 1)
      #expect(note.translations[0].text == "British English")
      #expect(note.translations[0].lang == "en-GB")
      #expect(note.citations.count == 2)
      #expect(note.citations[0].xref == "@S1@")
      #expect(note.citations[0].page == "1")
      #expect(note.citations[1].xref == "@S2@")
      #expect(note.citations[1].page == "2")
    default:
      Issue.record("unexpected note type")
    }
    switch ged.sourceRecordsMap["@S1@"]!.data!.events[0].place!.notes[1] {
    case .SNote(let snote):
      #expect(snote.xref == "@N1@")
    default:
      Issue.record("unexpected note type")
    }

    #expect(ged.sourceRecordsMap["@S1@"]!.data!.events[1].eventTypes == ["MARR"])
    //2 EVEN MARR
    //  3 DATE FROM 1701 TO 1800
    //    4 PHRASE 18th century

    #expect(ged.sourceRecordsMap["@S1@"]!.data!.agency ==  "Agency name")

    #expect(ged.sourceRecordsMap["@S1@"]!.data!.notes.count ==  2)
    switch ged.sourceRecordsMap["@S1@"]!.data!.notes[0] {
    case .Note(let note):
      #expect(note.text == "American English")
      #expect(note.mimeType == "text/plain")
      #expect(note.lang == "en-US")
      #expect(note.translations.count == 1)
      #expect(note.translations[0].text == "British English")
      #expect(note.translations[0].lang == "en-GB")
      #expect(note.citations.count == 2)
      #expect(note.citations[0].xref == "@S1@")
      #expect(note.citations[0].page == "1")
      #expect(note.citations[1].xref == "@S2@")
      #expect(note.citations[1].page == "2")
    default:
      Issue.record("unexpected note type")
    }

    switch ged.sourceRecordsMap["@S1@"]!.data!.notes[1] {
    case .SNote(let snote):
      #expect(snote.xref == "@N1@")
    default:
      Issue.record("unexpected note type")
    }

    #expect(ged.sourceRecordsMap["@S1@"]!.author == "Author")
    #expect(ged.sourceRecordsMap["@S1@"]!.title == "Title")
    #expect(ged.sourceRecordsMap["@S1@"]!.abbreviation == "Abbreviation")
    #expect(ged.sourceRecordsMap["@S1@"]!.publication == "Publication info")
    #expect(ged.sourceRecordsMap["@S1@"]!.text?.text == "Source text")
    #expect(ged.sourceRecordsMap["@S1@"]!.text?.mimeType == "text/plain")
    #expect(ged.sourceRecordsMap["@S1@"]!.text?.lang == "en-US")

    #expect(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation.count == 2)
    #expect(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[0].xref == "@R1@")
    #expect(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[0].notes.count == 2)
    switch ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[0].notes[0] {
    case .Note(let note):
      #expect(note.text == "Note text")
    default:
      Issue.record("unexpected note type")
    }
    switch ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[0].notes[1] {
    case .SNote(let note):
      #expect(note.xref == "@N1@")
    default:
      Issue.record("unexpected note type")
    }
    #expect(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[0].callNumbers.count == 1)
    #expect(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[0].callNumbers[0].callNumber == "Call number")
    #expect(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[0].callNumbers[0].medium!.medium == "BOOK")
    #expect(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[0].callNumbers[0].medium!.phrase == "Booklet")

    #expect(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[1].xref == "@R2@")
    #expect(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[1].callNumbers.count == 10)

    for (c, ex) in zip(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[1].callNumbers,
                       ["VIDEO", "CARD", "FICHE", "FILM", "MAGAZINE", "MANUSCRIPT", "MAP", "NEWSPAPER", "PHOTO", "TOMBSTONE"]) {
      #expect(c.callNumber == "Call number")
      #expect(c.medium!.medium == ex)
    }

    #expect(ged.sourceRecordsMap["@S1@"]!.identifiers.count == 6)
    switch (ged.sourceRecordsMap["@S1@"]!.identifiers[0]) {
    case .Refn(let refn):
      #expect(refn.refn == "1")
      #expect(refn.type == "User-generated identifier")
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.sourceRecordsMap["@S1@"]!.identifiers[1]) {
    case .Refn(let refn):
      #expect(refn.refn == "10")
      #expect(refn.type == "User-generated identifier")
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.sourceRecordsMap["@S1@"]!.identifiers[2]) {
    case .Uuid(let uid):
      #expect(uid.uid == UUID(uuidString: "f065a3e8-5c03-4b4a-a89d-6c5e71430a8d"))
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.sourceRecordsMap["@S1@"]!.identifiers[3]) {
    case .Uuid(let uid):
      #expect(uid.uid == UUID(uuidString: "9441c3f3-74df-42b4-bbc1-fed42fd7f536"))
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.sourceRecordsMap["@S1@"]!.identifiers[4]) {
    case .Exid(let exid):
      #expect(exid.exid == "123")
      #expect(exid.type == "http://example.com")
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.sourceRecordsMap["@S1@"]!.identifiers[5]) {
    case .Exid(let exid):
      #expect(exid.exid == "456")
      #expect(exid.type == "http://example.com")
    default:
      Issue.record("unexpected identifier type")
    }

    #expect(ged.sourceRecordsMap["@S1@"]!.multimediaLinks.count == 2)
    #expect(ged.sourceRecordsMap["@S1@"]!.multimediaLinks[0].xref == "@O1@")
    #expect(ged.sourceRecordsMap["@S1@"]!.multimediaLinks[1].xref == "@O2@")

    #expect(ged.sourceRecordsMap["@S1@"]!.notes.count == 2)
    switch ged.sourceRecordsMap["@S1@"]!.notes[0] {
    case .Note(let note):
      #expect(note.text == "Note text")
    default:
      Issue.record("unexpected note type")
    }
    switch ged.sourceRecordsMap["@S1@"]!.notes[1] {
    case .SNote(let note):
      #expect(note.xref == "@N1@")
    default:
      Issue.record("unexpected note type")
    }

    #expect(ged.sourceRecordsMap["@S1@"]!.changeDate != nil)
    #expect(ged.sourceRecordsMap["@S1@"]!.changeDate!.date.date == "27 MAR 2022")
    #expect(ged.sourceRecordsMap["@S1@"]!.changeDate!.date.time == "08:56")
    #expect(ged.sourceRecordsMap["@S1@"]!.changeDate!.notes.count == 2)

    #expect(ged.sourceRecordsMap["@S1@"]!.creationDate != nil)
    #expect(ged.sourceRecordsMap["@S1@"]!.creationDate!.date.date == "27 MAR 2022")
    #expect(ged.sourceRecordsMap["@S1@"]!.creationDate!.date.time == "08:55")

    #expect(ged.sourceRecordsMap["@S2@"]!.title == "Source Two")


    // Repositories
    /*
     TODO: Fix test when continuation lines are supported
        2 CONT 15 East South Temple Street
        2 CONT Salt Lake City, UT 84150 USA
    */
    #expect(ged.repositoryRecordsMap["@R1@"]!.name == "Repository 1")
    #expect(ged.repositoryRecordsMap["@R1@"]!.address!.address == "Family History Department")
    #expect(ged.repositoryRecordsMap["@R1@"]!.address!.adr1 == "Family History Department")
    #expect(ged.repositoryRecordsMap["@R1@"]!.address!.adr2 == "15 East South Temple Street")
    #expect(ged.repositoryRecordsMap["@R1@"]!.address!.adr3 == "Salt Lake City, UT 84150 USA")
    #expect(ged.repositoryRecordsMap["@R1@"]!.address!.city == "Salt Lake City")
    #expect(ged.repositoryRecordsMap["@R1@"]!.address!.state == "UT")
    #expect(ged.repositoryRecordsMap["@R1@"]!.address!.postalCode == "84150")
    #expect(ged.repositoryRecordsMap["@R1@"]!.address!.country == "USA")
    #expect(ged.repositoryRecordsMap["@R1@"]!.phoneNumbers
            == ["+1 (555) 555-1212", "+1 (555) 555-1234"])
    #expect(ged.repositoryRecordsMap["@R1@"]!.emails
            == ["GEDCOM@FamilySearch.org", "GEDCOM@example.com"])
    #expect(ged.repositoryRecordsMap["@R1@"]!.faxNumbers
            == ["+1 (555) 555-1212", "+1 (555) 555-1234"])
    #expect(ged.repositoryRecordsMap["@R1@"]!.www
            == ["http://gedcom.io", "http://gedcom.info"])
    #expect(ged.repositoryRecordsMap["@R1@"]!.notes.count == 2)
    switch ged.repositoryRecordsMap["@R1@"]!.notes[0] {
    case .Note(let note):
      #expect(note.text == "Note text")
    default:
      Issue.record("unexpected note type")
    }
    switch ged.repositoryRecordsMap["@R1@"]!.notes[1] {
    case .SNote(let note):
      #expect(note.xref == "@N1@")
    default:
      Issue.record("unexpected note type")
    }

    #expect(ged.repositoryRecordsMap["@R1@"]!.identifiers.count == 6)
    switch (ged.repositoryRecordsMap["@R1@"]!.identifiers[0]) {
    case .Refn(let refn):
      #expect(refn.refn == "1")
      #expect(refn.type == "User-generated identifier")
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.repositoryRecordsMap["@R1@"]!.identifiers[1]) {
    case .Refn(let refn):
      #expect(refn.refn == "10")
      #expect(refn.type == "User-generated identifier")
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.repositoryRecordsMap["@R1@"]!.identifiers[2]) {
    case .Uuid(let uid):
      #expect(uid.uid == UUID(uuidString: "efa7885b-c806-4590-9f1b-247797e4c96d"))
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.repositoryRecordsMap["@R1@"]!.identifiers[3]) {
    case .Uuid(let uid):
      #expect(uid.uid == UUID(uuidString: "d530f6ab-cfd4-44cd-ab2c-e40bddb76bf8"))
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.repositoryRecordsMap["@R1@"]!.identifiers[4]) {
    case .Exid(let exid):
      #expect(exid.exid == "123")
      #expect(exid.type == "http://example.com")
    default:
      Issue.record("unexpected identifier type")
    }
    switch (ged.repositoryRecordsMap["@R1@"]!.identifiers[5]) {
    case .Exid(let exid):
      #expect(exid.exid == "456")
      #expect(exid.type == "http://example.com")
    default:
      Issue.record("unexpected identifier type")
    }

    #expect(ged.repositoryRecordsMap["@R1@"]!.changeDate != nil)
    #expect(ged.repositoryRecordsMap["@R1@"]!.changeDate!.date.date == "27 MAR 2022")
    #expect(ged.repositoryRecordsMap["@R1@"]!.changeDate!.date.time == "08:56")
    #expect(ged.repositoryRecordsMap["@R1@"]!.changeDate!.notes.count == 2)
    #expect(ged.repositoryRecordsMap["@R1@"]!.creationDate != nil)
    #expect(ged.repositoryRecordsMap["@R1@"]!.creationDate!.date.date == "27 MAR 2022")
    #expect(ged.repositoryRecordsMap["@R1@"]!.creationDate!.date.time == "08:55")

    #expect(ged.repositoryRecordsMap["@R2@"]!.name == "Repository 2")
  }
}
