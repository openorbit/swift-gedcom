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
}
