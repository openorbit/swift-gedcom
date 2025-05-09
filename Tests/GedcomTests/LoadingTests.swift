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

  @Suite("Load Max Archive") struct MaxArchiveLoaderTests {
    let module = Bundle.module
    let resourceURL = Bundle.module.url(forResource: "Gedcom7/maximal70",
                                        withExtension: "gdz")
    let ged: GedcomFile
    init() throws {
      ged = try GedcomFile(withArchive: resourceURL!)
    }

    @Test func wasLoaded() async throws {
      #expect(resourceURL != nil)
    }

    @Test func fileStructure() async throws {
      #expect(ged.url == resourceURL)
      #expect(ged.familyRecords.count == 2)
      #expect(ged.individualRecords.count == 4)
      #expect(ged.multimediaRecords.count == 2)
      #expect(ged.repositoryRecords.count == 2)
      #expect(ged.sharedNoteRecords.count == 2)
      #expect(ged.sourceRecords.count == 2)
      #expect(ged.submitterRecords.count == 2)
      #expect(ged.submitterRecordsMap.count == 2)
    }

    @Test func submitterRecords() async throws {
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

    }

    @Test func sharedNotes() async throws {


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

    @Test func sources() async throws {

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
      #expect(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[0].callNumbers[0].medium!.kind == .BOOK)
      #expect(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[0].callNumbers[0].medium!.phrase == "Booklet")

      #expect(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[1].xref == "@R2@")
      #expect(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[1].callNumbers.count == 10)

      for (c, ex) in zip(ged.sourceRecordsMap["@S1@"]!.sourceRepoCitation[1].callNumbers,
                         [MediumKind.VIDEO, MediumKind.CARD, MediumKind.FICHE, MediumKind.FILM, MediumKind.MAGAZINE, MediumKind.MANUSCRIPT, MediumKind.MAP, MediumKind.NEWSPAPER, MediumKind.PHOTO, MediumKind.TOMBSTONE]) {
        #expect(c.callNumber == "Call number")
        #expect(c.medium!.kind == ex)
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



    }

    @Test func repositories() async throws {

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

    @Test func multimediaObjects() async throws {

      // Multimedia objects
      #expect(ged.multimediaRecordsMap["@O1@"]!.restrictions == [.CONFIDENTIAL, .LOCKED])
      #expect(ged.multimediaRecordsMap["@O1@"]!.files.count == 2)
      // In the GDZ the path is not a file url, otherwise a file: url
      #expect(ged.multimediaRecordsMap["@O1@"]!.files[0].path == "path/to/file1")
      #expect(ged.multimediaRecordsMap["@O1@"]!.files[0].form!.form == "text/plain")
      #expect(ged.multimediaRecordsMap["@O1@"]!.files[0].form!.medium?.kind == .OTHER)
      #expect(ged.multimediaRecordsMap["@O1@"]!.files[0].form!.medium?.phrase == "Transcript")
      #expect(ged.multimediaRecordsMap["@O1@"]!.files[1].path == "media/original.mp3")
      #expect(ged.multimediaRecordsMap["@O1@"]!.files[1].form!.form == "audio/mp3")
      #expect(ged.multimediaRecordsMap["@O1@"]!.files[1].form!.medium?.kind == .AUDIO)
      #expect(ged.multimediaRecordsMap["@O1@"]!.files[1].title == "Object title")
      #expect(ged.multimediaRecordsMap["@O1@"]!.files[1].translations.count == 2)
      #expect(ged.multimediaRecordsMap["@O1@"]!.files[1].translations[0].path == "media/derived.oga")
      #expect(ged.multimediaRecordsMap["@O1@"]!.files[1].translations[0].form == "audio/ogg")
      #expect(ged.multimediaRecordsMap["@O1@"]!.files[1].translations[1].path == "media/transcript.vtt")
      #expect(ged.multimediaRecordsMap["@O1@"]!.files[1].translations[1].form == "text/vtt")

      #expect(ged.multimediaRecordsMap["@O1@"]!.identifiers.count == 6)
      switch (ged.multimediaRecordsMap["@O1@"]!.identifiers[0]) {
      case .Refn(let refn):
        #expect(refn.refn == "1")
        #expect(refn.type == "User-generated identifier")
      default:
        Issue.record("unexpected identifier type")
      }
      switch (ged.multimediaRecordsMap["@O1@"]!.identifiers[1]) {
      case .Refn(let refn):
        #expect(refn.refn == "10")
        #expect(refn.type == "User-generated identifier")
      default:
        Issue.record("unexpected identifier type")
      }
      switch (ged.multimediaRecordsMap["@O1@"]!.identifiers[2]) {
      case .Uuid(let uid):
        #expect(uid.uid == UUID(uuidString: "69ebdd0e-c78c-4b81-873f-dc8ac30a48b9"))
      default:
        Issue.record("unexpected identifier type")
      }
      switch (ged.multimediaRecordsMap["@O1@"]!.identifiers[3]) {
      case .Uuid(let uid):
        #expect(uid.uid == UUID(uuidString: "79cae8c4-e673-4e4f-bc5d-13b02d931302"))
      default:
        Issue.record("unexpected identifier type")
      }
      switch (ged.multimediaRecordsMap["@O1@"]!.identifiers[4]) {
      case .Exid(let exid):
        #expect(exid.exid == "123")
        #expect(exid.type == "http://example.com")
      default:
        Issue.record("unexpected identifier type")
      }
      switch (ged.multimediaRecordsMap["@O1@"]!.identifiers[5]) {
      case .Exid(let exid):
        #expect(exid.exid == "456")
        #expect(exid.type == "http://example.com")
      default:
        Issue.record("unexpected identifier type")
      }
      #expect(ged.multimediaRecordsMap["@O1@"]!.notes.count == 2)
      switch (ged.multimediaRecordsMap["@O1@"]!.notes[0]) {
      case .Note(let note):
        #expect(note.text == "American English")
        #expect(note.mimeType == "text/plain")
        #expect(note.lang == "en-US")
        #expect(note.translations.count == 2)
        #expect(note.translations[0].text == "British English")
        #expect(note.translations[0].lang == "en-GB")
        #expect(note.translations[1].text == "Canadian English")
        #expect(note.translations[1].lang == "en-CA")
        #expect(note.citations.count == 2)
        #expect(note.citations[0].xref == "@S1@")
        #expect(note.citations[0].page == "1")
        #expect(note.citations[1].xref == "@S2@")
        #expect(note.citations[1].page == "2")
      default:
        Issue.record("unexpected note type")
      }
      switch (ged.multimediaRecordsMap["@O1@"]!.notes[1]) {
      case .SNote(let note):
        #expect(note.xref == "@N1@")
      default:
        Issue.record("unexpected snote type")
      }

      #expect(ged.multimediaRecordsMap["@O1@"]!.citations.count == 2)
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].page == "1")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].data?.date?.date == "28 MAR 2022")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].data?.date?.time == "10:29")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].data?.date?.phrase == "Morning")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].data?.text.count == 2)
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].data?.text[0].text == "Text 1")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].data?.text[0].mimeType == "text/plain")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].data?.text[0].lang == "en-US")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].data?.text[1].text == "Text 2")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].data?.text[1].mimeType == "text/plain")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].data?.text[1].lang == "en-US")

      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].events.count == 1)
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].events[0].event == "BIRT")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].events[0].phrase == "Event phrase")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].events[0].role!.role == "OTHER")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].events[0].role!.phrase == "Role phrase")

      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].quality == 0)
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].links.count == 2)
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].links[0].xref == "@O1@")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].links[0].crop!.top == 0)
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].links[0].crop!.left == 0)
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].links[0].crop!.height == 100)
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].links[0].crop!.width == 100)
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].links[0].title == "Title")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].links[1].xref == "@O1@")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].links[1].crop!.top == 100)
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].links[1].crop!.left == 100)
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].links[1].title == "Title")


      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[0].notes.count == 2)
      switch (ged.multimediaRecordsMap["@O1@"]!.citations[0].notes[0]) {
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
      switch (ged.multimediaRecordsMap["@O1@"]!.citations[0].notes[1]) {
      case .SNote(let note):
        #expect(note.xref == "@N1@")
      default:
        Issue.record("unexpected snote type")
      }

      #expect(ged.multimediaRecordsMap["@O1@"]!.changeDate != nil)
      #expect(ged.multimediaRecordsMap["@O1@"]!.changeDate!.date.date == "27 MAR 2022")
      #expect(ged.multimediaRecordsMap["@O1@"]!.changeDate!.date.time == "08:56")
      #expect(ged.multimediaRecordsMap["@O1@"]!.changeDate!.notes.count == 2)
      #expect(ged.multimediaRecordsMap["@O1@"]!.creationDate != nil)
      #expect(ged.multimediaRecordsMap["@O1@"]!.creationDate!.date.date == "27 MAR 2022")
      #expect(ged.multimediaRecordsMap["@O1@"]!.creationDate!.date.time == "08:55")


      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[1].xref == "@S1@")
      #expect(ged.multimediaRecordsMap["@O1@"]!.citations[1].page == "2")

      #expect(ged.multimediaRecordsMap["@O2@"]!.restrictions == [.PRIVACY])
      #expect(ged.multimediaRecordsMap["@O2@"]!.files[0].path == "http://host.example.com/path/to/file2")
      #expect(ged.multimediaRecordsMap["@O2@"]!.files[0].form?.form == "text/plain")
      #expect(ged.multimediaRecordsMap["@O2@"]!.files[0].form?.medium?.kind == .ELECTRONIC)


    }

    // Individual records
    @Test func individuals() async throws {

      #expect(ged.individualRecordsMap["@I1@"]?.restrictions == [.CONFIDENTIAL, .LOCKED])
      #expect(ged.individualRecordsMap["@I1@"]?.names.count == 4)

      /*

      0 @I1@ INDI

      1 NAME Lt. Cmndr. Joseph "John" /de Allen/ jr.
      2 TYPE OTHER
      3 PHRASE Name type phrase
      2 NPFX Lt. Cmndr.
      2 GIVN Joseph
      2 NICK John
      2 SPFX de
      2 SURN Allen
      2 NSFX jr.
      2 TRAN npfx John /spfx Doe/ nsfx
      3 LANG en-GB
      3 NPFX npfx
      3 GIVN John
      3 NICK John
      3 SPFX spfx
      3 SURN Doe
      3 NSFX nsfx
      2 TRAN John /Doe/
      3 LANG en-CA
      2 NOTE Note text
      2 SNOTE @N1@
      2 SNOTE @VOID@
      2 SOUR @S1@
      3 PAGE 1
      2 SOUR @S2@
*/
      #expect(ged.individualRecordsMap["@I1@"]?.names[1].name == "John /Doe/")
      #expect(ged.individualRecordsMap["@I1@"]?.names[1].type?.kind == .BIRTH)

      #expect(ged.individualRecordsMap["@I1@"]?.names[2].name == "Aka")
      #expect(ged.individualRecordsMap["@I1@"]?.names[2].type?.kind == .AKA)

      #expect(ged.individualRecordsMap["@I1@"]?.names[3].name == "Immigrant Name")
      #expect(ged.individualRecordsMap["@I1@"]?.names[3].type?.kind == .IMMIGRANT)

      #expect(ged.individualRecordsMap["@I1@"]?.sex == .male)

/*
      1 CAST Caste
      2 TYPE Caste type
      1 DSCR Description
      2 TYPE Description type
      2 SOUR @VOID@
      3 PAGE Entire source
      1 EDUC Education
      2 TYPE Education type
      1 IDNO ID number
      2 TYPE ID number type
      1 NATI Nationality
      2 TYPE Nationality type
      1 NCHI 2
      2 TYPE nchi type
      1 NMR 2
      2 TYPE nmr type
      1 OCCU occu
      2 TYPE occu type
      1 PROP prop
      2 TYPE prop type
      1 RELI reli
      2 TYPE reli type
      1 RESI resi
      2 TYPE resi type
      1 SSN ssn
      2 TYPE ssn type
      1 TITL titl
      2 TYPE titl type
      1 FACT fact
      2 TYPE fact type
      1 BAPM
      2 TYPE bapm type
      1 BAPM Y
      1 BARM
      2 TYPE barm type
      1 BASM
      2 TYPE basm type
      1 BLES
      2 TYPE bles type
      1 BURI
      2 TYPE buri type
      2 DATE 30 MAR 2022
      1 CENS
      2 TYPE cens type
      1 CHRA
      2 TYPE chra type
      1 CONF
      2 TYPE conf type
      1 CREM
      2 TYPE crem type
      1 DEAT
      2 TYPE deat type
      2 DATE 28 MAR 2022
      2 PLAC Somewhere
      2 ADDR Address
      2 PHON +1 (555) 555-1212
      2 PHON +1 (555) 555-1234
      2 EMAIL GEDCOM@FamilySearch.org
      2 EMAIL GEDCOM@example.com
      2 FAX +1 (555) 555-1212
      2 FAX +1 (555) 555-1234
      2 WWW http://gedcom.io
      2 WWW http://gedcom.info
      2 AGNC Agency
      2 RELI Religion
      2 CAUS Cause of death
      2 RESN CONFIDENTIAL, LOCKED
      2 SDATE 28 MAR 2022
      3 TIME 16:47
      3 PHRASE sdate phrase
      2 ASSO @I3@
      3 ROLE CHIL
      2 ASSO @VOID@
      3 ROLE PARENT
      2 NOTE Note text
      2 SNOTE @N1@
      2 SOUR @S1@
      3 PAGE 1
      2 SOUR @S2@
      3 PAGE 2
      2 OBJE @O1@
      2 OBJE @O2@
      2 UID 82092878-6f4f-4bca-ad59-d1ae87c5e521
      2 UID daf4b8c0-4141-42c4-bec8-01d1d818dfaf
      1 EMIG
      2 TYPE emig type
      1 FCOM
      2 TYPE fcom type
      1 GRAD
      2 TYPE grad type
      1 IMMI
      2 TYPE immi type
      1 NATU
      2 TYPE natu type
      1 ORDN
      2 TYPE ordn type
      1 PROB
      2 TYPE prob type
      1 RETI
      2 TYPE reti type
      1 WILL
      2 TYPE will type
      1 ADOP
      2 TYPE adop type
      2 FAMC @VOID@
      3 ADOP BOTH
      4 PHRASE Adoption phrase
      1 ADOP
      2 FAMC @VOID@
      3 ADOP HUSB
      1 ADOP
      2 FAMC @VOID@
      3 ADOP WIFE
      1 BIRT
      2 TYPE birth type
      2 DATE 1 JAN 2000
      1 CHR
      2 TYPE chr type
      2 DATE 9 JAN 2000
      2 AGE 8d
      3 PHRASE Age phrase
      1 EVEN Event
      2 TYPE Event type
      1 NO NATU
      2 DATE FROM 1700 TO 1800
      3 PHRASE No date phrase
      2 NOTE Note text
      2 SNOTE @N1@
      2 SOUR @S1@
      3 PAGE 1
      2 SOUR @S1@
      3 PAGE 2
      1 NO EMIG
      1 BAPL
      2 STAT STILLBORN
      3 DATE 27 MAR 2022
      1 BAPL
      2 STAT SUBMITTED
      3 DATE 27 MAR 2022
      1 BAPL
      2 DATE 27 MAR 2022
      1 CONL
      2 STAT INFANT
      3 DATE 27 MAR 2022
      1 CONL
      2 DATE 27 MAR 2022
      1 ENDL
      2 STAT CHILD
      3 DATE 27 MAR 2022
      1 ENDL
      2 DATE 27 MAR 2022
      1 INIL
      2 STAT EXCLUDED
      3 DATE 27 MAR 2022
      1 INIL
      2 DATE 27 MAR 2022
      1 SLGC
      2 DATE 27 MAR 2022
      3 TIME 15:47
      3 PHRASE Afternoon
      2 TEMP SLAKE
      2 FAMC @VOID@
      1 SLGC
      2 PLAC Place
      2 STAT BIC
      3 DATE 27 MAR 2022
      4 TIME 15:48
      2 NOTE Note text
      2 SNOTE @N1@
      2 SOUR @S1@
      3 PAGE 1
      2 SOUR @S2@
      3 PAGE 2
      2 FAMC @VOID@
      1 SLGC
      2 FAMC @F2@
      1 FAMC @VOID@
      2 PEDI OTHER
      3 PHRASE Other type
      2 STAT CHALLENGED
      3 PHRASE Phrase
      1 FAMC @VOID@
      2 PEDI FOSTER
      1 FAMC @VOID@
      2 PEDI SEALING
      1 FAMC @F2@
      2 PEDI ADOPTED
      2 STAT PROVEN
      1 FAMC @F2@
      2 PEDI BIRTH
      2 STAT DISPROVEN
      1 FAMS @VOID@
      2 NOTE Note text
      2 SNOTE @N1@
      1 FAMS @F1@
      1 SUBM @U1@
      1 SUBM @U2@
      1 ASSO @VOID@
      2 PHRASE Mr Stockdale
      2 ROLE FRIEND
      1 ASSO @VOID@
      2 ROLE NGHBR
      1 ASSO @VOID@
      2 ROLE FATH
      1 ASSO @VOID@
      2 ROLE GODP
      1 ASSO @VOID@
      2 ROLE HUSB
      1 ASSO @VOID@
      2 ROLE MOTH
      1 ASSO @VOID@
      2 ROLE MULTIPLE
      1 ASSO @VOID@
      2 ROLE SPOU
      1 ASSO @VOID@
      2 ROLE WIFE
      1 ALIA @VOID@
      1 ALIA @I3@
      2 PHRASE Alias
      1 ANCI @U1@
      1 ANCI @VOID@
      1 DESI @U1@
      1 DESI @VOID@
      1 REFN 1
      2 TYPE User-generated identifier
      1 REFN 10
      2 TYPE User-generated identifier
      1 UID 3d75b5eb-36e9-40b3-b79f-f088b5c18595
      1 UID cb49c361-7124-447e-b587-4c6d36e51825
      1 EXID 123
      2 TYPE http://example.com
      1 EXID 456
      2 TYPE http://example.com
      1 NOTE me@example.com is an example email address.
      2 CONT @@me and @I are example social media handles.
      2 CONT @@@@@ has four @ characters where only the first is escaped.
      1 SNOTE @N1@
      1 SOUR @S1@
      2 PAGE 1
      2 QUAY 3
      1 SOUR @S2@
      */
      #expect(ged.individualRecordsMap["@I1@"]?.multimediaLinks.count == 2)
      #expect(ged.individualRecordsMap["@I1@"]?.multimediaLinks[0].xref == "@O1@")
      #expect(ged.individualRecordsMap["@I1@"]?.multimediaLinks[1].xref == "@O2@")

      #expect(ged.individualRecordsMap["@I1@"]?.changeDate?.date.date == "27 MAR 2022")
      #expect(ged.individualRecordsMap["@I1@"]?.changeDate?.date.time == "08:56")
      switch ged.individualRecordsMap["@I1@"]?.changeDate?.notes[0] {
      case .Note(let n):
        #expect(n.text == "Change date note 1")
      default :
        Issue.record("bad note in individual change date")
      }
      switch ged.individualRecordsMap["@I1@"]?.changeDate?.notes[1] {
      case .Note(let n):
        #expect(n.text == "Change date note 2")
      default :
        Issue.record("bad note in individual change date")
      }


      #expect(ged.individualRecordsMap["@I1@"]?.creationDate?.date.date == "27 MAR 2022")
      #expect(ged.individualRecordsMap["@I1@"]?.creationDate?.date.time == "08:55")

      #expect(ged.individualRecordsMap["@I2@"]?.names[0].name == "Maiden Name")
      #expect(ged.individualRecordsMap["@I2@"]?.names[0].type?.kind == .MAIDEN)

      #expect(ged.individualRecordsMap["@I2@"]?.names[1].name == "Married Name")
      #expect(ged.individualRecordsMap["@I2@"]?.names[1].type?.kind == .MARRIED)

      #expect(ged.individualRecordsMap["@I2@"]?.names[2].name == "Professional Name")
      #expect(ged.individualRecordsMap["@I2@"]?.names[2].type?.kind == .PROFESSIONAL)

      #expect(ged.individualRecordsMap["@I2@"]?.sex == .female)
      #expect(ged.individualRecordsMap["@I2@"]?.spouseFamilies[0].xref == "@F1@")

      #expect(ged.individualRecordsMap["@I3@"]?.sex == .other)

      #expect(ged.individualRecordsMap["@I4@"]?.sex == .unknown)
      #expect(ged.individualRecordsMap["@I4@"]?.childOfFamilies[0].xref == "@F1@")
    }

    // Family records
    @Test func families() async throws {


    }
  }
}
