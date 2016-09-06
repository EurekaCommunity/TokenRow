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

    required init?(response: NSHTTPURLResponse, representation: AnyObject) {
        self.name = representation.valueForKeyPath("login") as! String
        self.avatar = representation.valueForKeyPath("avatar_url") as? String
        self.id = representation.valueForKeyPath("id") as! Int
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
        return id
    }

    var displayString: String {
        return name
    }
}
