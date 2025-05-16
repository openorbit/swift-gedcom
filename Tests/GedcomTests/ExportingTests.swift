//
//  LoadingTests.swift
//  Gedcom
//
//  Created by Mattias Holm on 2024-11-28.
//

import Testing
import Foundation
@testable import Gedcom

@Suite("Export Gedcom") struct ExportTests {
  @Test("Header") func header() {
    let header = Header()
    header.schema = Schema()
    header.schema!.tags["_SKYPEID"] = URL(string: "http://xmlns.com/foaf/0.1/skypeID")
    header.schema!.tags["_JABBERID"] = URL(string: "http://xmlns.com/foaf/0.1/jabberID")
    header.source = HeaderSource(source: "https://gedcom.io/")
    header.source?.version = "0.4"
    header.source?.name = "GEDCOM Steering Committee"
    header.source?.corporation = HeaderSourceCorporation(corp: "FamilySearch")
    header.source?.corporation?.address = AddressStructure(addr: "Family History Department\n15 East South Temple Street\nSalt Lake City, UT 84150 USA")

    header.source?.corporation?.address?.adr1 = "Family History Department"
    header.source?.corporation?.address?.adr2 = "15 East South Temple Street"
    header.source?.corporation?.address?.adr3 = "Salt Lake City, UT 84150 USA"
    header.source?.corporation?.address?.city = "Salt Lake City"
    header.source?.corporation?.address?.state = "UT"
    header.source?.corporation?.address?.postalCode = "84150"
    header.source?.corporation?.address?.country = "USA"
    header.source?.corporation?.phone.append("+1 (555) 555-1212")
    header.source?.corporation?.phone.append("+1 (555) 555-1234")
    header.source?.corporation?.email.append("GEDCOM@FamilySearch.org")
    header.source?.corporation?.email.append("GEDCOM@example.com")
    header.source?.corporation?.fax.append("+1 (555) 555-1212")
    header.source?.corporation?.fax.append("+1 (555) 555-1234")
    header.source?.corporation?.www.append(URL(string: "http://gedcom.io")!)
    header.source?.corporation?.www.append(URL(string: "http://gedcom.info")!)

    header.source?.data = HeaderSourceData(data: "HEAD-SOUR-DATA")
    header.source?.data?.date = DateTimeExact(date: "1 NOV 2022", time: "8:38")
    header.source?.data?.copyright = "copyright statement"

    header.destination = "https://gedcom.io/"
    header.date = DateTimeExact(date: "10 JUN 2022", time: "15:43:20.48Z")
    header.submitter = "@U1@"
    header.copyright = "another copyright statement"
    header.lang = "en-US"

    header.place = HeaderPlace(form: ["City", "County", "State", "Country"])
    let note = Note(text: "American English", mime: "text/plain", lang: "en-US")
    note.mimeType = "text/plain"
    note.lang = "en-US"
    note.translations.append(Translation(text: "British English", lang: "en-GB"))
    note.citations.append(SourceCitation(xref: "@S1@", page: "1"))
    note.citations.append(SourceCitation(xref: "@S1@", page: "2"))
    header.note = NoteStructure.Note(note)

    let exp = header.export()
    #expect(exp != nil)

    exp?.setLevel(0)

    #expect(exp!.export() ==
      """
      0 HEAD
      1 GEDC
      2 VERS 7.0
      1 SCHMA
      2 TAG _JABBERID http://xmlns.com/foaf/0.1/jabberID
      2 TAG _SKYPEID http://xmlns.com/foaf/0.1/skypeID
      1 SOUR https://gedcom.io/
      2 VERS 0.4
      2 NAME GEDCOM Steering Committee
      2 CORP FamilySearch
      3 ADDR Family History Department
      4 CONT 15 East South Temple Street
      4 CONT Salt Lake City, UT 84150 USA
      4 ADR1 Family History Department
      4 ADR2 15 East South Temple Street
      4 ADR3 Salt Lake City, UT 84150 USA
      4 CITY Salt Lake City
      4 STAE UT
      4 POST 84150
      4 CTRY USA
      3 PHON +1 (555) 555-1212
      3 PHON +1 (555) 555-1234
      3 EMAIL GEDCOM@FamilySearch.org
      3 EMAIL GEDCOM@example.com
      3 FAX +1 (555) 555-1212
      3 FAX +1 (555) 555-1234
      3 WWW http://gedcom.io
      3 WWW http://gedcom.info
      2 DATA HEAD-SOUR-DATA
      3 DATE 1 NOV 2022
      4 TIME 8:38
      3 COPR copyright statement
      1 DEST https://gedcom.io/
      1 DATE 10 JUN 2022
      2 TIME 15:43:20.48Z
      1 SUBM @U1@
      1 COPR another copyright statement
      1 LANG en-US
      1 PLAC
      2 FORM City, County, State, Country
      1 NOTE American English
      2 MIME text/plain
      2 LANG en-US
      2 TRAN British English
      3 LANG en-GB
      2 SOUR @S1@
      3 PAGE 1
      2 SOUR @S1@
      3 PAGE 2
      
      """
    )
  }

  @Test("Repository") func sourceRepo() {
    let repo = Repository(xref: "@R1@", name: "Repository 1")
    repo.address = AddressStructure(addr: "Family History Department\n15 East South Temple Street\nSalt Lake City, UT 84150 USA")
    repo.address!.adr1 = "Family History Department"
    repo.address!.adr2 = "15 East South Temple Street"
    repo.address!.adr3 = "Salt Lake City, UT 84150 USA"
    repo.address!.city = "Salt Lake City"
    repo.address!.state = "UT"
    repo.address!.postalCode = "84150"
    repo.address!.country = "USA"
    repo.phoneNumbers = ["+1 (555) 555-1212", "+1 (555) 555-1234"]
    repo.emails = ["GEDCOM@FamilySearch.org", "GEDCOM@example.com"]
    repo.faxNumbers = ["+1 (555) 555-1212", "+1 (555) 555-1234"]
    repo.www = [URL(string: "http://gedcom.io")!, URL(string: "http://gedcom.info")!]
    repo.notes.append(.Note(Note(text: "Note text")))
    repo.notes.append(.SNote(SNoteRef(xref: "@N1@")))

    repo.identifiers.append(.Refn(REFN(ident: "1", type: "User-generated identifier")))
    repo.identifiers.append(.Refn(REFN(ident: "10", type: "User-generated identifier")))
    repo.identifiers.append(.Uuid(UID(ident: "efa7885b-c806-4590-9f1b-247797e4c96d")))
    repo.identifiers.append(.Uuid(UID(ident: "d530f6ab-cfd4-44cd-ab2c-e40bddb76bf8")))
    repo.identifiers.append(.Exid(EXID(ident: "123", type: "http://example.com")))
    repo.identifiers.append(.Exid(EXID(ident: "456", type: "http://example.com")))

    repo.changeDate = ChangeDate(date: "27 MAR 2022", time: "08:56")
    repo.changeDate!.notes.append(.Note(Note(text: "Change date note 1")))
    repo.changeDate!.notes.append(.Note(Note(text: "Change date note 2")))

    repo.creationDate = CreationDate(date: "27 MAR 2022", time: "08:55")


    let exp = repo.export()
    #expect(exp != nil)

    exp?.setLevel(0)

    #expect(exp!.export() ==
      """
      0 @R1@ REPO
      1 NAME Repository 1
      1 ADDR Family History Department
      2 CONT 15 East South Temple Street
      2 CONT Salt Lake City, UT 84150 USA
      2 ADR1 Family History Department
      2 ADR2 15 East South Temple Street
      2 ADR3 Salt Lake City, UT 84150 USA
      2 CITY Salt Lake City
      2 STAE UT
      2 POST 84150
      2 CTRY USA
      1 PHON +1 (555) 555-1212
      1 PHON +1 (555) 555-1234
      1 EMAIL GEDCOM@FamilySearch.org
      1 EMAIL GEDCOM@example.com
      1 FAX +1 (555) 555-1212
      1 FAX +1 (555) 555-1234
      1 WWW http://gedcom.io
      1 WWW http://gedcom.info
      1 NOTE Note text
      1 SNOTE @N1@
      1 REFN 1
      2 TYPE User-generated identifier
      1 REFN 10
      2 TYPE User-generated identifier
      1 UID efa7885b-c806-4590-9f1b-247797e4c96d
      1 UID d530f6ab-cfd4-44cd-ab2c-e40bddb76bf8
      1 EXID 123
      2 TYPE http://example.com
      1 EXID 456
      2 TYPE http://example.com
      1 CHAN
      2 DATE 27 MAR 2022
      3 TIME 08:56
      2 NOTE Change date note 1
      2 NOTE Change date note 2
      1 CREA
      2 DATE 27 MAR 2022
      3 TIME 08:55

      """)
  }

  @Test("Shared Note") func sharedNote() {
    let snote = SharedNote(xref: "@N1@", text: "Shared note 1", mime: "text/plain", lang: "en-US")
    snote.translations += [Translation(text: "Shared note 1", mime: "text/plain", lang: "en-GB")]
    snote.translations += [Translation(text: "Shared note 1", mime: "text/plain", lang: "en-CA")]

    snote.citations += [SourceCitation(xref: "@S1@", page: "1")]
    snote.citations += [SourceCitation(xref: "@S2@", page: "2")]

    snote.identifiers.append(.Refn(REFN(ident: "1", type: "User-generated identifier")))
    snote.identifiers.append(.Refn(REFN(ident: "10", type: "User-generated identifier")))
    snote.identifiers.append(.Uuid(UID(ident: "6efbee0b-96a1-43ea-83c8-828ec71c54d7")))
    snote.identifiers.append(.Uuid(UID(ident: "4094d92a-5525-44ec-973d-6c527aa5535a")))
    snote.identifiers.append(.Exid(EXID(ident: "123", type: "http://example.com")))
    snote.identifiers.append(.Exid(EXID(ident: "456", type: "http://example.com")))

    snote.changeDate = ChangeDate(date: "27 MAR 2022", time: "08:56")
    snote.changeDate!.notes.append(.Note(Note(text: "Change date note 1")))
    snote.changeDate!.notes.append(.Note(Note(text: "Change date note 2")))

    snote.creationDate = CreationDate(date: "27 MAR 2022", time: "08:55")

    let exp = snote.export()
    #expect(exp != nil)

    exp?.setLevel(0)

    #expect(exp!.export() ==
        """
        0 @N1@ SNOTE Shared note 1
        1 MIME text/plain
        1 LANG en-US
        1 TRAN Shared note 1
        2 MIME text/plain
        2 LANG en-GB
        1 TRAN Shared note 1
        2 MIME text/plain
        2 LANG en-CA
        1 SOUR @S1@
        2 PAGE 1
        1 SOUR @S2@
        2 PAGE 2
        1 REFN 1
        2 TYPE User-generated identifier
        1 REFN 10
        2 TYPE User-generated identifier
        1 UID 6efbee0b-96a1-43ea-83c8-828ec71c54d7
        1 UID 4094d92a-5525-44ec-973d-6c527aa5535a
        1 EXID 123
        2 TYPE http://example.com
        1 EXID 456
        2 TYPE http://example.com
        1 CHAN
        2 DATE 27 MAR 2022
        3 TIME 08:56
        2 NOTE Change date note 1
        2 NOTE Change date note 2
        1 CREA
        2 DATE 27 MAR 2022
        3 TIME 08:55
        
        """)
  }

  @Test("Source Record") func source() {
    let source = Source(xref: "@S1@")
    source.data = SourceData()
    source.data?.events += [SourceDataEvents(types: ["BIRT", "DEAT"])]
    source.data?.events[0].period = SourceDataEventPeriod(date: "FROM 1701 TO 1800",
                                                          phrase: "18th century")
    source.data?.events[0].place = PlaceStructure(place: ["Some City",
                                                          "Some County",
                                                          "Some State",
                                                          "Some Country"],
                                                  form: [
                                                    "City", "County", "State", "Country"
                                                  ],
                                                  lang: "en-US")
    source.data?.events[0].place?.translations += [
      PlaceTranslation(place: ["Some City", "Some County", "Some State", "Some Country"],
                       lang: "en-GB"),
      PlaceTranslation(place: ["Some City", "Some County", "Some State", "Some Country"],
                       lang: "en")
    ]

    source.data?.events[0].place?.map = PlaceCoordinates(lat: 18.150944, lon: 168.150944)

    source.data?.events[0].place?.exids.append(EXID(ident: "123", type: "http://example.com"))
    source.data?.events[0].place?.exids.append(EXID(ident: "456", type: "http://example.com"))

    let n = Note(text: "American English", mime: "text/plain", lang: "en-US")
    n.translations.append(Translation(text: "British English", lang: "en-GB"))
    n.citations.append(SourceCitation(xref: "@S1@", page: "1"))
    n.citations.append(SourceCitation(xref: "@S2@", page: "2"))
    source.data?.events[0].place?.notes.append(.Note(n))
    source.data?.events[0].place?.notes.append(.SNote(SNoteRef(xref: "@N1@")))


    source.data?.events += [SourceDataEvents(types: ["MARR"])]
    source.data?.events[1].period = SourceDataEventPeriod(date: "FROM 1701 TO 1800",
                                                          phrase: "18th century")

    source.data?.agency = "Agency name"
    source.data?.notes.append(.Note(n))
    source.data?.notes.append(.SNote(SNoteRef(xref: "@N1@")))

    source.author = "Author"
    source.title = "Title"
    source.abbreviation = "Abbreviation"
    source.publication = "Publication info"
    source.text = SourceText(text: "Source text", mime: "text/plain", lang: "en-US")

    source.sourceRepoCitation += [SourceRepositoryCitation(xref: "@R1@")]
    source.sourceRepoCitation[0].notes.append(.Note(Note(text: "Note text")))
    source.sourceRepoCitation[0].notes.append(.SNote(SNoteRef(xref: "@N1@")))
    source.sourceRepoCitation[0].callNumbers += [CallNumber(callNumber: "Call number", medium: Medium(kind: .BOOK, phrase: "Booklet"))]

    source.sourceRepoCitation += [SourceRepositoryCitation(xref: "@R2@")]
    source.sourceRepoCitation[1].callNumbers += [CallNumber(callNumber: "Call number", medium: Medium(kind: .VIDEO))]
    source.sourceRepoCitation[1].callNumbers += [CallNumber(callNumber: "Call number", medium: Medium(kind: .CARD))]
    source.sourceRepoCitation[1].callNumbers += [CallNumber(callNumber: "Call number", medium: Medium(kind: .FICHE))]
    source.sourceRepoCitation[1].callNumbers += [CallNumber(callNumber: "Call number", medium: Medium(kind: .FILM))]
    source.sourceRepoCitation[1].callNumbers += [CallNumber(callNumber: "Call number", medium: Medium(kind: .MAGAZINE))]
    source.sourceRepoCitation[1].callNumbers += [CallNumber(callNumber: "Call number", medium: Medium(kind: .MANUSCRIPT))]
    source.sourceRepoCitation[1].callNumbers += [CallNumber(callNumber: "Call number", medium: Medium(kind: .MAP))]
    source.sourceRepoCitation[1].callNumbers += [CallNumber(callNumber: "Call number", medium: Medium(kind: .NEWSPAPER))]
    source.sourceRepoCitation[1].callNumbers += [CallNumber(callNumber: "Call number", medium: Medium(kind: .PHOTO))]
    source.sourceRepoCitation[1].callNumbers += [CallNumber(callNumber: "Call number", medium: Medium(kind: .TOMBSTONE))]

    source.identifiers.append(.Refn(REFN(ident: "1", type: "User-generated identifier")))
    source.identifiers.append(.Refn(REFN(ident: "10", type: "User-generated identifier")))
    source.identifiers.append(.Uuid(UID(ident: "f065a3e8-5c03-4b4a-a89d-6c5e71430a8d")))
    source.identifiers.append(.Uuid(UID(ident: "9441c3f3-74df-42b4-bbc1-fed42fd7f536")))
    source.identifiers.append(.Exid(EXID(ident: "123", type: "http://example.com")))
    source.identifiers.append(.Exid(EXID(ident: "456", type: "http://example.com")))

    source.notes += [.Note(Note(text: "Note text")), .SNote(SNoteRef(xref: "@N1@"))]
    source.multimediaLinks += [MultimediaLink(xref: "@O1@"), MultimediaLink(xref: "@O2@")]

    source.changeDate = ChangeDate(date: "27 MAR 2022", time: "08:56")
    source.changeDate?.notes = [
      .Note(Note(text: "Change date note 1")),
      .Note(Note(text: "Change date note 2")),
    ]
    source.creationDate = CreationDate(date: "27 MAR 2022", time: "08:55")

    let exp = source.export()
    #expect(exp != nil)

    exp?.setLevel(0)

    // From the first submitter example

    let expected =
        """
        0 @S1@ SOUR
        1 DATA
        2 EVEN BIRT, DEAT
        3 DATE FROM 1701 TO 1800
        4 PHRASE 18th century
        3 PLAC Some City, Some County, Some State, Some Country
        4 FORM City, County, State, Country
        4 LANG en-US
        4 TRAN Some City, Some County, Some State, Some Country
        5 LANG en-GB
        4 TRAN Some City, Some County, Some State, Some Country
        5 LANG en
        4 MAP
        5 LATI N18.150944
        5 LONG E168.150944
        4 EXID 123
        5 TYPE http://example.com
        4 EXID 456
        5 TYPE http://example.com
        4 NOTE American English
        5 MIME text/plain
        5 LANG en-US
        5 TRAN British English
        6 LANG en-GB
        5 SOUR @S1@
        6 PAGE 1
        5 SOUR @S2@
        6 PAGE 2
        4 SNOTE @N1@
        2 EVEN MARR
        3 DATE FROM 1701 TO 1800
        4 PHRASE 18th century
        2 AGNC Agency name
        2 NOTE American English
        3 MIME text/plain
        3 LANG en-US
        3 TRAN British English
        4 LANG en-GB
        3 SOUR @S1@
        4 PAGE 1
        3 SOUR @S2@
        4 PAGE 2
        2 SNOTE @N1@
        1 AUTH Author
        1 TITL Title
        1 ABBR Abbreviation
        1 PUBL Publication info
        1 TEXT Source text
        2 MIME text/plain
        2 LANG en-US
        1 REPO @R1@
        2 NOTE Note text
        2 SNOTE @N1@
        2 CALN Call number
        3 MEDI BOOK
        4 PHRASE Booklet
        1 REPO @R2@
        2 CALN Call number
        3 MEDI VIDEO
        2 CALN Call number
        3 MEDI CARD
        2 CALN Call number
        3 MEDI FICHE
        2 CALN Call number
        3 MEDI FILM
        2 CALN Call number
        3 MEDI MAGAZINE
        2 CALN Call number
        3 MEDI MANUSCRIPT
        2 CALN Call number
        3 MEDI MAP
        2 CALN Call number
        3 MEDI NEWSPAPER
        2 CALN Call number
        3 MEDI PHOTO
        2 CALN Call number
        3 MEDI TOMBSTONE
        1 REFN 1
        2 TYPE User-generated identifier
        1 REFN 10
        2 TYPE User-generated identifier
        1 UID f065a3e8-5c03-4b4a-a89d-6c5e71430a8d
        1 UID 9441c3f3-74df-42b4-bbc1-fed42fd7f536
        1 EXID 123
        2 TYPE http://example.com
        1 EXID 456
        2 TYPE http://example.com
        1 NOTE Note text
        1 SNOTE @N1@
        1 OBJE @O1@
        1 OBJE @O2@
        1 CHAN
        2 DATE 27 MAR 2022
        3 TIME 08:56
        2 NOTE Change date note 1
        2 NOTE Change date note 2
        1 CREA
        2 DATE 27 MAR 2022
        3 TIME 08:55
        
        """.split(separator: "\n")

    let exported = exp!.export().split(separator: "\n")

    for (v, e) in zip(exported, expected) {
      #expect(v == e)
    }
  }

  @Test("Submitter Record") func submitter() {
    let submitter = Submitter(xref: "@U1@", name: "GEDCOM Steering Committee")
    submitter.address = AddressStructure(addr: "Family History Department\n15 East South Temple Street\nSalt Lake City, UT 84150 USA")
    submitter.address?.adr1 = "Family History Department"
    submitter.address?.adr2 = "15 East South Temple Street"
    submitter.address?.adr3 = "Salt Lake City, UT 84150 USA"
    submitter.address?.city = "Salt Lake City"
    submitter.address?.state = "UT"
    submitter.address?.postalCode = "84150"
    submitter.address?.country = "USA"

    submitter.phone = ["+1 (555) 555-1212", "+1 (555) 555-1234"]
    submitter.email = ["GEDCOM@FamilySearch.org", "GEDCOM@example.com"]
    submitter.fax = ["+1 (555) 555-1212", "+1 (555) 555-1234"]
    submitter.www = [URL(string: "http://gedcom.io")!, URL(string: "http://gedcom.info")!]

    submitter.multimediaLinks.append(MultimediaLink(xref: "@O1@", crop: Crop(top: 0, left: 0, height: 100, width: 100), title: "Title"))
    submitter.multimediaLinks.append(MultimediaLink(xref: "@O1@", crop: Crop(top: 100, left: 100), title: "Title"))

    submitter.languages = ["en-US", "en-GB"]

    submitter.identifiers.append(.Refn(REFN(ident: "1", type: "User-generated identifier")))
    submitter.identifiers.append(.Refn(REFN(ident: "10", type: "User-generated identifier")))
    submitter.identifiers.append(.Uuid(UID(ident: "24132fe0-26f6-4f87-9924-389a4f40f0ec")))
    submitter.identifiers.append(.Uuid(UID(ident: "b451c8df-5550-473b-a55c-ed31e65c60c8")))
    submitter.identifiers.append(.Exid(EXID(ident: "123", type: "http://example.com")))
    submitter.identifiers.append(.Exid(EXID(ident: "456", type: "http://example.com")))

    let n = Note(text: "American English", mime: "text/plain", lang: "en-US")
    n.translations.append(Translation(text: "British English", lang: "en-GB"))
    n.citations.append(SourceCitation(xref: "@S1@", page: "1"))
    n.citations.append(SourceCitation(xref: "@S2@", page: "2"))
    submitter.notes.append(.Note(n))
    submitter.notes.append(.SNote(SNoteRef(xref: "@N1@")))

    submitter.changeDate = ChangeDate(date: "27 MAR 2022", time: "08:56")
    submitter.changeDate!.notes.append(.Note(Note(text: "Change date note 1")))
    submitter.changeDate!.notes.append(.Note(Note(text: "Change date note 2")))

    submitter.creationDate = CreationDate(date: "27 MAR 2022", time: "08:55")

    let exp = submitter.export()
    #expect(exp != nil)

    exp?.setLevel(0)

    // From the first submitter example
    #expect(exp!.export() ==
        """
        0 @U1@ SUBM
        1 NAME GEDCOM Steering Committee
        1 ADDR Family History Department
        2 CONT 15 East South Temple Street
        2 CONT Salt Lake City, UT 84150 USA
        2 ADR1 Family History Department
        2 ADR2 15 East South Temple Street
        2 ADR3 Salt Lake City, UT 84150 USA
        2 CITY Salt Lake City
        2 STAE UT
        2 POST 84150
        2 CTRY USA
        1 PHON +1 (555) 555-1212
        1 PHON +1 (555) 555-1234
        1 EMAIL GEDCOM@FamilySearch.org
        1 EMAIL GEDCOM@example.com
        1 FAX +1 (555) 555-1212
        1 FAX +1 (555) 555-1234
        1 WWW http://gedcom.io
        1 WWW http://gedcom.info
        1 OBJE @O1@
        2 CROP
        3 TOP 0
        3 LEFT 0
        3 HEIGHT 100
        3 WIDTH 100
        2 TITL Title
        1 OBJE @O1@
        2 CROP
        3 TOP 100
        3 LEFT 100
        2 TITL Title
        1 LANG en-US
        1 LANG en-GB
        1 REFN 1
        2 TYPE User-generated identifier
        1 REFN 10
        2 TYPE User-generated identifier
        1 UID 24132fe0-26f6-4f87-9924-389a4f40f0ec
        1 UID b451c8df-5550-473b-a55c-ed31e65c60c8
        1 EXID 123
        2 TYPE http://example.com
        1 EXID 456
        2 TYPE http://example.com
        1 NOTE American English
        2 MIME text/plain
        2 LANG en-US
        2 TRAN British English
        3 LANG en-GB
        2 SOUR @S1@
        3 PAGE 1
        2 SOUR @S2@
        3 PAGE 2
        1 SNOTE @N1@
        1 CHAN
        2 DATE 27 MAR 2022
        3 TIME 08:56
        2 NOTE Change date note 1
        2 NOTE Change date note 2
        1 CREA
        2 DATE 27 MAR 2022
        3 TIME 08:55
        
        """
        //  1 _SKYPEID example.person
        //  1 _JABBERID person@example.com
    )
  }
}
