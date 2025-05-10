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

      #expect(ged.submitterRecordsMap["@U1@"]!.address?.address == "Family History Department\n15 East South Temple Street\nSalt Lake City, UT 84150 USA")
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
      #expect(ged.repositoryRecordsMap["@R1@"]!.name == "Repository 1")
      #expect(ged.repositoryRecordsMap["@R1@"]!.address!.address == "Family History Department\n15 East South Temple Street\nSalt Lake City, UT 84150 USA")
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

      #expect(ged.individualRecordsMap["@I1@"]?.names[0].name == "Lt. Cmndr. Joseph \"John\" /de Allen/ jr.")
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].type?.kind == .OTHER)
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].type?.phrase == "Name type phrase")

      #expect(ged.individualRecordsMap["@I1@"]?.names[0].namePieces.count == 6)
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].namePieces[0] == .NPFX("Lt. Cmndr."))
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].namePieces[1] == .GIVN("Joseph"))
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].namePieces[2] == .NICK("John"))
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].namePieces[3] == .SPFX("de"))
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].namePieces[4] == .SURN("Allen"))
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].namePieces[5] == .NSFX("jr."))
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].translations[0].name == "npfx John /spfx Doe/ nsfx")
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].translations[0].lang == "en-GB")
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].translations[0].namePieces[0] == .NPFX("npfx"))
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].translations[0].namePieces[1] == .GIVN("John"))
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].translations[0].namePieces[2] == .NICK("John"))
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].translations[0].namePieces[3] == .SPFX("spfx"))
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].translations[0].namePieces[4] == .SURN("Doe"))
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].translations[0].namePieces[5] == .NSFX("nsfx"))

      #expect(ged.individualRecordsMap["@I1@"]?.names[0].translations[1].name == "John /Doe/")
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].translations[1].lang == "en-CA")

      #expect(ged.individualRecordsMap["@I1@"]?.names[0].notes.count == 3)
      switch ged.individualRecordsMap["@I1@"]?.names[0].notes[0] {
      case .Note(let n):
        #expect(n.text == "Note text")
        break
      default:
        Issue.record("bad note in individual name")
      }
      switch ged.individualRecordsMap["@I1@"]?.names[0].notes[1] {
      case .SNote(let n):
        #expect(n.xref == "@N1@")
        break
      default:
        Issue.record("bad note in individual name")
      }
      switch ged.individualRecordsMap["@I1@"]?.names[0].notes[2] {
      case .SNote(let n):
        #expect(n.xref == "@VOID@")
        break
      default:
        Issue.record("bad note in individual name")
      }


      #expect(ged.individualRecordsMap["@I1@"]?.names[0].citations.count == 2)
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].citations[0].xref == "@S1@")
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].citations[0].page == "1")
      #expect(ged.individualRecordsMap["@I1@"]?.names[0].citations[1].xref == "@S2@")

      #expect(ged.individualRecordsMap["@I1@"]?.names[1].name == "John /Doe/")
      #expect(ged.individualRecordsMap["@I1@"]?.names[1].type?.kind == .BIRTH)

      #expect(ged.individualRecordsMap["@I1@"]?.names[2].name == "Aka")
      #expect(ged.individualRecordsMap["@I1@"]?.names[2].type?.kind == .AKA)

      #expect(ged.individualRecordsMap["@I1@"]?.names[3].name == "Immigrant Name")
      #expect(ged.individualRecordsMap["@I1@"]?.names[3].type?.kind == .IMMIGRANT)

      #expect(ged.individualRecordsMap["@I1@"]?.sex == .male)

/*
// Facts
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
 */

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents.count == 26)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[0].kind == .BAPM)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[0].type == "bapm type")

      // TOOD: 1 BAPM Y
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[1].kind == .BAPM)


      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[2].kind == .BARM)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[2].type == "barm type")

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[3].kind == .BASM)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[3].type == "basm type")

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[4].kind == .BLES)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[4].type == "bles type")

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[5].kind == .BURI)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[5].type == "buri type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[5].date?.date == "30 MAR 2022")

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[6].kind == .CENS)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[6].type == "cens type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[7].kind == .CHRA)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[7].type == "chra type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[8].kind == .CONF)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[8].type == "conf type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[9].kind == .CREM)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[9].type == "crem type")

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].kind == .DEAT)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].type == "deat type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].date?.date == "28 MAR 2022")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].place?.place == ["Somewhere"])
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].address?.address == "Address")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].phone == ["+1 (555) 555-1212", "+1 (555) 555-1234"])
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].email == ["GEDCOM@FamilySearch.org", "GEDCOM@example.com"])
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].fax == ["+1 (555) 555-1212", "+1 (555) 555-1234"])
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].www == [URL(string: "http://gedcom.io")!, URL(string: "http://gedcom.info")!])
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].agency == "Agency")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].religion == "Religion")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].cause == "Cause of death")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].cause == "Cause of death")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].restrictions == [.CONFIDENTIAL, .LOCKED])
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].sdate?.date == "28 MAR 2022")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].sdate?.time == "16:47")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].sdate?.phrase == "sdate phrase")

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].associations[0].xref == "@I3@")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].associations[0].role?.kind == .CHIL)

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].associations[1].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].associations[1].role?.kind == .PARENT)
      switch ged.individualRecordsMap["@I1@"]?.individualEvents[10].notes[0] {
      case .Note(let n):
        #expect(n.text == "Note text")
      default:
        Issue.record("bad note in individual event")
      }
      switch ged.individualRecordsMap["@I1@"]?.individualEvents[10].notes[1] {
      case .SNote(let n):
        #expect(n.xref == "@N1@")
      default:
        Issue.record("bad note in individual event")
      }

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].citations[0].xref == "@S1@")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].citations[0].page == "1")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].citations[1].xref == "@S2@")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].citations[1].page == "2")

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].multimediaLinks[0].xref == "@O1@")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].multimediaLinks[1].xref == "@O2@")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[10].uid == [
        UUID(uuidString: "82092878-6f4f-4bca-ad59-d1ae87c5e521")!,
        UUID(uuidString: "daf4b8c0-4141-42c4-bec8-01d1d818dfaf")!])

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[11].kind == .EMIG)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[11].type == "emig type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[12].kind == .FCOM)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[12].type == "fcom type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[13].kind == .GRAD)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[13].type == "grad type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[14].kind == .IMMI)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[14].type == "immi type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[15].kind == .NATU)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[15].type == "natu type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[16].kind == .ORDN)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[16].type == "ordn type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[17].kind == .PROB)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[17].type == "prob type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[18].kind == .RETI)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[18].type == "reti type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[19].kind == .WILL)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[19].type == "will type")

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[20].kind == .ADOP)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[20].type == "adop type")
      /*
      1 ADOP
        2 FAMC @VOID@
          3 ADOP BOTH
            4 PHRASE Adoption phrase
      */
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[21].kind == .ADOP)
      /*
      1 ADOP
        2 FAMC @VOID@
          3 ADOP HUSB
       */
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[22].kind == .ADOP)
      /*
      1 ADOP
        2 FAMC @VOID@
          3 ADOP WIFE
*/
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[23].kind == .BIRT)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[23].type == "birth type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[23].date?.date == "1 JAN 2000")

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[24].kind == .CHR)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[24].type == "chr type")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[24].date?.date == "9 JAN 2000")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[24].age?.age == "8d")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[24].age?.phrase == "Age phrase")

      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[25].kind == .EVEN)
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[25].text == "Event")
      #expect(ged.individualRecordsMap["@I1@"]?.individualEvents[25].type == "Event type")



      /*
      // non event structures
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


      // LDS_INDIVIDUAL_ORDINANCE
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
      */

      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies.count == 5)
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[0].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[0].pedigree?.kind == .OTHER)
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[0].pedigree?.phrase == "Other type")
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[0].status?.kind == .CHALLENGED)
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[0].status?.phrase == "Phrase")

      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[1].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[1].pedigree?.kind == .FOSTER)
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[2].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[2].pedigree?.kind == .SEALING)
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[3].xref == "@F2@")
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[3].pedigree?.kind == .ADOPTED)
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[3].status?.kind == .PROVEN)
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[4].xref == "@F2@")
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[4].pedigree?.kind == .BIRTH)
      #expect(ged.individualRecordsMap["@I1@"]?.childOfFamilies[4].status?.kind == .DISPROVEN)

      #expect(ged.individualRecordsMap["@I1@"]?.spouseFamilies.count == 2)
      #expect(ged.individualRecordsMap["@I1@"]?.spouseFamilies[0].xref == "@VOID@")
      switch ged.individualRecordsMap["@I1@"]?.spouseFamilies[0].notes[0] {
      case .Note(let n):
        #expect(n.text == "Note text")
      default:
        Issue.record("bad note in individual fams")
      }
      switch ged.individualRecordsMap["@I1@"]?.spouseFamilies[0].notes[1] {
      case .SNote(let n):
        #expect(n.xref == "@N1@")
      default:
        Issue.record("bad note in individual fams")
      }

      #expect(ged.individualRecordsMap["@I1@"]?.spouseFamilies[1].xref == "@F1@")

      #expect(ged.individualRecordsMap["@I1@"]?.submitters.count == 2)
      #expect(ged.individualRecordsMap["@I1@"]?.submitters[0] == "@U1@")
      #expect(ged.individualRecordsMap["@I1@"]?.submitters[1] == "@U2@")

      #expect(ged.individualRecordsMap["@I1@"]?.associations.count == 9)
      #expect(ged.individualRecordsMap["@I1@"]?.associations[0].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.associations[0].phrase == "Mr Stockdale")
      #expect(ged.individualRecordsMap["@I1@"]?.associations[0].role?.kind == .FRIEND)

      #expect(ged.individualRecordsMap["@I1@"]?.associations[1].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.associations[1].role?.kind == .NGHBR)

      #expect(ged.individualRecordsMap["@I1@"]?.associations[2].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.associations[2].role?.kind == .FATH)

      #expect(ged.individualRecordsMap["@I1@"]?.associations[3].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.associations[3].role?.kind == .GODP)

      #expect(ged.individualRecordsMap["@I1@"]?.associations[4].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.associations[4].role?.kind == .HUSB)

      #expect(ged.individualRecordsMap["@I1@"]?.associations[5].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.associations[5].role?.kind == .MOTH)

      #expect(ged.individualRecordsMap["@I1@"]?.associations[6].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.associations[6].role?.kind == .MULTIPLE)

      #expect(ged.individualRecordsMap["@I1@"]?.associations[7].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.associations[7].role?.kind == .SPOU)

      #expect(ged.individualRecordsMap["@I1@"]?.associations[8].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.associations[8].role?.kind == .WIFE)

      #expect(ged.individualRecordsMap["@I1@"]?.aliases.count == 2)
      #expect(ged.individualRecordsMap["@I1@"]?.aliases[0].xref == "@VOID@")
      #expect(ged.individualRecordsMap["@I1@"]?.aliases[1].xref == "@I3@")
      #expect(ged.individualRecordsMap["@I1@"]?.aliases[1].phrase == "Alias")

      #expect(ged.individualRecordsMap["@I1@"]?.ancestorInterest.count == 2)
      #expect(ged.individualRecordsMap["@I1@"]?.ancestorInterest[0] == "@U1@")
      #expect(ged.individualRecordsMap["@I1@"]?.ancestorInterest[1] == "@VOID@")

      #expect(ged.individualRecordsMap["@I1@"]?.decendantInterest.count == 2)
      #expect(ged.individualRecordsMap["@I1@"]?.decendantInterest[0] == "@U1@")
      #expect(ged.individualRecordsMap["@I1@"]?.decendantInterest[1] == "@VOID@")

      #expect(ged.individualRecordsMap["@I1@"]?.identifiers.count == 6)
      switch ged.individualRecordsMap["@I1@"]?.identifiers[0] {
      case .Refn(let ident):
        #expect(ident.refn == "1")
        #expect(ident.type == "User-generated identifier")
      default:
        Issue.record("bad identifier in individual")
      }

      switch ged.individualRecordsMap["@I1@"]?.identifiers[1] {
      case .Refn(let ident):
        #expect(ident.refn == "10")
        #expect(ident.type == "User-generated identifier")
      default:
        Issue.record("bad identifier in individual")
      }

      switch ged.individualRecordsMap["@I1@"]?.identifiers[2] {
      case .Uuid(let ident):
        #expect(ident.uid == UUID(uuidString: "3d75b5eb-36e9-40b3-b79f-f088b5c18595")!)
      default:
        Issue.record("bad identifier in individual")
      }

      switch ged.individualRecordsMap["@I1@"]?.identifiers[3] {
      case .Uuid(let ident):
        #expect(ident.uid == UUID(uuidString: "cb49c361-7124-447e-b587-4c6d36e51825")!)
      default:
        Issue.record("bad identifier in individual")
      }

      switch ged.individualRecordsMap["@I1@"]?.identifiers[4] {
      case .Exid(let ident):
        #expect(ident.exid == "123")
        #expect(ident.type == "http://example.com")
      default:
        Issue.record("bad identifier in individual")
      }

      switch ged.individualRecordsMap["@I1@"]?.identifiers[5] {
      case .Exid(let ident):
        #expect(ident.exid == "456")
        #expect(ident.type == "http://example.com")

      default:
        Issue.record("bad identifier in individual")
      }


      #expect(ged.individualRecordsMap["@I1@"]?.notes.count == 2)
      switch ged.individualRecordsMap["@I1@"]?.notes[0] {
      case .Note(let n):
        #expect(n.text == "me@example.com is an example email address.\n@@me and @I are example social media handles.\n@@@@@ has four @ characters where only the first is escaped.")
      default:
        Issue.record("bad note in individual")
      }
      switch ged.individualRecordsMap["@I1@"]?.notes[1] {
      case .SNote(let n):
        #expect(n.xref == "@N1@")
      default:
        Issue.record("bad note in individual")
      }

      #expect(ged.individualRecordsMap["@I1@"]?.citations.count == 2)
      #expect(ged.individualRecordsMap["@I1@"]?.citations[0].xref == "@S1@")
      #expect(ged.individualRecordsMap["@I1@"]?.citations[0].page == "1")
      #expect(ged.individualRecordsMap["@I1@"]?.citations[0].quality == 3)
      #expect(ged.individualRecordsMap["@I1@"]?.citations[1].xref == "@S2@")

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
