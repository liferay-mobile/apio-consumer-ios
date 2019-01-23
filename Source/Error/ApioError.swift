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

/**
 * @author Paulo Cruz
 */
enum ApioError : Error {
    case cantParseToThing
    case emptyVocab
    case invalidRequestUrl
    case requestFailedException(statusCode: Int, title: String, description: String?)
    case thingNotFound
    case thingWithoutOperation(thingId: String, operationId: String)
}

extension ApioError {
    func getErrorMessage() -> String {
        switch self {
        case .cantParseToThing:
            return "Can't parse to thing"
        case .emptyVocab:
            return "Empty vocab"
        case .invalidRequestUrl:
            return "Invalid request URL"
        case .requestFailedException(_, title: let title, description: let description):
            guard let description = description else {
                return "\(title)"
            }
            
            return "\(title): \(description)"
        case .thingNotFound:
            return "Thing not found"
        case .thingWithoutOperation(thingId: let thingId, operationId: let operationId):
            return "Thing \(thingId) doesn't have the operation \(operationId)"
        }
    }
}
