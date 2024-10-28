//
//  AuthorHelper_Tests.swift
//  Quote DropletTests
//
//  Created by Daniel Agapov on 2024-10-26.
//

import Testing
@testable import Quote_Droplet

@Suite("Author Helper Tests") struct AuthorHelper_Tests {
    @Test func isAuthorValid_True() {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        #expect(isAuthorValid(authorGiven: "Marcus Aurelius") == true)
    }

    @Test func isAuthorValid_False_Unknown() {
        #expect(isAuthorValid(authorGiven: "Unknown Author") == false)
    }

    @Test func isAuthorValid_False_NULL() {
        #expect(isAuthorValid(authorGiven: "NULL") == false)
    }

    @Test func isAuthorValid_False_Empty_String() {
        #expect(isAuthorValid(authorGiven: "") == false)
    }

    @Test func isAuthorValid_False_Nil() {
        #expect(isAuthorValid(authorGiven: nil) == false)

    }
}
