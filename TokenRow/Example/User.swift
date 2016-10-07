//
//  User.swift
//  Example
//
//  Created by Mathias Claassen on 9/8/16.
//
//

import Foundation
import TokenRow
import Alamofire

final class User: ResponseObjectSerializable, ResponseCollectionSerializable {
    var id: Int = 0
    var name: String = ""
    var avatar: String?

    var hashValue: Int {
        return id
    }

    required init?(response: HTTPURLResponse, representation: AnyObject) {
        self.name = representation.value(forKeyPath: "login") as! String
        self.avatar = representation.value(forKeyPath: "avatar_url") as? String
        self.id = representation.value(forKeyPath: "id") as! Int
    }
}

func == (lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}

extension User: TokenSearchable {
    func contains(token: String) -> Bool {
        return name.contains(token)
    }

    var identifier: NSObject {
        return id as NSObject
    }

    var displayString: String {
        return name
    }
}
