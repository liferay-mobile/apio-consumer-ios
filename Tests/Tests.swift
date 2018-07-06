//
//  Tests.swift
//  Tests
//
//  Created by Igor Matos  on 28/06/18.
//  Copyright © 2018 Allan Melo. All rights reserved.
//


import XCTest
@testable import apio_consumer_ios

class ApioConsumerTests: XCTestCase {
//    
//	let blogCollection = """
//			{
//			  "totalItems": 1,
//			  "view": {
//				"last": "http://screens.liferay.org.es/o/api/p/blogs?page=1&per_page=30",
//				"@type": [
//				  "PartialCollectionView"
//				],
//				"@id": "http://screens.liferay.org.es/o/api/p/blogs?page=1&per_page=30",
//				"first": "http://screens.liferay.org.es/o/api/p/blogs?page=1&per_page=30"
//			  },
//			  "numberOfItems": 1,
//			  "@type": [
//				"Collection"
//			  ],
//			  "member": [
//				{
//				  "creator": "http://screens.liferay.org.es/o/api/p/people/57457",
//				  "articleBody": "<p>My Content</p>",
//				  "@type": [
//					"BlogPosting"
//				  ],
//				  "author": "http://screens.liferay.org.es/o/api/p/people/57457",
//				  "@context": {
//					"creator": {
//					  "@type": "@id"
//					},
//					"author": {
//					  "@type": "@id"
//					},
//					"comment": {
//					  "@type": "@id"
//					},
//					"aggregateRating": {
//					  "@type": "@id"
//					},
//					"group": {
//					  "@type": "@id"
//					}
//				  },
//				  "alternativeHeadline": "My Subtitle",
//				  "license": "https://creativecommons.org/licenses/by/4.0",
//				  "modifiedDate": "2017-08-31T18:39:52+00:00",
//				  "comment": "http://screens.liferay.org.es/o/api/p/comments?id=57499&type=blogs&filterName=assetType_id",
//				  "@id": "http://screens.liferay.org.es/o/api/p/blogs/57499",
//				  "aggregateRating": "http://screens.liferay.org.es/o/api/p/aggregate-ratings/com.liferay.apio.liferay.portal.identifier.ClassNameClassPKIdentifier@4d2042ba",
//				  "headline": "My Title",
//				  "fileFormat": "text/html",
//				  "createDate": "2017-08-31T18:39:52+00:00",
//				  "group": "http://screens.liferay.org.es/o/api/p/groups/57459"
//				}
//			  ],
//			  "@id": "http://screens.liferay.org.es/o/api/p/blogs",
//			  "@context": {
//				"@vocab": "http://schema.org",
//				"Collection": "http://www.w3.org/ns/hydra/pagination.jsonld"
//			  }
//			}
//		"""

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
	
	var data: Data!
	var json: [String:Any]!
	var context: [Any]!
	
    override func setUp() {
        super.setUp()
		
		guard let data = blogCollection.data(using: .utf8),
			  let json = try! JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
				let context = json["@context"] as? [Any] else {
			
			XCTFail()
			return
		}
		
		self.data = data
		self.json = json
		self.context = context
    }
    
	func testParseAttributes() {
		let parsedAttributes = JsonLdParser.parseAttributes(json: json,  context: context)

		XCTAssertTrue(!parsedAttributes.0.keys.isEmpty)
		XCTAssertTrue(!parsedAttributes.1.keys.isEmpty)
	}
	
	func testFlatten() {
		
	}
	
	
    func testFilterProperties() {
		let properties = ["@id", "@context", "@type"]

		let result = JsonLdParser.filterProperties(json: json, properties: properties)

		result.filter { key, value in
			if (properties.contains(key)) {
				XCTFail()
				return false
			}
			return true
		}
		
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
//	
	func testCreatesPairsWithRelations() {
		let blogs = JsonLdParser.parseThing(json: json)
		print(blogs)
	}
//    
}
