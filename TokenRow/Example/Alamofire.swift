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


public enum BackendError: Error {
    case network(error: NSError)
    case dataSerialization(reason: String)
    case jsonSerialization(error: NSError)
    case objectSerialization(reason: String)
    case xmlSerialization(error: NSError)
}

public protocol ResponseObjectSerializable {
    init?(response: HTTPURLResponse, representation: AnyObject)
}

extension DataRequest {
    @discardableResult
    public func responseObject<T: ResponseObjectSerializable>(queue: DispatchQueue? = nil, completionHandler: @escaping (DataResponse<T>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<T> { request, response, data, error in
            guard error == nil else { return .failure(BackendError.network(error: error! as NSError)) }

            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

            switch result {
            case .success(let value):
                if let
                    response = response,
                    let responseObject = T(response: response, representation: value as AnyObject)
                {
                    return .success(responseObject)
                } else {
                    return .failure(BackendError.objectSerialization(reason: "JSON could not be serialized into response object: \(value)"))
                }
            case .failure(let error):
                return .failure(BackendError.jsonSerialization(error: error as NSError))
            }
        }

        return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}

public protocol ResponseCollectionSerializable {
    static func collection(response: HTTPURLResponse, representation: AnyObject) -> [Self]
}

extension ResponseCollectionSerializable where Self: ResponseObjectSerializable {
    static func collection(response: HTTPURLResponse, representation: AnyObject) -> [Self] {
        var collection = [Self]()

        // check in items path
        if let representation = representation.value(forKeyPath: "items") as? [[String: AnyObject]] {
            for itemRepresentation in representation {
                if let item = Self(response: response, representation: itemRepresentation as AnyObject) {
                    collection.append(item)
                }
            }
        }

        return collection
    }
}

extension DataRequest {
    @discardableResult
    public func responseCollection<T: ResponseCollectionSerializable>(queue: DispatchQueue? = nil,
                                   completionHandler: @escaping (DataResponse<[T]>) -> Void) -> Self {
        let responseSerializer = DataResponseSerializer<[T]> { request, response, data, error in
            guard error == nil else { return .failure(BackendError.network(error: error! as NSError)) }

            let JSONResponseSerializer = DataRequest.jsonResponseSerializer(options: .allowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

            switch result {
            case .success(let value):
                if let response = response {
                    return .success(T.collection(response: response, representation: value as AnyObject))
                } else {
                    return .failure(BackendError.objectSerialization(reason: "JSON could not be serialized into response object: \(value)"))
                }
            case .failure(let error):
                return .failure(BackendError.jsonSerialization(error: error as NSError))
            }
        }

        return response(queue: queue, responseSerializer: responseSerializer, completionHandler: completionHandler)
    }
}
