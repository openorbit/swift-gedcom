
import Testing
@testable import Gedcom

@Suite struct ReproductionTaskDefault {
    @Test func testEscapeCharacters() {
        // GEDCOM 7: Only leading @ needs escaping as @@.
        // @@username -> @username
        let line1 = Line("1 TAG @@username")
        #expect(line1?.value == "@username")
        
        // email@example.com -> email@example.com (no escape needed in middle)
        let line2 = Line("1 TAG email@example.com")
        #expect(line2?.value == "email@example.com")
        
        // @Pointer@ -> @Pointer@ (Pointer is not escaped)
        let line3 = Line("1 TAG @Pointer@")
        #expect(line3?.value == "@Pointer@")
    }
    
    @Test func testEscapeExport() {
        // Value "@username" (internally unescaped) -> "@@username" (escaped)
        let line1 = Line(level: 1, tag: "TAG", value: "@username")
        let exported1 = line1.export()
        #expect(exported1.contains("@@username"))
        
        // Value "@PTR@" -> "@PTR@" (Pointer detected, no escape)
        let line2 = Line(level: 1, tag: "TAG", value: "@PTR@")
        let exported2 = line2.export()
        #expect(exported2.contains(" @PTR@"))
        #expect(!exported2.contains("@@PTR@"))
        
        // Value "email@domain" -> "email@domain"
        let line3 = Line(level: 1, tag: "TAG", value: "email@domain")
        let exported3 = line3.export()
        #expect(exported3.contains(" email@domain"))
    }
    
    @Test func testDateParsing() {
        let d1 = GedcomDateParser.parse("15 APR 1990")
        #expect(d1 == .exact(GedcomSimpleDate(year: 1990, month: "APR", day: 15)))
        
        // Range
        let d2 = GedcomDateParser.parse("BET 1900 AND 2000")
        #expect(d2 == .between(start: GedcomSimpleDate(year: 1900), end: GedcomSimpleDate(year: 2000)))
        
        // Approx
        let d3 = GedcomDateParser.parse("ABT 1850")
        #expect(d3 == .approx(kind: .about, date: GedcomSimpleDate(year: 1850)))
        
        // Phrase
        let d4 = GedcomDateParser.parse("(Not a valid date)")
        #expect(d4 == .phrase("Not a valid date"))
        
        // From/To
        let d5 = GedcomDateParser.parse("FROM 1990 TO 2000")
        #expect(d5 == .range(start: GedcomSimpleDate(year: 1990), end: GedcomSimpleDate(year: 2000)))
    }

    /*
    @Test func testNameSlashHandling() {
         // This name has no slashes, so surname should be nil
         // and it should just be parsed as a whole string
         let parser = GedcomPersonalNameParser.parse("John Smith")
         #expect(parser.surname == nil)
         #expect(parser.rawTrimmed == "John Smith") 
    }
    */
}
