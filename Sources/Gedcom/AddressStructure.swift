//
//  AddressStructure.swift
//  Gedcom
//
//  Created by Mattias Holm on 2025-04-09.
//

/*
n ADDR <Special> {1:1} g7:ADDR
+1 ADR1 <Special> {0:1} g7:ADR1
+1 ADR2 <Special> {0:1} g7:ADR2
+1 ADR3 <Special> {0:1} g7:ADR3
+1 CITY <Special> {0:1} g7:CITY
+1 STAE <Special> {0:1} g7:STAE
+1 POST <Special> {0:1} g7:POST
+1 CTRY <Special> {0:1} g7:CTRY
*/

public class AddressStructure : RecordProtocol {
  public var address: String
  public var adr1: String?
  public var adr2: String?
  public var adr3: String?
  public var city: String?
  public var state: String?
  public var postalCode: String?
  public var country: String?

  nonisolated(unsafe) static let keys : [String:AnyKeyPath] = [
    "ADR1" : \AddressStructure.adr1,
    "ADR2" : \AddressStructure.adr2,
    "ADR3" : \AddressStructure.adr3,
    "CITY" : \AddressStructure.city,
    "STAE" : \AddressStructure.state,
    "POST" : \AddressStructure.postalCode,
    "CTRY" : \AddressStructure.country,
  ]

  init(addr: String)
  {
    address = addr
  }
  required init(record: Record) throws {
    address = record.line.value ?? ""
    var mutableSelf = self
    for child in record.children {
      guard let kp = Self.keys[child.line.tag] else {
        //  throw GedcomError.badRecord
        continue
      }

      if let wkp = kp as? WritableKeyPath<AddressStructure, String?> {
        mutableSelf[keyPath: wkp] = child.line.value ?? ""
      }
    }
  }

  func export() -> Record? {
    let record = Record(level: 0, tag: "ADDR", value: address)
    if let adr1 {
      record.children.append(Record(level: 1, tag: "ADR1", value: adr1))
    }
    if let adr2 {
      record.children.append(Record(level: 1, tag: "ADR2", value: adr2))
    }
    if let adr3 {
      record.children.append(Record(level: 1, tag: "ADR3", value: adr3))
    }
    if let city {
      record.children.append(Record(level: 1, tag: "CITY", value: city))
    }
    if let state {
      record.children.append(Record(level: 1, tag: "STAE", value: state))
    }
    if let postalCode {
      record.children.append(Record(level: 1, tag: "POST", value: postalCode))
    }
    if let country {
      record.children.append(Record(level: 1, tag: "CTRY", value: country))
    }

    return record
  }
}

