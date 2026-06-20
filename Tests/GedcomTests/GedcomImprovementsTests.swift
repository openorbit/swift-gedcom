
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

    @Test func testGedcom551ImportsAsGedcom7Output() throws {
        let content = """
0 HEAD
1 SOUR LegacyApp
1 GEDC
2 VERS 5.5.1
2 FORM LINEAGE-LINKED
1 CHAR UTF-8
1 FILE legacy.ged
0 @N1@ NOTE This is a long
1 CONC legacy note
1 CONT with another line.
0 @I1@ INDI
1 NAME Jane /Doe/
1 NOTE @N1@
0 TRLR
"""
        let ged = try loadGedcom(content)

        #expect(ged.sourceDialect == .gedcom5(version: "5.5.1"))
        #expect(ged.header.gedc.vers == "7.0")
        #expect(ged.header.gedc.form == "LINEAGE-LINKED")
        #expect(ged.header.characterEncoding == "UTF-8")
        #expect(ged.header.file == "legacy.ged")
        #expect(ged.sharedNoteRecords.count == 1)
        #expect(ged.sharedNoteRecords[0].xref == "@N1@")
        #expect(ged.sharedNoteRecords[0].text == "This is a longlegacy note\nwith another line.")

        let exported = ged.exportContent()
        #expect(exported.contains("2 VERS 7.0\n"))
        #expect(exported.contains("0 @N1@ SNOTE This is a longlegacy note\n1 CONT with another line.\n"))
        #expect(!exported.contains("2 FORM LINEAGE-LINKED\n"))
        #expect(!exported.contains("1 CHAR UTF-8\n"))
        #expect(!exported.contains("1 FILE legacy.ged\n"))
        #expect(!exported.contains("0 @N1@ NOTE"))
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

    @Test func testGedcom551DateConversionToGedcom7Phrases() throws {
        let content = """
0 HEAD
1 SOUR LegacyApp
1 GEDC
2 VERS 5.5.1
0 @I1@ INDI
1 NAME Date /Tester/
1 BIRT
2 DATE INT 1800 (interpreted from census)
1 DEAT
2 DATE 2 FEB 1711/12
0 TRLR
"""
        let ged = try loadGedcom(content)
        let individual = try #require(ged.individualRecords.first)
        let birth = try #require(individual.events.first(where: { $0.kind == .BIRT }))
        let death = try #require(individual.events.first(where: { $0.kind == .DEAT }))

        #expect(birth.date?.date == "1800")
        #expect(birth.date?.phrase == "interpreted from census")
        #expect(death.date?.date == "2 FEB 1711")
        #expect(death.date?.phrase == "2 FEB 1711/12")

        let exported = ged.exportContent()
        #expect(exported.contains("1 BIRT\n2 DATE 1800\n3 PHRASE interpreted from census\n"))
        #expect(exported.contains("1 DEAT\n2 DATE 2 FEB 1711\n3 PHRASE 2 FEB 1711/12\n"))
    }

    @Test func testGedcom551InlineMultimediaLiftedToRecord() throws {
        let content = """
0 HEAD
1 GEDC
2 VERS 5.5.1
0 @I1@ INDI
1 NAME Media /Tester/
1 OBJE
2 FILE photos/john.jpg
3 FORM jpg
2 TITL John Smith portrait
0 TRLR
"""
        let ged = try loadGedcom(content)
        let individual = try #require(ged.individualRecords.first)
        let link = try #require(individual.multimediaLinks.first)
        let multimedia = try #require(ged.multimediaRecords.first)
        let file = try #require(multimedia.files.first)

        #expect(link.xref == multimedia.xref)
        #expect(file.path == "photos/john.jpg")
        #expect(file.form.form == "image/jpeg")
        #expect(file.title == "John Smith portrait")

        let exported = ged.exportContent()
        #expect(exported.contains("1 OBJE @O1@\n"))
        #expect(exported.contains("0 @O1@ OBJE\n1 FILE photos/john.jpg\n2 FORM image/jpeg\n2 TITL John Smith portrait\n"))
    }

    @Test func testGedcom551InlineSourceLiftedToRecord() throws {
        let content = """
0 HEAD
1 GEDC
2 VERS 5.5.1
0 @I1@ INDI
1 NAME Source /Tester/
1 DEAT
2 DATE 1910
2 SOUR Letter from Alice Smith, 13 April 1946
3 TEXT My father passed away back in 1910.
0 TRLR
"""
        let ged = try loadGedcom(content)
        let individual = try #require(ged.individualRecords.first)
        let death = try #require(individual.events.first(where: { $0.kind == .DEAT }))
        let citation = try #require(death.citations.first)
        let source = try #require(ged.sourceRecords.first)

        #expect(citation.xref == source.xref)
        #expect(source.title == "Letter from Alice Smith, 13 April 1946")
        #expect(source.text?.text == "My father passed away back in 1910.")

        let exported = ged.exportContent()
        #expect(exported.contains("2 SOUR @S1@\n"))
        #expect(exported.contains("0 @S1@ SOUR\n1 TITL Letter from Alice Smith, 13 April 1946\n1 TEXT My father passed away back in 1910.\n"))
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
