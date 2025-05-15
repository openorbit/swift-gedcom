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
