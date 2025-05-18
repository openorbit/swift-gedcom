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

    #expect(exp.export() ==
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

  @Test("Family") func family() {
    let family = Family(xref: "@F1@")
    family.restrictions = [.CONFIDENTIAL, .LOCKED]

    family.attributes += [
      FamilyAttribute(kind: .NCHI, text: "2", type: "Type of children",
                      husband: SpouseAge(kind: "HUSB", age: "25y", phrase: "Adult"),
                      wife: SpouseAge(kind: "WIFE", age: "25y", phrase: "Adult")),
      FamilyAttribute(kind: .RESI, text: "Residence", type: "Type of residence",
                      husband: SpouseAge(kind: "HUSB", age: "25y", phrase: "Adult"),
                      wife: SpouseAge(kind: "WIFE", age: "25y", phrase: "Adult")),
      FamilyAttribute(kind: .FACT, text: "Fact", type: "Type of fact",
                      husband: SpouseAge(kind: "HUSB", age: "25y", phrase: "Adult"),
                      wife: SpouseAge(kind: "WIFE", age: "25y", phrase: "Adult")),
    ]
    family.events += [
      FamilyEvent(kind: .ANUL, occured: true),
      FamilyEvent(kind: .CENS, occured: true),
      FamilyEvent(kind: .DIV, occured: true),
      FamilyEvent(kind: .DIVF, occured: true),
      FamilyEvent(kind: .ENGA, occured: true),
      FamilyEvent(kind: .MARB, occured: true),
      FamilyEvent(kind: .MARC, occured: true),
      FamilyEvent(kind: .MARL, occured: true),
      FamilyEvent(kind: .MARS, occured: true),
      FamilyEvent(kind: .MARR, occured: true,
                  husband: SpouseAge(kind: "HUSB", age: "25y", phrase: "Adult"),
                  wife: SpouseAge(kind: "WIFE", age: "25y", phrase: "Adult"),
                  date: DateValue(date: "27 MAR 2022", time: "16:02", phrase: "Afternoon"),
                  sdate: DateValue(date: "27 MAR 2022", time: "16:03", phrase: "Afternoon"),
                  place: PlaceStructure(place: ["Place"]),
                  address: AddressStructure(addr: "Address"),
                  phones: ["+1 (555) 555-1212", "+1 (555) 555-1234"],
                  emails: ["GEDCOM@FamilySearch.org", "GEDCOM@example.com"],
                  faxes: ["+1 (555) 555-1212", "+1 (555) 555-1234"],
                  urls: [URL(string: "http://gedcom.io")!,
                         URL(string: "http://gedcom.info")!],
                  agency: "Agency",
                  religion: "Religion",
                  cause: "Cause",
                  restrictions: [.CONFIDENTIAL, .LOCKED],
                  associations: [AssoiciationStructure(xref: "@VOID@",
                                                       role: Role(kind: .OFFICIATOR)),
                                 AssoiciationStructure(xref: "@VOID@",
                                                       role: Role(kind: .WITN),
                                                       notes: [
                                                        .Note(Note(text: "Note text"))
                                                       ]),
                  ],
                  notes: [
                    .SNote(SNoteRef(xref: "@N1@"))
                  ],
                  citations: [
                    SourceCitation(xref: "@S1@", page: "1"),
                    SourceCitation(xref: "@S1@", page: "2"),
                  ],
                  multimediaLinks: [
                    MultimediaLink(xref: "@O1@"),
                    MultimediaLink(xref: "@O2@"),
                  ],
                  uids: [
                    UUID(uuidString: "bbcc0025-34cb-4542-8cfb-45ba201c9c2c")!,
                    UUID(uuidString: "9ead4205-5bad-4c05-91c1-0aecd3f5127d")!
                  ]
      ),
      FamilyEvent(kind: .EVEN, text: "Event", type: "Event type"),
    ]
    family.nonEvents += [
      NonFamilyEventStructure(kind: .DIV,
                              date: DatePeriod(date: "FROM 1700 TO 1800",
                                               phrase: "No date phrase"),
                              notes: [
                                .Note(Note(text: "Note text")),
                                .SNote(SNoteRef(xref: "@N2@")),
                              ],
                              citations: [
                                SourceCitation(xref: "@S1@", page: "1"),
                                SourceCitation(xref: "@S1@", page: "2"),
                              ]),
      .init(kind: .ANUL),
    ]
    family.husband = PhraseRef(tag: "HUSB", xref: "@I1@", phrase: "Husband phrase")
    family.wife = PhraseRef(tag: "WIFE", xref: "@I2@", phrase: "Wife phrase")
    family.children = [
      PhraseRef(tag: "CHIL", xref: "@I4@", phrase: "First child"),
      PhraseRef(tag: "CHIL", xref: "@VOID@", phrase: "Second child")
    ]
    family.associations = [
      AssoiciationStructure(xref: "@I3@",
                            phrase: "Association text",
                            role: Role(kind: .OTHER, phrase: "Role text"),
                            notes: [
                              .Note(Note(text: "Note text")),
                              .SNote(SNoteRef(xref: "@N1@"))
                            ],
                            citations: [
                              SourceCitation(xref: "@S1@", page: "1"),
                              SourceCitation(xref: "@S2@", page: "2")
                            ]),
      AssoiciationStructure(xref: "@VOID@",
                            role: Role(kind: .CLERGY))
    ]
    family.submitters = ["@U1@", "@U2@", "@VOID@"]
    family.ldsSpouseSealings = [
      .init(date: .init(date: "27 MAR 2022", time: "15:47", phrase: "Afternoon"),
            temple: "LOGAN",
            place: .init(place: ["Place"]),
            status: .init(kind: .COMPLETED,
                          date: .init(date: "27 MAR 2022", time: "15:48")),
            notes: [
              .Note(Note(text: "Note text")),
              .SNote(SNoteRef(xref: "@N1@"))
            ],
            citations: [
              .init(xref: "@S1@", page: "1"),
              .init(xref: "@S2@", page: "2")
            ]),
      .init(date: .init(date: "27 MAR 2022"),
            status: .init(kind: .CANCELED,
                          date: .init(date: "27 MAR 2022"))),
      .init(date: .init(date: "27 MAR 2022"),
            status: .init(kind: .EXCLUDED,
                          date: .init(date: "27 MAR 2022"))),
      .init(date: .init(date: "27 MAR 2022"),
            status: .init(kind: .DNS,
                          date: .init(date: "27 MAR 2022"))),
      .init(date: .init(date: "27 MAR 2022"),
            status: .init(kind: .DNS_CAN,
                          date: .init(date: "27 MAR 2022"))),
      .init(date: .init(date: "27 MAR 2022"),
            status: .init(kind: .PRE_1970,
                          date: .init(date: "27 MAR 2022"))),
      .init(date: .init(date: "27 MAR 2022"),
            status: .init(kind: .UNCLEARED,
                          date: .init(date: "27 MAR 2022")))
    ]

    family.identifiers = [
      .Refn(REFN(ident: "1", type: "User-generated identifier")),
      .Refn(REFN(ident: "10", type: "User-generated identifier")),
      .Uuid(UID(ident: "f096b664-5e40-40e2-bb72-c1664a46fe45")),
      .Uuid(UID(ident: "1f76f868-8a36-449c-af0d-a29247b3ab50")),
      .Exid(EXID(ident: "123", type: "http://example.com")),
      .Exid(EXID(ident: "456", type: "http://example.com")),
    ]

    family.notes = [
      .Note(Note(text: "Note text")),
      .SNote(SNoteRef(xref: "@N1@")),
    ]

    family.citations = [
      SourceCitation(xref: "@S1@", page: "1", quality: 1),
      SourceCitation(xref: "@S2@", page: "2", quality: 2),
    ]
    family.multimediaLinks = [
      .init(xref: "@O1@"),
      .init(xref: "@O2@"),
      .init(xref: "@VOID@", title: "Title"),
    ]
    family.changeDate = ChangeDate(date: "27 MAR 2022", time: "08:56",
                                   notes: [
                                    .Note(Note(text: "Change date note 1")),
                                    .Note(Note(text: "Change date note 2")),
                                   ])
    family.creationDate = CreationDate(date: "27 MAR 2022", time: "08:55")
    
    let exp = family.export()

    let exported = exp.export().split(separator: "\n")
    let expected =
      """
      0 @F1@ FAM
      1 RESN CONFIDENTIAL, LOCKED
      1 NCHI 2
      2 TYPE Type of children
      2 HUSB
      3 AGE 25y
      4 PHRASE Adult
      2 WIFE
      3 AGE 25y
      4 PHRASE Adult
      1 RESI Residence
      2 TYPE Type of residence
      2 HUSB
      3 AGE 25y
      4 PHRASE Adult
      2 WIFE
      3 AGE 25y
      4 PHRASE Adult
      1 FACT Fact
      2 TYPE Type of fact
      2 HUSB
      3 AGE 25y
      4 PHRASE Adult
      2 WIFE
      3 AGE 25y
      4 PHRASE Adult
      1 ANUL Y
      1 CENS Y
      1 DIV Y
      1 DIVF Y
      1 ENGA Y
      1 MARB Y
      1 MARC Y
      1 MARL Y
      1 MARS Y
      1 MARR Y
      2 HUSB
      3 AGE 25y
      4 PHRASE Adult
      2 WIFE
      3 AGE 25y
      4 PHRASE Adult
      2 DATE 27 MAR 2022
      3 TIME 16:02
      3 PHRASE Afternoon
      2 PLAC Place
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
      2 CAUS Cause
      2 RESN CONFIDENTIAL, LOCKED
      2 SDATE 27 MAR 2022
      3 TIME 16:03
      3 PHRASE Afternoon
      2 ASSO @VOID@
      3 ROLE OFFICIATOR
      2 ASSO @VOID@
      3 ROLE WITN
      3 NOTE Note text
      2 SNOTE @N1@
      2 SOUR @S1@
      3 PAGE 1
      2 SOUR @S1@
      3 PAGE 2
      2 OBJE @O1@
      2 OBJE @O2@
      2 UID bbcc0025-34cb-4542-8cfb-45ba201c9c2c
      2 UID 9ead4205-5bad-4c05-91c1-0aecd3f5127d
      1 EVEN Event
      2 TYPE Event type
      1 NO DIV
      2 DATE FROM 1700 TO 1800
      3 PHRASE No date phrase
      2 NOTE Note text
      2 SNOTE @N2@
      2 SOUR @S1@
      3 PAGE 1
      2 SOUR @S1@
      3 PAGE 2
      1 NO ANUL
      1 HUSB @I1@
      2 PHRASE Husband phrase
      1 WIFE @I2@
      2 PHRASE Wife phrase
      1 CHIL @I4@
      2 PHRASE First child
      1 CHIL @VOID@
      2 PHRASE Second child
      1 ASSO @I3@
      2 PHRASE Association text
      2 ROLE OTHER
      3 PHRASE Role text
      2 NOTE Note text
      2 SNOTE @N1@
      2 SOUR @S1@
      3 PAGE 1
      2 SOUR @S2@
      3 PAGE 2
      1 ASSO @VOID@
      2 ROLE CLERGY
      1 SUBM @U1@
      1 SUBM @U2@
      1 SUBM @VOID@
      1 SLGS
      2 DATE 27 MAR 2022
      3 TIME 15:47
      3 PHRASE Afternoon
      2 TEMP LOGAN
      2 PLAC Place
      2 STAT COMPLETED
      3 DATE 27 MAR 2022
      4 TIME 15:48
      2 NOTE Note text
      2 SNOTE @N1@
      2 SOUR @S1@
      3 PAGE 1
      2 SOUR @S2@
      3 PAGE 2
      1 SLGS
      2 DATE 27 MAR 2022
      2 STAT CANCELED
      3 DATE 27 MAR 2022
      1 SLGS
      2 DATE 27 MAR 2022
      2 STAT EXCLUDED
      3 DATE 27 MAR 2022
      1 SLGS
      2 DATE 27 MAR 2022
      2 STAT DNS
      3 DATE 27 MAR 2022
      1 SLGS
      2 DATE 27 MAR 2022
      2 STAT DNS_CAN
      3 DATE 27 MAR 2022
      1 SLGS
      2 DATE 27 MAR 2022
      2 STAT PRE_1970
      3 DATE 27 MAR 2022
      1 SLGS
      2 DATE 27 MAR 2022
      2 STAT UNCLEARED
      3 DATE 27 MAR 2022
      1 REFN 1
      2 TYPE User-generated identifier
      1 REFN 10
      2 TYPE User-generated identifier
      1 UID f096b664-5e40-40e2-bb72-c1664a46fe45
      1 UID 1f76f868-8a36-449c-af0d-a29247b3ab50
      1 EXID 123
      2 TYPE http://example.com
      1 EXID 456
      2 TYPE http://example.com
      1 NOTE Note text
      1 SNOTE @N1@
      1 SOUR @S1@
      2 PAGE 1
      2 QUAY 1
      1 SOUR @S2@
      2 PAGE 2
      2 QUAY 2
      1 OBJE @O1@
      1 OBJE @O2@
      1 OBJE @VOID@
      2 TITL Title
      1 CHAN
      2 DATE 27 MAR 2022
      3 TIME 08:56
      2 NOTE Change date note 1
      2 NOTE Change date note 2
      1 CREA
      2 DATE 27 MAR 2022
      3 TIME 08:55
      
      """

    for (v, e) in zip(exported, expected.split(separator: "\n")) {
      #expect(v == e)
    }

  }

  @Test("Individual") func individual() {
    let individual = Individual(xref: "@I1@")

    individual.restrictions = [.CONFIDENTIAL, .LOCKED]
    individual.names += [
      PersonalName(name: "Lt. Cmndr. Joseph \"John\" /de Allen/ jr.",
                   type: NameType(kind: .OTHER, phrase: "Name type phrase"),
                   namePieces: [
                    .NPFX("Lt. Cmndr."),
                    .GIVN("Joseph"),
                    .NICK("John"),
                    .SPFX("de"),
                    .SURN("Allen"),
                    .NSFX("jr.")
                   ],
                   translations: [
                    PersonalNameTranslation(name: "npfx John /spfx Doe/ nsfx",
                                            lang: "en-GB",
                                            namePieces: [
                                              .NPFX("npfx"),
                                              .GIVN("John"),
                                              .NICK("John"),
                                              .SPFX ("spfx"),
                                              .SURN ("Doe"),
                                              .NSFX("nsfx")]),
                    PersonalNameTranslation(name: "John /Doe/",
                                            lang: "en-CA")
                   ],
                   notes: [
                    .Note(Note(text: "Note text")),
                    .SNote(SNoteRef(xref: "@N1@")),
                    .SNote(SNoteRef(xref: "@VOID@"))
                   ],
                   citations: [
                    SourceCitation(xref: "@S1@", page: "1"),
                    SourceCitation(xref: "@S2@")
                   ]
                  ),
      PersonalName(name: "John /Doe/", type: NameType(kind: .BIRTH)),
      PersonalName(name: "Aka", type: NameType(kind: .AKA)),
      PersonalName(name: "Immigrant Name", type: NameType(kind: .IMMIGRANT))
    ]
    individual.sex = .male
    individual.attributes = [
      .init(kind: .CAST, text: "Caste", type: "Caste type"),
      .init(kind: .DSCR, text: "Description", type: "Description type",
            citations: [
              SourceCitation(xref: "@VOID@", page: "Entire source")
            ]),
      .init(kind: .EDUC, text: "Education", type: "Education type"),
      .init(kind: .IDNO, text: "ID number", type: "ID number type"),
      .init(kind: .NATI, text: "Nationality", type: "Nationality type"),
      .init(kind: .NCHI, text: "2", type: "nchi type"),
      .init(kind: .NMR, text: "2", type: "nmr type"),
      .init(kind: .OCCU, text: "occu", type: "occu type"),
      .init(kind: .PROP, text: "prop", type: "prop type"),
      .init(kind: .RELI, text: "reli", type: "reli type"),
      .init(kind: .RESI, text: "resi", type: "resi type"),
      .init(kind: .SSN, text: "ssn", type: "ssn type"),
      .init(kind: .TITL, text: "titl", type: "titl type"),
      .init(kind: .FACT, text: "fact", type: "fact type"),
    ]
    individual.events = [
      .init(kind: .BAPM, type: "bapm type"),
      .init(kind: .BAPM, occurred: true),
      .init(kind: .BARM, type: "barm type"),
      .init(kind: .BASM, type: "basm type"),
      .init(kind: .BLES, type: "bles type"),
      .init(kind: .BURI, type: "buri type", date: DateValue(date: "30 MAR 2022")),
      .init(kind: .CENS, type: "cens type"),
      .init(kind: .CHRA, type: "chra type"),
      .init(kind: .CONF, type: "conf type"),
      .init(kind: .CREM, type: "crem type"),
      .init(kind: .DEAT, type: "deat type",
            date: .init(date: "28 MAR 2022"),
            sdate: .init(date: "28 MAR 2022", time: "16:47", phrase: "sdate phrase"),
            place: .init(place: ["Somewhere"]),
            address: .init(addr: "Address"),
            phones: ["+1 (555) 555-1212", "+1 (555) 555-1234"],
            emails: ["GEDCOM@FamilySearch.org", "GEDCOM@example.com"],
            fax: ["+1 (555) 555-1212", "+1 (555) 555-1234"],
            www: [URL(string: "http://gedcom.io")!, URL(string: "http://gedcom.info")!],
            agency: "Agency",
            religion: "Religion",
            cause: "Cause of death",
            restrictions: [.CONFIDENTIAL, .LOCKED],
            associations: [
              .init(xref: "@I3@", role: Role(kind: .CHIL)),
              .init(xref: "@VOID@", role: Role(kind: .PARENT))
            ],
            notes: [
              .Note(Note(text: "Note text")),
              .SNote(SNoteRef(xref: "@N1@"))
            ],
            citations: [
              .init(xref: "@S1@", page: "1"),
              .init(xref: "@S2@", page: "2"),
            ],
            multimediaLinks: [
              .init(xref: "@O1@"),
              .init(xref: "@O2@"),
            ],
            uid: [
              UUID(uuidString: "82092878-6f4f-4bca-ad59-d1ae87c5e521")!,
              UUID(uuidString: "daf4b8c0-4141-42c4-bec8-01d1d818dfaf")!
            ]
          ),

      .init(kind: .EMIG, type: "emig type"),
      .init(kind: .FCOM, type: "fcom type"),
      .init(kind: .GRAD, type: "grad type"),
      .init(kind: .IMMI, type: "immi type"),
      .init(kind: .NATU, type: "natu type"),
      .init(kind: .ORDN, type: "ordn type"),
      .init(kind: .PROB, type: "prob type"),
      .init(kind: .RETI, type: "reti type"),
      .init(kind: .WILL, type: "will type"),
      .init(kind: .ADOP, type: "adop type",
            familyChild: .init(xref: "@VOID@",
                               adoption: .init(kind: .BOTH,
                                               phrase: "Adoption phrase"))),
      .init(kind: .ADOP,
            familyChild: .init(xref: "@VOID@",
                               adoption: .init(kind: .HUSB))),
      .init(kind: .ADOP,
            familyChild: .init(xref: "@VOID@",
                               adoption: .init(kind: .WIFE))),
      .init(kind: .BIRT, type: "birth type", date: .init(date: "1 JAN 2000")),
      .init(kind: .CHR, type: "chr type",
            age: Age(age: "8d", phrase: "Age phrase"),
            date: .init(date: "9 JAN 2000")
            ),
      .init(kind: .EVEN, text: "Event", type: "Event type"),
    ]
    individual.nonEvents = [
      .init(kind: .NATU, date: DatePeriod(date: "FROM 1700 TO 1800",
                                          phrase: "No date phrase"),
            notes: [
              .Note(Note(text: "Note text")),
              .SNote(SNoteRef(xref: "@N1@")),
            ],
            citations: [
              .init(xref: "@S1@", page: "1"),
              .init(xref: "@S1@", page: "2"),
            ]
      ),
      .init(kind: .EMIG)
    ]

    individual.ldsDetails = [
      .init(kind: .BAPL,
            status: .init(kind: .STILLBORN,
                          date: .init(date: "27 MAR 2022"))),

      .init(kind: .BAPL,
            status: .init(kind: .SUBMITTED,
                          date: .init(date: "27 MAR 2022"))),

      .init(kind: .BAPL,
              date: .init(date: "27 MAR 2022")),

      .init(kind: .CONL,
            status: .init(kind: .INFANT,
                          date: .init(date: "27 MAR 2022"))),

      .init(kind: .CONL,
            date: .init(date: "27 MAR 2022")),

      .init(kind: .ENDL,
            status: .init(kind: .CHILD,
                          date: .init(date: "27 MAR 2022"))),

      .init(kind: .ENDL,
            date: .init(date: "27 MAR 2022")),

      .init(kind: .INIL,
            status: .init(kind: .EXCLUDED,
                          date: .init(date: "27 MAR 2022"))),
      .init(kind: .INIL,
            date: .init(date: "27 MAR 2022")),

      .init(kind: .SLGC,
            date: .init(date: "27 MAR 2022", time: "15:47", phrase: "Afternoon"),
            temple: "SLAKE",
            familyChild: "@VOID@"
           ),
      .init(kind: .SLGC,
            familyChild: "@VOID@",
            place: .init(place: ["Place"]),
            status: .init(kind: .BIC,
                          date: .init(date: "27 MAR 2022", time: "15:48")),
            notes: [
              .Note(Note(text: "Note text")),
              .SNote(SNoteRef(xref: "@N1@"))
            ],
            citations: [
              .init(xref: "@S1@", page: "1"),
              .init(xref: "@S2@", page: "2"),
            ]
           ),
      .init(kind: .SLGC, familyChild: "@F2@"),
    ]
    individual.childOfFamilies = [
      .init(xref: "@VOID@",
            pedigree: .init(kind: .OTHER, phrase: "Other type"),
            status: .init(kind: .CHALLENGED, phrase: "Phrase")),
      .init(xref: "@VOID@",
            pedigree: .init(kind: .FOSTER)),
      .init(xref: "@VOID@",
            pedigree: .init(kind: .SEALING)),
      .init(xref: "@F2@",
            pedigree: .init(kind: .ADOPTED),
            status: .init(kind: .PROVEN)),
      .init(xref: "@F2@",
            pedigree: .init(kind: .BIRTH),
            status: .init(kind: .DISPROVEN)),
    ]
    individual.spouseFamilies = [
      .init(xref: "@VOID@", notes: [
        .Note(.init(text: "Note text")),
        .SNote(.init(xref: "@N1@"))
      ]),
      .init(xref: "@F1@")
    ]
    individual.submitters = ["@U1@", "@U2@"]
    individual.associations = [
      .init(xref: "@VOID@", phrase: "Mr Stockdale", role: .init(kind: .FRIEND)),
      .init(xref: "@VOID@", role: .init(kind: .NGHBR)),
      .init(xref: "@VOID@", role: .init(kind: .FATH)),
      .init(xref: "@VOID@", role: .init(kind: .GODP)),
      .init(xref: "@VOID@", role: .init(kind: .HUSB)),
      .init(xref: "@VOID@", role: .init(kind: .MOTH)),
      .init(xref: "@VOID@", role: .init(kind: .MULTIPLE)),
      .init(xref: "@VOID@", role: .init(kind: .SPOU)),
      .init(xref: "@VOID@", role: .init(kind: .WIFE)),
    ]

    individual.aliases = [
      .init(tag: "ALIA", xref: "@VOID@"),
      .init(tag: "ALIA", xref: "@I3@", phrase: "Alias"),
    ]
    individual.ancestorInterest = ["@U1@", "@VOID@"]
    individual.decendantInterest = ["@U1@", "@VOID@"]

    individual.identifiers = [
      .Refn(REFN(ident: "1", type: "User-generated identifier")),
      .Refn(REFN(ident: "10", type: "User-generated identifier")),
      .Uuid(UID(ident: "3d75b5eb-36e9-40b3-b79f-f088b5c18595")),
      .Uuid(UID(ident: "cb49c361-7124-447e-b587-4c6d36e51825")),
      .Exid(EXID(ident: "123", type: "http://example.com")),
      .Exid(EXID(ident: "456", type: "http://example.com")),
    ]
    individual.notes = [
      .Note(Note(text: "me@example.com is an example email address.\n@@me and @I are example social media handles.\n@@@@@ has four @ characters where only the first is escaped.")),
      .SNote(SNoteRef(xref: "@N1@"))
    ]
    individual.citations = [
      .init(xref: "@S1@", page: "1", quality: 3),
      .init(xref: "@S2@"),
    ]

    individual.multimediaLinks = [
      .init(xref: "@O1@"),
      .init(xref: "@O2@"),
    ]

    individual.changeDate = .init(date: "27 MAR 2022", time: "08:56", notes: [
      .Note(Note(text: "Change date note 1")),
      .Note(Note(text: "Change date note 2"))
    ])
    individual.creationDate = .init(date: "27 MAR 2022", time: "08:55")

    let exp = individual.export()

    let exported = exp.export()

    let expected = """
          0 @I1@ INDI
          1 RESN CONFIDENTIAL, LOCKED
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
          1 NAME John /Doe/
          2 TYPE BIRTH
          1 NAME Aka
          2 TYPE AKA
          1 NAME Immigrant Name
          2 TYPE IMMIGRANT
          1 SEX M
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
          1 OBJE @O1@
          1 OBJE @O2@
          1 SOUR @S1@
          2 PAGE 1
          2 QUAY 3
          1 SOUR @S2@
          1 CHAN
          2 DATE 27 MAR 2022
          3 TIME 08:56
          2 NOTE Change date note 1
          2 NOTE Change date note 2
          1 CREA
          2 DATE 27 MAR 2022
          3 TIME 08:55

          """

    for (v, e) in zip(exported.split(separator: "\n"), expected.split(separator: "\n")) {
      #expect(v == e)
    }
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

    #expect(exp.export() ==
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

    #expect(exp.export() ==
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

  @Test("Multimedia Record") func multimedia() {
    let media = Multimedia(xref: "@O1@")
    media.restrictions = [.CONFIDENTIAL, .LOCKED]
    media.files += [MultimediaFile(path: "path/to/file1",
                                   form: MultimediaFileForm(form: "text/plain",
                                                            medium: Medium(kind: .OTHER,
                                                                           phrase: "Transcript")
                                                           )
                                  )
    ]

    media.files += [
      MultimediaFile(path: "media/original.mp3",
                     form: MultimediaFileForm(form: "audio/mp3",
                                              medium: Medium(kind: .AUDIO)),
                     title: "Object title")
    ]
    media.files[1].translations  += [
      FileTranslation(path: "media/derived.oga", form: "audio/ogg"),
      FileTranslation(path: "media/transcript.vtt", form: "text/vtt")
    ]

    media.identifiers.append(.Refn(REFN(ident: "1", type: "User-generated identifier")))
    media.identifiers.append(.Refn(REFN(ident: "10", type: "User-generated identifier")))
    media.identifiers.append(.Uuid(UID(ident: "69ebdd0e-c78c-4b81-873f-dc8ac30a48b9")))
    media.identifiers.append(.Uuid(UID(ident: "79cae8c4-e673-4e4f-bc5d-13b02d931302")))
    media.identifiers.append(.Exid(EXID(ident: "123", type: "http://example.com")))
    media.identifiers.append(.Exid(EXID(ident: "456", type: "http://example.com")))

    let n = Note(text: "American English", mime: "text/plain", lang: "en-US")
    n.translations.append(Translation(text: "British English", mime: "text/plain", lang: "en-GB"))
    n.translations.append(Translation(text: "Canadian English", mime: "text/plain", lang: "en-CA"))
    n.citations.append(SourceCitation(xref: "@S1@", page: "1"))
    n.citations.append(SourceCitation(xref: "@S2@", page: "2"))
    media.notes.append(.Note(n))
    media.notes.append(.SNote(SNoteRef(xref: "@N1@")))

    media.citations += [SourceCitation(xref: "@S1@", page: "1")]
    media.citations[0].data =
      SourceCitationData(date: DateValue(date: "28 MAR 2022",
                                           time: "10:29",
                                           phrase: "Morning"))

    media.citations[0].data?.text += [
      SourceText(text: "Text 1", mime: "text/plain", lang: "en-US"),
      SourceText(text: "Text 2", mime: "text/plain", lang: "en-US")
    ]
    media.citations[0].events += [
      SourceEventData(event: "BIRT", phrase: "Event phrase",
                      role: SourceEventRole(role: "OTHER", phrase: "Role phrase"))
    ]

    media.citations[0].quality = 0
    media.citations[0].multimediaLinks = [
      MultimediaLink(xref: "@O1@",
                     crop: Crop(top: 0, left: 0, height: 100, width: 100),
                     title: "Title"),
      MultimediaLink(xref: "@O1@",
                     crop: Crop(top: 100, left: 100),
                     title: "Title")
    ]
    let n2 = Note(text: "American English", mime: "text/plain", lang: "en-US")
    n2.translations += [Translation(text: "British English", lang: "en-GB")]
    n2.citations += [SourceCitation(xref: "@S1@", page: "1")]
    n2.citations += [SourceCitation(xref: "@S2@", page: "2")]

    media.citations[0].notes += [
      .Note(n2),
      .SNote(SNoteRef(xref: "@N1@"))
    ]

    media.citations += [SourceCitation(xref: "@S1@", page: "2")]

///XXXX


    media.changeDate = ChangeDate(date: "27 MAR 2022", time: "08:56")
    media.changeDate?.notes = [
      .Note(Note(text: "Change date note 1")),
      .Note(Note(text: "Change date note 2")),
    ]
    media.creationDate = CreationDate(date: "27 MAR 2022", time: "08:55")

    let exp = media.export()

    // From the first submitter example

    let expected =
        """
        0 @O1@ OBJE
        1 RESN CONFIDENTIAL, LOCKED
        1 FILE path/to/file1
        2 FORM text/plain
        3 MEDI OTHER
        4 PHRASE Transcript
        1 FILE media/original.mp3
        2 FORM audio/mp3
        3 MEDI AUDIO
        2 TITL Object title
        2 TRAN media/derived.oga
        3 FORM audio/ogg
        2 TRAN media/transcript.vtt
        3 FORM text/vtt
        1 REFN 1
        2 TYPE User-generated identifier
        1 REFN 10
        2 TYPE User-generated identifier
        1 UID 69ebdd0e-c78c-4b81-873f-dc8ac30a48b9
        1 UID 79cae8c4-e673-4e4f-bc5d-13b02d931302
        1 EXID 123
        2 TYPE http://example.com
        1 EXID 456
        2 TYPE http://example.com
        1 NOTE American English
        2 MIME text/plain
        2 LANG en-US
        2 TRAN British English
        3 MIME text/plain
        3 LANG en-GB
        2 TRAN Canadian English
        3 MIME text/plain
        3 LANG en-CA
        2 SOUR @S1@
        3 PAGE 1
        2 SOUR @S2@
        3 PAGE 2
        1 SNOTE @N1@
        1 SOUR @S1@
        2 PAGE 1
        2 DATA
        3 DATE 28 MAR 2022
        4 TIME 10:29
        4 PHRASE Morning
        3 TEXT Text 1
        4 MIME text/plain
        4 LANG en-US
        3 TEXT Text 2
        4 MIME text/plain
        4 LANG en-US
        2 EVEN BIRT
        3 PHRASE Event phrase
        3 ROLE OTHER
        4 PHRASE Role phrase
        2 QUAY 0
        2 OBJE @O1@
        3 CROP
        4 TOP 0
        4 LEFT 0
        4 HEIGHT 100
        4 WIDTH 100
        3 TITL Title
        2 OBJE @O1@
        3 CROP
        4 TOP 100
        4 LEFT 100
        3 TITL Title
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
        1 SOUR @S1@
        2 PAGE 2
        1 CHAN
        2 DATE 27 MAR 2022
        3 TIME 08:56
        2 NOTE Change date note 1
        2 NOTE Change date note 2
        1 CREA
        2 DATE 27 MAR 2022
        3 TIME 08:55

        """.split(separator: "\n")

    let exported = exp.export().split(separator: "\n")

    for (v, e) in zip(exported, expected) {
      #expect(v == e)
    }

//    0 @O2@ OBJE
//    1 RESN PRIVACY
//    1 FILE http://host.example.com/path/to/file2
//    2 FORM text/plain
//    3 MEDI ELECTRONIC

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

    let exported = exp.export().split(separator: "\n")

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

    // From the first submitter example
    #expect(exp.export() ==
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
