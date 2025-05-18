//
//  RoundtripTest.swift
//  Gedcom
//
//  Created by Mattias Holm on 2025-05-18.
//

import Testing
import Foundation
@testable import Gedcom

@Suite("Round Trip Test") struct RoundtripTest {
  @Test func testRoundtripMinFile() async throws {
    let module = Bundle.module
    let resourceURL = module.url(forResource: "Gedcom7/minimal70",
                                 withExtension: "ged")
    #expect(resourceURL != nil)

    let ged = try GedcomFile(withFile: resourceURL!)
    let fileContent = ged.dataAsString(encoding: .utf8)!

    let result = ged.exportContent()

    #expect(fileContent == result)
  }
}
