//
//  AuthorHelper.swift
//  Quote Droplet
//
//  Created by Daniel Agapov on 2024-07-21.
//

import Foundation

func isAuthorValid (authorGiven: String?)-> Bool {
    return (authorGiven != "Unknown Author" && authorGiven != "NULL" && authorGiven != "" && authorGiven != nil &&  (authorGiven?.isEmpty == false))
}
