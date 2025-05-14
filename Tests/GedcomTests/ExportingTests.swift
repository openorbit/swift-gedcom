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

    let exp = header.export()
    #expect(exp != nil)

    exp?.setLevel(0)
    #expect(exp?.line.tag == "HEAD")
    #expect(exp?.line.level == 0)
    #expect(exp?.children[0].line.level == 1)
    #expect(exp?.children[0].line.tag == "GEDC")
    #expect(exp?.children[0].children[0].line.level == 2)
    #expect(exp?.children[0].children[0].line.tag == "VERS")
    #expect(exp?.children[0].children[0].line.value == "7.0")

    #expect(exp!.export() ==
      """
      0 HEAD
      1 GEDC
      2 VERS 7.0
      1 SCHMA
      2 TAG _JABBERID http://xmlns.com/foaf/0.1/jabberID
      2 TAG _SKYPEID http://xmlns.com/foaf/0.1/skypeID

      """
    )
  }
}
