import Testing
@testable import Gedcom

@Test func testBasicLineParsing() async throws {
  let line = Line("1 INDI")
  #expect(line != nil)
  #expect(line!.level == 1)
  #expect(line!.xref == nil)
  #expect(line!.tag == "INDI")
  #expect(line!.value == nil)
}


@Test func testXrefLineParsing() async throws {
  let line = Line("1 @123@ INDI")
  #expect(line != nil)
  #expect(line!.level == 1)
  #expect(line!.xref == "@123@")
  #expect(line!.tag == "INDI")
  #expect(line!.value == nil)
}

@Test func testValueLineParsing() async throws {
  let line = Line("123 INDI Hello World")
  #expect(line != nil)
  #expect(line!.level == 123)
  #expect(line!.xref == nil)
  #expect(line!.tag == "INDI")
  #expect(line!.value == "Hello World")
}


@Test func testXrefValueLineParsing() async throws {
  let line = Line("1 @123@ INDI Hello World")
  #expect(line != nil)
  #expect(line!.level == 1)
  #expect(line!.xref == "@123@")
  #expect(line!.tag == "INDI")
  #expect(line!.value == "Hello World")
}
