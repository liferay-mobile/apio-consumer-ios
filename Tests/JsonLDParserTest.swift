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
    private var embeddedThings: Dict!
    private var attributes: Attribute!
    
    override func setUp() {
        super.setUp()
        
        let responseWithEmbedded = loadJson("response-item-with-embbeded-structure")
        let (thing, embeddedThings) = JsonLDParser.parseThing(json: responseWithEmbedded)
        
        self.thing = thing
        self.embeddedThings = embeddedThings
        self.attributes = thing.attributes
    }
    
    func testShouldGetThingOperations() {
        let operations = thing.operations
        
        var typesOperation = operations["_:form/evaluate-context"]?.types
        XCTAssertEqual(operations["_:form/evaluate-context"]?.id, "_:form/evaluate-context")
        XCTAssertEqual(operations["_:form/evaluate-context"]?.method, "POST")
        XCTAssertEqual(operations["_:form/evaluate-context"]?.target, "http://localhost:8080/o/api/form/37115/evaluate-context")
        XCTAssertEqual(operations["_:form/evaluate-context"]?.expects, "")
        XCTAssertEqual(typesOperation?.first, "Operation")
        
        XCTAssertEqual(operations["_:form/fetch-latest-draft"]?.id, "_:form/fetch-latest-draft")
        XCTAssertEqual(operations["_:form/fetch-latest-draft"]?.method, "GET")
        XCTAssertEqual(operations["_:form/fetch-latest-draft"]?.target, "http://localhost:8080/o/api/form/37115/fetch-latest-draft")
        typesOperation = operations["_:form/fetch-latest-draft"]?.types
        XCTAssertEqual(typesOperation?.first, "Operation")
        
        typesOperation = operations["_:form/retrieve"]?.types
        XCTAssertEqual(operations["_:form/retrieve"]?.id, "_:form/retrieve")
        XCTAssertEqual(operations["_:form/retrieve"]?.method, "GET")
        XCTAssertEqual(operations["_:form/retrieve"]?.target, "http://localhost:8080/o/api/form/37115")
        XCTAssertEqual(typesOperation?.first, "Operation")
        
        XCTAssertEqual(operations["_:form/upload-file"]?.id, "_:form/upload-file")
        XCTAssertEqual(operations["_:form/upload-file"]?.method, "POST")
        XCTAssertEqual(operations["_:form/upload-file"]?.target, "http://localhost:8080/o/api/form/37115/upload-file")
        XCTAssertEqual(operations["_:form/upload-file"]?.expects, "")
        typesOperation = operations["_:form/upload-file"]?.types
        XCTAssertEqual(typesOperation?.first, "Operation")
        
        XCTAssertEqual(thing.operations.count, 4)
    }
    
    func testShouldGetFieldProperty() {
        let attributes = self.attributes as Attribute
        
        var value = attributes["dateCreated"] as! String
        XCTAssertEqual(value, "2019-01-09T11:52Z")
        
        value = attributes["name"] as! String
        XCTAssertEqual(value, "Parse Form")
        
        XCTAssertEqual(thing.attributes.count, 10)
    }
    
    func testShouldGetStructureAsRelationAndNavigateIntoTheFieldsLevel() {
        let relation = attributes["structure"] as! Relation
        let relationAttributes = relation.thing?.attributes
        let relationAttributeValue = relationAttributes?["formPages"] as! Dict
        let relationMember = relationAttributeValue["member"] as! [[String:Any?]]
        let relationFields = relationMember[0]["fields"] as! Dict
        let fieldsMember = relationFields["member"] as! [[String:Any?]]
        let field = fieldsMember[0]
        
        XCTAssertEqual(relation.id, "http://localhost:8080/o/api/form-structures/37112")
        
        let fieldValue = field["label"] as! String
        XCTAssertEqual(fieldValue, "Text Field")
    }

    func testShouldParseNestedArray() {
        XCTAssertEqual(thing.attributes["availableLanguages"] as! [String], ["en-US", "pt-BR"])
    }
    
    func testShouldReplaceIdWithRelation() {
        let structureRelation = thing.attributes["structure"]
        
        XCTAssertTrue(structureRelation is Relation)
    }
    
    func testShouldReturnEmbeddedThingsInSeparetedArray() {
        XCTAssertEqual(embeddedThings.count, 6)
    }
    
    func testShouldReturnEmbeddedThingsWithSameIdFoundedInRelations() {
        let structureRelation = thing.attributes["structure"] as! Relation
        let embeddedStructureRelation = embeddedThings[structureRelation.id] as! Thing
        
        XCTAssertEqual(embeddedStructureRelation.attributes["name"] as! String, "Parse Form")
    }
    
    func testShouldParseThing() {
        XCTAssertEqual(thing.id, "http://localhost:8080/o/api/form/37115")
        XCTAssertEqual(thing.types, ["Form"])
        XCTAssertEqual(attributes["name"] as! String, "Parse Form")
    }
}
