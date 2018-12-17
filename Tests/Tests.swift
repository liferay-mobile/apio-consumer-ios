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

class ApioConsumerTests: BaseTest {

	let blogCollection = """
			{
				"totalItems": 3,
				"numberOfItems": 3,
				"view": {
					"@id": "http://localhost:8080/o/api/p/people?page=1&per_page=30",
					"first": "http://localhost:8080/o/api/p/people?page=1&per_page=30",
					"last": "http://localhost:8080/o/api/p/people?page=1&per_page=30",
					"@type": "PartialCollectionView"
				},
				"@id": "http://localhost:8080/o/api/p/people",
				"member": [
					{
						"birthDate": "2018-02-21T20:21Z",
						"alternateName": "20101",
						"email": "default@liferay.com",
						"gender": "male",
						"@type": "Person",
						"@id": "http://localhost:8080/o/api/p/people/20101"
					},
					{
						"birthDate": "1970-01-01T03:00Z",
						"alternateName": "test",
						"dashboardURL": "http://localhost:8080/user/test",
						"email": "test@liferay.com",
						"familyName": "Test",
						"gender": "male",
						"givenName": "Test",
						"name": "Test Test",
						"profileURL": "http://localhost:8080/web/test",
						"@type": "Person",
						"@id": "http://localhost:8080/o/api/p/people/20137"
					},
					{
						"birthDate": "1970-01-01T03:00Z",
						"alternateName": "anonymous20097",
						"email": "anonymous20097@liferay.com",
						"familyName": "Anonymous",
						"gender": "male",
						"givenName": "Anonymous",
						"name": "Anonymous Anonymous",
						"@type": "Person",
						"@id": "http://localhost:8080/o/api/p/people/38801"
					}
				],
				"operation": [
					{
						"expects": "http://localhost:8080/o/api/f/c/people",
						"target": "http://localhost:8080/o/api/p/people/",
						"method": "POST",
						"@id": "_:/create",
						"@type": "Operation"
					}
				],
				"@context": [
					{
						"@vocab": "http://schema.org/"
					},
					"https://www.w3.org/ns/hydra/core#"
				],
				"@type": "Collection"
			}
	"""
	
	let responseWithoutEmbbeded = """
		{
		"image": "https://apiosample.wedeploy.io/images/9",
		"birthDate": "1993-08-08T05:38Z",
		"email": "joel.sanford@example.com",
		"familyName": "Hermiston",
		"givenName": "Loy",
		"name": "Loy Hermiston",
		"jobTitle": [
		"Dynamic Tactics Orchestrator"
		],
		"@type": [
		"Person"
		],
		"@id": "https://apiosample.wedeploy.io/p/people/9",
		"address": {
		"addressCountry": "CI",
		"addressLocality": "Mitchellville",
		"addressRegion": "Kentucky",
		"postalCode": "47685-5726",
		"streetAddress": "1228 Ada Shoal",
		"@type": [
		"PostalAddress"
		]
		},
		"@context": [
		{
		"@vocab": "http://schema.org/"
		},
		"https://www.w3.org/ns/hydra/core#"
		]
		}
		"""
	
	let tessste = """
			{
			"totalItems": 42,
			"numberOfItems": 30,
			"view": {
				"@id": "https://apiosample.wedeploy.io/p/blog-postings?page=1&per_page=30",
				"first": "https://apiosample.wedeploy.io/p/blog-postings?page=1&per_page=30",
				"last": "https://apiosample.wedeploy.io/p/blog-postings?page=2&per_page=30",
				"next": "https://apiosample.wedeploy.io/p/blog-postings?page=2&per_page=30",
				"@type": [
					"PartialCollectionView"
				]
			},
			"@id": "https://apiosample.wedeploy.io/p/blog-postings",
			"member": [
				{
					"dateCreated": "2018-06-01T10:48Z",
					"dateModified": "2018-06-01T10:48Z",
					"alternativeHeadline": "Deserunt dolorum iusto.",
					"articleBody": "Natus in dolore est quaerat qui. Et nesciunt ut nihil sit placeat. Beatae alias velit deleniti accusantium.",
					"fileFormat": "text/html",
					"headline": "Death Be Not Proud",
					"@type": [
						"BlogPosting"
					],
					"@id": "https://apiosample.wedeploy.io/p/blog-postings/0",
					"creator": "https://apiosample.wedeploy.io/p/people/9",
					"@context": [
						{
							"creator": {
								"@type": "@id"
							}
						},
						{
							"comment": {
								"@type": "@id"
							}
						}
					],
					"comment": "https://apiosample.wedeploy.io/p/blog-postings/0/comments"
				}
			],
			"@context": [
				{
					"@vocab": "http://schema.org/"
				},
				"https://www.w3.org/ns/hydra/core#"
			],
			"@type": [
				"Collection"
			]
			}
	"""
	
	var data: Data!
	var json: [String:Any]!
	var context: [Any]!
	
    override func setUp() {
        super.setUp()
		
		guard let data = tessste.data(using: .utf8),
			  let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
				let context = json["@context"] as? [Any] else {
			
			XCTFail()
			return
		}
		
		self.data = data
		self.json = json
		self.context = context
    }
//    
//	func testParseAttributes() {
//		let parsedAttributes = JsonLdParser.parseAttributes(json: json,  context: context)
//
//		XCTAssertTrue(!parsedAttributes.0.keys.isEmpty)
//		XCTAssertTrue(!parsedAttributes.1.keys.isEmpty)
//	}
//	
//	func testFlatten() {
//		
//	}
//	
//	
//    func testFilterProperties() {
//		let properties = ["@id", "@context", "@type"]
//
//		let result = JsonLdParser.filterProperties(json: json, properties: properties)
//
//		result.filter { key, value in
//			if (properties.contains(key)) {
//				XCTFail()
//				return false
//			}
//			return true
//		}
//		
//    }
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//
	
	func testParseResponseWithEmbedded() {
		let responseWithEmbedded = loadJson("response-item-with-embbeded-structure")
		let (things, embeddedthings) = JsonLDParser.parseThing(json: responseWithEmbedded)
		
		
		XCTAssertEqual(things.id, "https://apiosample.wedeploy.io/p/blog-postings")
		
		XCTAssertEqual(things.types.count, 1)
		XCTAssertEqual(things.types.first, "Collection")
		
		XCTAssertEqual(things.operations.count, 0)
		
		XCTAssertEqual(things.attributes.count, 4)
		XCTAssertEqual(things.attributes["totalItems"] as? Int, 42)
		XCTAssertEqual(things.attributes["numberOfItems"] as? Int, 30)
		
		let members = things.attributes["member"] as? [Relation] ?? []
		XCTAssertEqual(members.count, 1)
		let member = members.first!
		XCTAssertEqual(member.id, "https://apiosample.wedeploy.io/p/blog-postings/0")
		XCTAssert(member.thing != nil)
		let memberThing = member.thing!
		XCTAssertEqual(memberThing.id, "https://apiosample.wedeploy.io/p/blog-postings/0")
		XCTAssertEqual(memberThing.types.first, "BlogPosting")
		XCTAssertEqual(memberThing.attributes.count, 8)
		
		XCTAssertEqual(memberThing.attributes["dateCreated"] as? String, "2018-06-01T10:48Z")
		XCTAssertEqual(memberThing.attributes["dateModified"] as? String, "2018-06-01T10:48Z")
		XCTAssertEqual(memberThing.attributes["alternativeHeadline"] as? String, "Deserunt dolorum iusto.")
		XCTAssertEqual(memberThing.attributes["articleBody"] as? String, "Natus in dolore est quaerat qui. Et nesciunt ut nihil sit placeat. Beatae alias velit deleniti accusantium.")
		
		XCTAssertEqual(memberThing.attributes["fileFormat"] as? String, "text/html")
		XCTAssertEqual(memberThing.attributes["headline"] as? String, "Death Be Not Proud")
		
		let memberThingCreator = memberThing.attributes["creator"] as? Relation
		XCTAssert(memberThingCreator != nil)
		
		XCTAssertEqual(memberThingCreator!.id, "https://apiosample.wedeploy.io/p/people/9")
		XCTAssertNil(memberThingCreator!.thing)
		
		let memberThingComment = memberThing.attributes["comment"] as? Relation
		XCTAssertEqual(memberThingComment!.id, "https://apiosample.wedeploy.io/p/blog-postings/0/comments")
		XCTAssertNil(memberThingComment!.thing)
		
		XCTAssertEqual(memberThing.operations.count, 0)
		
		let view = things.attributes["view"] as? Relation
		XCTAssertNotNil(view)
		XCTAssertEqual(view!.id, "https://apiosample.wedeploy.io/p/blog-postings?page=1&per_page=30")
		
		XCTAssertNotNil(view?.thing)
		
		let viewThing = view!.thing!
		XCTAssertEqual(viewThing.id, "https://apiosample.wedeploy.io/p/blog-postings?page=1&per_page=30")
		XCTAssertEqual(viewThing.types.count, 1)
		XCTAssertEqual(viewThing.types.first, "PartialCollectionView")
		XCTAssertEqual(viewThing.attributes.count, 3)
		
		XCTAssertEqual(viewThing.attributes["first"] as? String, "https://apiosample.wedeploy.io/p/blog-postings?page=1&per_page=30")
		XCTAssertEqual(viewThing.attributes["last"] as? String, "https://apiosample.wedeploy.io/p/blog-postings?page=2&per_page=30")
		XCTAssertEqual(viewThing.attributes["next"] as? String, "https://apiosample.wedeploy.io/p/blog-postings?page=2&per_page=30")
		
		XCTAssertEqual(viewThing.operations.count, 0)
	}
	
}
