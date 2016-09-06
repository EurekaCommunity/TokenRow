//
//  String+TokenRow.swift
//  TokenRow
//
//  Created by Mathias Claassen on 9/6/16.
//
//

import Foundation

extension String: TokenSearchable {

    public var displayString: String { return self }
    public var identifier: NSObject { return self }

    public func contains(token: String) -> Bool {
        return self.lowercaseString.containsString(token.lowercaseString)
    }
}