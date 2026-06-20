import Testing
import Foundation
@testable import Gedcom

@Suite struct Gedcom5ConversionTests {
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

    @Test func testGedcom551NameVariationStructuresBecomeTranslations() throws {
        let content = """
0 HEAD
1 GEDC
2 VERS 5.5.1
0 @I1@ INDI
1 NAME /橘/ 逸勢
2 ROMN /Tachibana/ no Hayanari
3 TYPE romaji
2 FONE /たちばな/ の はやなり
3 TYPE kana
0 TRLR
"""
        let ged = try loadGedcom(content)
        let individual = try #require(ged.individualRecords.first)
        let name = try #require(individual.names.first)

        #expect(name.translations.count == 2)
        #expect(name.translations[0].name == "/Tachibana/ no Hayanari")
        #expect(name.translations[0].lang == "ja-Latn")
        #expect(name.translations[1].name == "/たちばな/ の はやなり")
        #expect(name.translations[1].lang == "ja-hrkt")

        let exported = ged.exportContent()
        #expect(exported.contains("2 TRAN /Tachibana/ no Hayanari\n3 LANG ja-Latn\n"))
        #expect(exported.contains("2 TRAN /たちばな/ の はやなり\n3 LANG ja-hrkt\n"))
    }

    @Test func testGedcom551RelationshipStructureBecomesRolePhrase() throws {
        let content = """
0 HEAD
1 GEDC
2 VERS 5.5.1
0 @I1@ INDI
1 NAME Associated /Person/
1 ASSO @I2@
2 RELA Honorary uncle
0 @I2@ INDI
1 NAME Other /Person/
0 TRLR
"""
        let ged = try loadGedcom(content)
        let individual = try #require(ged.individualRecords.first)
        let association = try #require(individual.associations.first)

        #expect(association.role?.kind == .OTHER)
        #expect(association.role?.phrase == "Honorary uncle")

        let exported = ged.exportContent()
        #expect(exported.contains("1 ASSO @I2@\n2 ROLE OTHER\n3 PHRASE Honorary uncle\n"))
    }

    private func loadGedcom(_ content: String) throws -> GedcomFile {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("ged")
        try content.write(to: url, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }
        return try GedcomFile(withFile: url)
    }
}
