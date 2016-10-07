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
    public var identifier: NSObject { return self as NSObject }

    public func contains(token: String) -> Bool {
        return self.lowercased().contains(token.lowercased())
    }
}
