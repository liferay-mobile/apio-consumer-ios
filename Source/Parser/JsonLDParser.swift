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

/**
* @author Igor Matos
* @author Allan Melo
*/
class JsonLDParser {
	
	typealias OptionalAttributes = [String: Any?]
	typealias Attributes = [String: Any]
	typealias JsonObject = [Any]
	
    static func contextFrom(jsonObject: JsonObject?, parentContext: Context?) throws -> Context? {
        var vocabContext: String
        var attributesContext: [String : Any] = [:]
        
        if let context = jsonObject, let vocab = getVocab(context: context), vocab != "" {
            vocabContext = vocab
        }
        else {
            guard let vocab = parentContext?.vocab, vocab != "" else {
                throw ApioError.emptyVocab
            }
            
            vocabContext = vocab
        }
        
        fillProperties(jsonObject: jsonObject, attributesContext: &attributesContext)
        
        return Context(vocab: vocabContext, attributeContext: attributesContext)
    }
    
    static func fillProperties(jsonObject: JsonObject?, attributesContext: inout [String : Any]) {
        jsonObject?.forEach { property in
            if let property = property as? [String : Any] {
                for (key, value) in property {
                    if (key != "@vocab") {
                        attributesContext[key] = [key : value]
                    }
                }
            }
        }
    }
	
	static func filterProperties(
		json: OptionalAttributes, properties: [String]) -> OptionalAttributes {
		
		let keys = json.keys.filter { !properties.contains($0) }
		
		let filteredProperties = keys.reduce(OptionalAttributes(), { acc, key in
			var acc = acc
			
			guard let value = json[key] else {
				return acc
			}
			
			acc.updateValue(value, forKey: key)
			
			return acc
		})
		
		return filteredProperties
	}
	
	static func flatten(
		context: Context?, foldedAttributes: inout OptionalAttributes, attribute: Attributes) throws
		-> OptionalAttributes {
		
        var attributes = foldedAttributes["attributes"] as? Attributes ?? Attributes()
        var things = foldedAttributes["things"] as? OptionalAttributes ?? OptionalAttributes()

        let key = attribute.keys.first ?? ""
        let value = attribute.values.first ?? ""

        if let value = value as? [String : Any?] {
            try parseObject(key: key, value: value, context: context, attributes: &attributes, things: &things)
        }
        else if let value = value as? [[String : Any]] {
            try parseObjectArray(key: key, value: value, context: context, attributes: &attributes, things: &things)
        }
        else if isId(name: key, context: context) {
            let value =  value as? String ?? ""
            let relation = Relation(id: value, thing: nil)
            
            things[value] = nil
            
            attributes[key] = relation
        }
        else {
            attributes[key] = value
        }

        return ["attributes" : attributes, "things" : things]
	}
	
    static func getVocab(context: JsonObject) -> String? {
        var vocabValue: String

        if (hasVocab(jsonObject: context)) {
            vocabValue = ""
            context.forEach { attrs in
                if let items = attrs as? [String : Any] {
                    for item in items {
                        if (item.key == "@vocab") {
                            vocabValue = item.value as? String ?? ""
                        }
                    }
                }
            }
            
            return vocabValue
        }

        return nil
    }
	
	static func hasVocab(jsonObject: JsonObject) -> Bool {
        var flagVocab: Bool = false
            jsonObject.forEach { item in
                if let item = item as? [String : Any], item.keys.contains("@vocab") {
                    flagVocab = true
                }
            }

        return flagVocab
	}
	
	static func isEmbeddedThingArray(value: JsonObject) -> Bool {
        if let firstPair = value.first as? [String : Any] {
			return firstPair["@id"] != nil
		}
		
		return false
	}
	
	static func isId(name: String, context: Context?) -> Bool {
        guard let context = context else {
            return false
        }

        if let typeContext = context.attributeContext["@type"] as? String {
            if typeContext == "@id" {
                return true
            }
        }

        return false
	}
	
	static func parseAttributes(
		json: OptionalAttributes, context: Context?) throws -> (Attributes, OptionalAttributes) {
		let filteredJson = filterProperties(json: json, properties: ["@id", "@context", "@type"])
		
        let result = try filteredJson.keys
            .reduce(
				into: ["attributes": Attributes(), "things": OptionalAttributes()], { acc, key in
                    acc = try flatten(context: context, foldedAttributes: &acc, attribute: [key : filteredJson[key] as Any] as Attributes)
            })
        
		let attributes = result["attributes"] as? Attributes ?? [:]
		let things = result["things"] as? OptionalAttributes ??  [:]
		
		return (attributes, things)
	}
	
	static func parseObject(
		key: String, value: OptionalAttributes, context: Context?, attributes: inout Attributes, things: inout OptionalAttributes) throws {
		
        if (value.keys.contains("@id")) {
            let (thing, embbededThings) = try parseThing(json: value, parentContext: context)
            
            attributes[key] = Relation(id: thing.id, thing: thing)
            
            things.merge(embbededThings) { first, second  in
                return first
            }
            
            things[thing.id] = thing
        }
        else {
            let (parsedAttributes, parsedEmbbededThings) = try parseAttributes(json: value, context: context)
            
            attributes[key] = parsedAttributes
            
            things.merge(parsedEmbbededThings) { first, second in
                return first
            }
        }
	}
	
	static func parseObjectArray(
		key: String, value: JsonObject, context: Context?, attributes: inout Attributes, things: inout OptionalAttributes) throws {

		if (isEmbeddedThingArray(value: value)) {
			let collection = try value.map { try parseThing(json: $0 as? OptionalAttributes ?? [:], parentContext: context) }

			var relations = [Relation]()
			
			for (thing, embbededThings) in collection {
				let relation = Relation(id: thing.id, thing: thing)
				
				relations.append(relation)
				
				things.merge(embbededThings) { first, second in
					return second
				}
				
				things[thing.id] = thing
			}
			
			attributes[key] = relations
		}
		else {
			let collection = 
					try value.map { try parseAttributes(json: $0 as? OptionalAttributes ?? [:], context: context) }
			
			var attributesList = [OptionalAttributes]()
			
			for (embeddedAttributes, embeddedThings) in collection {
				attributesList.append(embeddedAttributes)
				
				things.merge(embeddedThings) { first, second in
					return second
				}
				
				attributes[key] = attributesList
			}
		}
	}
	
	static func parseOperations(json: OptionalAttributes) -> [String: Operation] {
		let operationsJson = json["operation"] as? [OptionalAttributes] ?? []
		
		let operations = operationsJson.map { operationJson -> Operation in
			let id = operationJson["@id"] as? String ?? ""
			let target = operationJson["target"] as? String ?? ""
			let method = operationJson["method"] as? String ?? ""
			let expects = operationJson["expects"] as? String ?? ""
			let types = operationJson["@type"] as? [String] ?? []
			
			return Operation(id: id, target: target, method: method, expects: expects, types: types)
		}

		return operations.reduce(into: [String: Operation]()) { (acc, operation) in
			acc[operation.id] = operation
		}		
	}
	
	static func parseThing(json: OptionalAttributes, parentContext: Context? = nil) throws -> (Thing, OptionalAttributes) {
        do {
            let id = json["@id"] as? String ?? ""
            let types = parseType(json["@type"] ?? nil)
            let context =
                try contextFrom(jsonObject: json["@context"] as? JsonObject ?? [], parentContext: parentContext)
            
            let operations = parseOperations(json: json)
            let (attributes, things) = try parseAttributes(json: json, context: context)
            
            let thing = Thing(id: id, types: types, attributes: attributes, operations: operations)
		
            return (thing, things)
        } catch {
            throw ApioError.cantParseToThing
        }
	}
	
	static func parseType(_ type: Any?) -> [String] {
		switch type {
		case let type as String:
			return [type]
		case let type as [String]:
			return type
		default:
			return []
		}
	}
}
