//
//  ApioConsumer.swift
//  apio-consumer-ios
//
//  Created by Igor Matos  on 28/06/18.
//  Copyright © 2018 Allan Melo. All rights reserved.
//

import Foundation

class JsonLdParser {
	
	static func parseThing(json: Dict, parentContext: ArrayTest? = nil) -> (Thing, Dict) {
		let id = json["@id"] as? String ?? ""
		let types = parseType(json["@type"])
		let context = contextFrom(context: json["@context"] as? ArrayTest ?? [], parentContext: parentContext)
		let operations = parseOperations(json: json)
		let (attributes, things) = parseAttributes(json: json, context: context)
		
		let thing = Thing(id: id, types: types, attributes: attributes, operations: operations)
		
		return (thing, ["embeddedThings": things])
	}
	
	static func contextFrom(context: ArrayTest?, parentContext: ArrayTest?) -> ArrayTest {
		if let context = context, let parentContext = parentContext {
			if !hasVocab(jsonObject: context) && hasVocab(jsonObject: parentContext)  {
				var context = context
				
				context.append( ["@vocab": getVocab(context: parentContext) ?? ""])
				
				return context
			}
		}
		
		return context ?? parentContext ?? [] 
	}
	
	static func hasVocab(jsonObject: ArrayTest) -> Bool {
		return getVocab(context: jsonObject) != nil
	}
	
	static func getVocab(context: ArrayTest) -> String? {
		return context.first { item in
			if let item = item as? [String: Any], item.keys.contains("@vocab") {
				return true
			}
			
			return false
		} as? String
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
	
	static func parseObject(key: String, value: Dict, context: ArrayTest, attributes: Dict, things: Dict) -> (Dict, Dict) {
		var attributes = attributes
		var things = things
		
		if (value.keys.contains("@id")) {
			let (thing, embbededThings) = parseThing(json: value)
			
			
			attributes[key] = Relation(id: thing.id, thing: thing)
			
			things.merge(embbededThings) { first, second  in
				return first
			}
			
			things[thing.id] = thing
		} else {
			var (attributes, embbededThings) = parseAttributes(json: value, context: context)
			
			attributes[key] = attributes
			
			things.merge(embbededThings) { first, second in
				return first 
			}
		}
		
		return (things, attributes)
	}
	
	typealias Dict = [String: Any]
	typealias ArrayTest = [Any]
	
	static func parseObjectArray(key: String, value: ArrayTest, context: ArrayTest, attributes: Dict, things: Dict) -> (Dict, Dict) {
		let first = value.first as? [String:Any] ?? [:]
		var things = things
		var attributes = attributes

		if (first.keys.contains("@id")) {
			
			let collection = value.map { any -> (Thing, Dict) in
				let dict = any as? Dict ?? [:]
				
				return parseThing(json: dict)
			}  

			var relations = [Relation]()
			
			for (thing, embbededThings) in collection {
				let relation = Relation(id: thing.id, thing: thing)
				
				relations.append(relation)
				
				things.merge(embbededThings) { first, second in
					return first 
				}

			}
			
			attributes[key] = relations

		} 
		else {
			let collection = value.map { any -> (Dict, Dict) in
				let dict = any as? Dict ?? [:]
				
				return self.parseAttributes(json: dict, context: context)				
			}
			
			var attributesList = [Dict]()
			
			for (attributes, embeddedThings) in collection {
				attributesList.append(attributes)
				
				things.merge(embeddedThings) { first, second in
					return first
				}
			}
		}
		
		return (things, attributes)
	}
	
	
	static func parseOperations(json: Dict) -> [String: Operation] {
		let operationsJson = json["operation"] as? [Dict] ?? [[:]] 
		
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
	
	static func parseAttributes(json: Dict, context: ArrayTest) -> (Dict, Dict) {
		let filteredJson = JsonLdParser.filterProperties(json: json, properties: ["@id", "@context", "@type"])
		
		let result = filteredJson.keys.reduce(into: ["attributes": Dict() , "things": Dict()], { acc, key in 
			acc = JsonLdParser.flatten(context: context, foldedAttributes: acc, attribute: (key, json[key] ?? [:]))
		})
		
		let attributes = result["attributes"] as? Dict ?? [:] 
		let things = result["things"] as? Dict ??  [:]
		
		return (attributes, things)
	}
	
	static func flatten(context: ArrayTest, foldedAttributes: Dict, attribute: (String, Any)) -> Dict {
		let (key, value) = attribute
		
		var attributes = foldedAttributes["attributes"] as? Dict ?? Dict() 
		var things = foldedAttributes["things"] as? Dict ?? Dict()
		
		if let value = value as? Dict {
			let (parsedAttributes, parsedThings) = parseObject(key: key, value: value, context: context, attributes: attributes, things: things)
			attributes = parsedAttributes
			things = parsedThings
		}
		else if let value = value as? [Any] {
			let (parsedAttributes, parsedThings) = parseObjectArray(key: key, value: value, context: context, attributes: attributes, things: things)
			attributes = parsedAttributes
			things = parsedThings
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
	
	static func isId(name: String, context: ArrayTest?) -> Bool {
		guard let context = context else {
			return false
		}
		
		return context.first { item in
			if let dict = item as? Dict, 
				let value = dict[name] as? Dict, 
				let type = value["@type"] as? String, type == "@id" {
					
				return true
			}
			
			return false
		} != nil
	}
	
	static func filterProperties(json: Dict, properties: [String]) -> Dict {
		let keys = json.keys.filter { !properties.contains($0) }
		
		let filteredProperties = keys.reduce(Dict(), { acc, key in 
			var acc = acc
			
			guard let value = json[key] else {
				return acc
			}
			
			acc.updateValue(value, forKey: key)
			
			return acc
		})
		
		return filteredProperties
	}
	
}
