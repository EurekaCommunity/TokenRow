//
//  Alamofire.swift
//  Example
//
//  Created by Mathias Claassen on 9/8/16.
//
//

import Foundation
import Alamofire


/**

 NOTE: This code has been copied from the Alamofire Readme. This are just helper methods to show the other functionalities
*/


public enum BackendError: ErrorType {
    case Network(error: NSError)
    case DataSerialization(reason: String)
    case JSONSerialization(error: NSError)
    case ObjectSerialization(reason: String)
    case XMLSerialization(error: NSError)
}

public protocol ResponseObjectSerializable {
    init?(response: NSHTTPURLResponse, representation: AnyObject)
}

extension Request {
    public func responseObject<T: ResponseObjectSerializable>(completionHandler: Response<T, BackendError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<T, BackendError> { request, response, data, error in
            guard error == nil else { return .Failure(.Network(error: error!)) }

            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

            switch result {
            case .Success(let value):
                if let
                    response = response,
                    responseObject = T(response: response, representation: value)
                {
                    return .Success(responseObject)
                } else {
                    return .Failure(.ObjectSerialization(reason: "JSON could not be serialized into response object: \(value)"))
                }
            case .Failure(let error):
                return .Failure(.JSONSerialization(error: error))
            }
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

public protocol ResponseCollectionSerializable {
    static func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Self]
}

extension ResponseCollectionSerializable where Self: ResponseObjectSerializable {
    static func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Self] {
        var collection = [Self]()

        // check in items path
        if let representation = representation.valueForKeyPath("items") as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = Self(response: response, representation: itemRepresentation) {
                    collection.append(item)
                }
            }
        }

        return collection
    }
}

extension Alamofire.Request {
    public func responseCollection<T: ResponseCollectionSerializable>(completionHandler: Response<[T], BackendError> -> Void) -> Self {
        let responseSerializer = ResponseSerializer<[T], BackendError> { request, response, data, error in
            guard error == nil else { return .Failure(.Network(error: error!)) }

            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONSerializer.serializeResponse(request, response, data, error)

            switch result {
            case .Success(let value):
                if let response = response {
                    return .Success(T.collection(response: response, representation: value))
                } else {
                    return .Failure(. ObjectSerialization(reason: "Response collection could not be serialized due to nil response"))
                }
            case .Failure(let error):
                return .Failure(.JSONSerialization(error: error))
            }
        }

        return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}
