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

/**
* @author Victor Oliveira
*/
class BaseTest: XCTestCase {
    
    typealias Dict = [String : Any?]
    typealias Attribute = [String : Any]

	func loadJson(_ filename: String) -> [String: Any] {
		let bundle = Bundle(for: type(of: self))
		let path = bundle.path(forResource: filename, ofType: "json")!
		let data = try! Data(contentsOf: URL(fileURLWithPath: path))
		
		return try! JSONSerialization.jsonObject(
			with: data, options: []) as! [String : Any]
	}
}
