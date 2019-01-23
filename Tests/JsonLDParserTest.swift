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
import XCTest
@testable import apio_consumer_ios

/**
 * @author Marcelo Mello
 */
class JsonLDParserTest : BaseTest {
    
    private var thing: Thing!
    private var embeddedThings: OptionalAttributes!
    private var attributes: Attributes!
    private var responseWithEmbedded: [String : Any]!
    
    func failureVocabSetUp() {
        super.setUp()
        
        responseWithEmbedded = loadJson("response-item-with-embbeded-structure-vocab-failure")
    }
    
    func successSetUp() {
        super.setUp()
        
        do {
            responseWithEmbedded = loadJson("response-item-with-embbeded-structure")
            let (thing, embeddedThings) = try JsonLDParser.parseThing(json: responseWithEmbedded)
            
            self.thing = thing
            self.embeddedThings = embeddedThings
            self.attributes = thing.attributes
        } catch {
            XCTFail()
        }
    }
    
    func testShouldThrowExceptionForEmptyVocab() {
        failureVocabSetUp()
        
        XCTAssertThrowsError(try JsonLDParser.parseThing(json: self.responseWithEmbedded, parentContext: nil))
    }
    
    func testShouldGetThingOperations() {
        successSetUp()
        
        let operations = thing.operations
		
		if let evaluateContext = operations["_:form/evaluate-context"],
			let fetchLatestDraft = operations["_:form/fetch-latest-draft"],
			let retrieve = operations["_:form/retrieve"],
			let uploadFile = operations["_:form/upload-file"] {
			
			XCTAssertEqual(evaluateContext.id, "_:form/evaluate-context")
			XCTAssertEqual(evaluateContext.method, "POST")
			XCTAssertEqual(evaluateContext.target, "http://localhost:8080/o/api/form/37115/evaluate-context")
			XCTAssertEqual(evaluateContext.expects, "")
			XCTAssertEqual(evaluateContext.types.first, "Operation")
			
			XCTAssertEqual(fetchLatestDraft.id, "_:form/fetch-latest-draft")
			XCTAssertEqual(fetchLatestDraft.method, "GET")
			XCTAssertEqual(fetchLatestDraft.target, "http://localhost:8080/o/api/form/37115/fetch-latest-draft")
			XCTAssertEqual(fetchLatestDraft.types.first, "Operation")
			
			XCTAssertEqual(retrieve.id, "_:form/retrieve")
			XCTAssertEqual(retrieve.method, "GET")
			XCTAssertEqual(retrieve.target, "http://localhost:8080/o/api/form/37115")
			XCTAssertEqual(retrieve.types.first, "Operation")
			
			XCTAssertEqual(uploadFile.id, "_:form/upload-file")
			XCTAssertEqual(uploadFile.method, "POST")
			XCTAssertEqual(uploadFile.target, "http://localhost:8080/o/api/form/37115/upload-file")
			XCTAssertEqual(uploadFile.expects, "")
			XCTAssertEqual(uploadFile.types.first, "Operation")
			
			XCTAssertEqual(thing.operations.count, 4)
			
		} else {
			XCTFail()
		}

    }
    
    func testShouldGetFieldProperty() {
        successSetUp()
        
        let attributes = self.attributes as Attributes
        
        var value = attributes["dateCreated"] as! String
        XCTAssertEqual(value, "2019-01-09T11:52Z")
        
        value = attributes["name"] as! String
        XCTAssertEqual(value, "Parse Form")
        
        XCTAssertEqual(thing.attributes.count, 10)
    }
    
    func testShouldGetStructureAsRelationAndNavigateIntoTheFieldsLevel() {
        successSetUp()
        
        let relation = attributes["structure"] as! Relation
        let relationAttributes = relation.thing?.attributes
        let relationAttributeFormPages = relationAttributes?["formPages"] as! OptionalAttributes
        let relationMember = relationAttributeFormPages["member"] as! [OptionalAttributes]
        let relationFields = relationMember[0]["fields"] as! OptionalAttributes
        let fieldsMember = relationFields["member"] as! [[String:Any?]]
        let field = fieldsMember[0]
        
        XCTAssertEqual(relation.id, "http://localhost:8080/o/api/form-structures/37112")
        XCTAssertEqual(field["label"] as! String, "Text Field")
    }

    func testShouldParseNestedArray() {
        successSetUp()
        
        XCTAssertEqual(thing.attributes["availableLanguages"] as! [String], ["en-US", "pt-BR"])
    }
    
    func testShouldReplaceIdWithRelation() {
        successSetUp()
        
        let structureRelation = thing.attributes["structure"]
        
        XCTAssertTrue(structureRelation is Relation)
    }
    
    func testShouldReturnEmbeddedThingsInSeparetedArray() {
        successSetUp()
        
        XCTAssertEqual(embeddedThings.count, 6)
    }
    
    func testShouldReturnEmbeddedThingsWithSameIdFoundedInRelations() {
        successSetUp()
        
        let structureRelation = thing.attributes["structure"] as! Relation
        let embeddedStructureRelation = embeddedThings[structureRelation.id] as! Thing
        
        XCTAssertEqual(embeddedStructureRelation.attributes["name"] as! String, "Parse Form")
    }
    
    func testShouldParseThing() {
        successSetUp()
        
        XCTAssertEqual(thing.id, "http://localhost:8080/o/api/form/37115")
        XCTAssertEqual(thing.types, ["Form"])
        XCTAssertEqual(attributes["name"] as! String, "Parse Form")
    }
}
