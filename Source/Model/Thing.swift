/**
* Copyright (c) 2000-present Liferay, Inc. All rights reserved.
*
* This library is free software; you can redistribute it and/or modify it under
* the terms of the GNU Lesser General Public License as published by the Free
* Software Foundation; either version 2.1 of the License, or (at your option)
* any later version.
*
* This library is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
* details.
*/


import Foundation

struct Thing {
	let id: String
	let types: [String]
	let attributes: [String: Any]
	let operations: [String: Operation]
	
	init(id: String, types: [String], attributes: [String: Any], operations: [String: Operation]) {
		self.id = id
		self.types = types
		self.attributes = attributes
		self.operations = operations
	}
	
	enum CodingKeys: String, CodingKey {
		case id
		case types
		case attributes
		case operations
	}
}

extension Thing: Decodable {
	init(from decoder: Decoder) throws {
		attributes = [String: Any]()

		let values = try decoder.container(keyedBy: CodingKeys.self)
		id = try values.decode(String.self, forKey: .id)
		types = try values.decode([String].self, forKey: .types)
		operations = try values.decode([String: Operation].self, forKey: .operations)
	}
}

extension Thing: Encodable {
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id, forKey: .id)
		try container.encode(types, forKey: .types)
		
		var jsonMaster = "{"
		for (key, value) in attributes {
			if let value = value as? Relation {
				let jsonEncoder = JSONEncoder()
				let jsonData = try! jsonEncoder.encode(value)
				let key = "\"\(key)\""
				let value = "\"\(String(data: jsonData, encoding: String.Encoding.utf8) ?? "")\""
				jsonMaster.append("\(key) : \(value)")
				
				jsonMaster.append(", ")
				continue
			}
			
			if let value = value as? Thing {
				let jsonEncoder = JSONEncoder()
				let jsonData = try! jsonEncoder.encode(value)
				let key = "\"\(key)\""
				let value = "\"\(String(data: jsonData, encoding: String.Encoding.utf8) ?? "")\""
				jsonMaster.append("\(key) : \(value)")
				
				jsonMaster.append(", ")
				continue
			}
			
			if let value = value as? String {
				let key = "\"\(key)\""
				let value = "\"\(value)\""
				jsonMaster.append("\(key) : \(value)")
				
				jsonMaster.append(", ")
				continue
			}
			
			if let value = value as? [String: Any], !value.keys.isEmpty {
				var subDict = "{"
				for (keyItem, valueItem) in value {
					if let valueItem = valueItem as? String {
						let keyItem = "\"\(keyItem)\""
						let valueItem = "\"\(valueItem)\""
						subDict.append("\(keyItem) : \(valueItem),")
					}
				}
				if !value.keys.isEmpty {
					subDict.removeLast()
				}
				
				subDict.append("}")
				jsonMaster.append("\(key) : \(subDict)")
				
				jsonMaster.append(", ")
				continue
			}
			
			if let value = value as? [String], !value.isEmpty {
				var myArray = "["
				for valueItem in value {
					let valueItem = "\"\(valueItem)\""
					myArray.append("\(valueItem),")
				}
				if !value.isEmpty {
					myArray.removeLast()
				}
				
				myArray.append("]")
				jsonMaster.append("\(key) : \(myArray)")
				
				jsonMaster.append(", ")
				continue
			}
		}
		if (!jsonMaster.isEmpty) {
			jsonMaster.removeLast()
		}
		
		if (!jsonMaster.isEmpty) {
			jsonMaster.removeLast()
		}
		jsonMaster.append("}")
		
		try container.encode(jsonMaster, forKey: .attributes)
		try container.encode(operations, forKey: .operations)
	}
}

//struct GenericCodingKeys: CodingKey {
//	var intValue: Int?
//	var stringValue: String
//
//	init?(intValue: Int) { self.intValue = intValue; self.stringValue = "\(intValue)" }
//	init?(stringValue: String) { self.stringValue = stringValue }
//
//	static func makeKey(name: String) -> GenericCodingKeys {
//		return GenericCodingKeys(stringValue: name)!
//	}
//}

//extension AnyObject: Encodable {
//	func encode(to encoder: Encoder) throws {
//	}
//}
