//
//  TokenRowTests.swift
//  TokenRowTests
//
//  Created by Mathias Claassen on 9/9/16.
//  Copyright © 2016 Xmartlabs. All rights reserved.
//

import XCTest
import TokenRow

class TokenRowTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testAddRemoveToken() {
        let token1 = "First token"
        let token2 = "Second token"

        let tokenRow = TokenAccessoryRow<String>() {
            $0.options = [token1, token2]
        }
        tokenRow.addToken(token1)
        tokenRow.addToken(NSString(string: token2))

        XCTAssertEqual(tokenRow.value?.count, 2)

        tokenRow.removeToken(NSString(string: token1))

        XCTAssertEqual(tokenRow.value?.count, 1)

        tokenRow.removeToken("something else")

        XCTAssertEqual(tokenRow.value?.count, 1)
    }

    func testStringSearchable() {
        let string = "SoMe VeRy RarE StrINg"

        XCTAssertTrue(string.contains(token: "very"))
        XCTAssertTrue(string.contains(token: "STRING"))
        XCTAssertFalse(string.contains(token: "strange"))
    }
    
}
