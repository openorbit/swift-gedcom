//
//  NameParsingTest.swift
//  Gedcom
//
//  Created by Mattias Holm on 2025-08-26.
//

import Testing
import Foundation
@testable import Gedcom

@Suite("Parse Name String Test") struct NameParsingTest {
  @Test func testNameComponents() async throws {

    let a = GedcomPersonalNameParser.parse("Lt. Cmndr. Joseph /Allen/ jr.")
    #expect(a.beforeSurname == "Lt. Cmndr. Joseph")
    #expect(a.surname == "Allen")
    #expect(a.afterSurname ==  "jr.")
    #expect(a.serialize() == "Lt. Cmndr. Joseph/Allen/jr.")
  }

  @Test func testUnicodeLastName() async throws {
    let b = GedcomPersonalNameParser.parse("/Иванов/")
    #expect(b.beforeSurname == nil)
    #expect(b.surname == "Иванов")
    #expect(b.afterSurname == nil)
    #expect(b.serialize() == "/Иванов/")
  }

  @Test func testSingleName() async throws {
    let c = GedcomPersonalNameParser.parse("Cher")
    #expect(c.usesSlashForm == false)
    #expect(c.serialize() == "Cher")
  }

  @Test func testBadNumberOfSlashesName() async throws {
    // Invalid: one slash (not allowed by GEDCOM 7 ABNF)
    let result = GedcomPersonalNameParser.parse("John /Smith")
    #expect(result.raw == "John /Smith")
  }

  @Test func testEmpty() async throws {
    // Invalid: one slash (not allowed by GEDCOM 7 ABNF)
    let result = GedcomPersonalNameParser.parse("")
    #expect(result.raw == "")
  }

  @Test func testBuildFromRaw() async throws {
    // Build from raw GEDCOM payload
    let p1 = GedcomPersonalName(raw: "Lt. Cmndr. Joseph /Allen/ jr.")
    #expect(p1.surname == "Allen")
    #expect(p1.serialize() == "Lt. Cmndr. Joseph/Allen/jr.")
  }

  @Test func testBuildFromComponents() async throws {

    // Build from components
    let p2 = GedcomPersonalName(beforeSurname: "Maria", surname: "García", afterSurname: "PhD")
    #expect(p2.raw == "Maria/García/PhD")
    #expect(p2.usesSlashForm == true) // true
  }

  @Test func testBuildFreeText() async throws {

    // Free-text form (no surname)
    let p3 = GedcomPersonalName(beforeSurname: "Cher")
    #expect(p3.raw == "Cher")
    #expect(p3.usesSlashForm == false) // false
  }
}
