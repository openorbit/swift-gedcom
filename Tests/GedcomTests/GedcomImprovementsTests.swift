
import Testing
import Foundation
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

    @Test func testAgeParsing() {
        #expect(GedcomAgeParser.parse("35y") == GedcomAge(duration: GedcomAgeDuration(years: 35)))
        #expect(GedcomAgeParser.parse("< 2y 3m 4w 5d") == GedcomAge(bound: .lessThan, duration: GedcomAgeDuration(years: 2, months: 3, weeks: 4, days: 5)))
        #expect(GedcomAgeParser.parse("> 8d") == GedcomAge(bound: .greaterThan, duration: GedcomAgeDuration(days: 8)))
        #expect(GedcomAgeParser.parse("") == GedcomAge())
        #expect(GedcomAgeParser.parse("1y 30m") == GedcomAge(duration: GedcomAgeDuration(years: 1, months: 30)))
        #expect(GedcomAgeParser.parse("8w 30d") == GedcomAge(duration: GedcomAgeDuration(weeks: 8, days: 30)))
        #expect(GedcomAgeParser.parse("2m 1y") == nil)
        #expect(GedcomAgeParser.parse("1Y") == nil)
        #expect(GedcomAgeParser.parse("<") == nil)
    }

    @Test func testAgeRecordParsedAge() {
        let age = Age(age: "51w 6d", phrase: "363.5 days rounded down")
        #expect(age.parsedAge == GedcomAge(duration: GedcomAgeDuration(weeks: 51, days: 6)))
        #expect(age.phrase == "363.5 days rounded down")
    }

    @Test func testExtensionPreservationAndSchemaLookup() throws {
        let content = """
0 HEAD
1 GEDC
2 VERS 7.0
1 SOUR Family Tree Maker
1 SCHMA
2 TAG _LOC https://example.com/LocationRecord
0 @I1@ INDI
1 NAME John /Doe/
1 BIRT
2 DATE 1 JAN 1900
2 _EVENTEXT Event extension payload
1 _LOC @L1@
2 _NOTE Nested extension payload
1 FOO Future standard-looking payload
0 @L1@ _LOC
1 NAME Paris
0 TRLR
"""
        let ged = try loadGedcom(content)

        #expect(ged.uri(forExtensionTag: "_LOC") == URL(string: "https://example.com/LocationRecord")!)
        #expect(ged.individualRecords.count == 1)
        #expect(ged.individualRecords[0].extensions.count == 2)
        #expect(ged.individualRecords[0].extensions[0].tag == "_LOC")
        #expect(ged.individualRecords[0].extensions[0].value == "@L1@")
        #expect(ged.individualRecords[0].extensions[0].children[0].tag == "_NOTE")
        #expect(ged.individualRecords[0].extensions[1].tag == "FOO")
        #expect(ged.individualRecords[0].events.first?.extensions.first?.tag == "_EVENTEXT")
        #expect(ged.extensionRecords.first?.xref == "@L1@")
        #expect(ged.extensionRecords.first?.tag == "_LOC")
        #expect(ged.extensionNodes(tag: "_NOTE").first?.value == "Nested extension payload")
        #expect(ged.extensionNodes(tag: "_EVENTEXT").first?.value == "Event extension payload")

        let exported = ged.exportContent()
        #expect(exported.contains("2 TAG _LOC https://example.com/LocationRecord\n"))
        #expect(exported.contains("2 TAG _NOTE https://openorbit.org/gedcom/extensions/vendor-family-tree-maker/_NOTE\n"))
        #expect(exported.contains("2 TAG _EVENTEXT https://openorbit.org/gedcom/extensions/vendor-family-tree-maker/_EVENTEXT\n"))
        #expect(exported.contains("2 _EVENTEXT Event extension payload\n"))
        #expect(exported.contains("1 _LOC @L1@\n2 _NOTE Nested extension payload\n"))
        #expect(exported.contains("1 FOO Future standard-looking payload\n"))
        #expect(exported.contains("0 @L1@ _LOC\n1 NAME Paris\n"))
    }

    @Test func testUndeclaredExtensionUsesUnknownNamespaceWithoutHeaderSource() throws {
        let content = """
0 HEAD
1 GEDC
2 VERS 7.0
0 @I1@ INDI
1 _FOO Bar
0 TRLR
"""
        let ged = try loadGedcom(content)

        #expect(ged.header.schema == nil)

        let exported = ged.exportContent()
        #expect(exported.contains("1 SCHMA\n2 TAG _FOO https://openorbit.org/gedcom/extensions/unknown/_FOO\n"))
        #expect(exported.contains("1 _FOO Bar\n"))
        #expect(ged.uri(forExtensionTag: "_FOO") == URL(string: "https://openorbit.org/gedcom/extensions/unknown/_FOO")!)
    }

    @Test func testConcIsRejectedForGedcom7Input() throws {
        let content = """
0 HEAD
1 GEDC
2 VERS 7.0
0 @I1@ INDI
1 NOTE First
2 CONC second
0 TRLR
"""

        do {
            _ = try loadGedcom(content)
            Issue.record("GEDCOM 7 input must not accept CONC")
        } catch GedcomError.badRecord {
            #expect(true)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func testCommonLineEndingsImport() throws {
        let lines = [
            "0 HEAD",
            "1 GEDC",
            "2 VERS 7.0",
            "0 TRLR",
            ""
        ]

        for separator in ["\n", "\r\n", "\r"] {
            let ged = try loadGedcom(lines.joined(separator: separator))
            #expect(ged.sourceDialect == .gedcom7(version: "7.0"))
            #expect(ged.exportContent() == "0 HEAD\n1 GEDC\n2 VERS 7.0\n0 TRLR\n")
        }
    }

    private func loadGedcom(_ content: String) throws -> GedcomFile {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("ged")
        try content.write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }
        return try GedcomFile(withFile: url)
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
