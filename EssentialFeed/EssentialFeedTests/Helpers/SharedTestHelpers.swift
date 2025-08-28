//
//  SharedTestHelpers.swift
//  EssentialFeed
//
//  Created by Bouchra Bekkouche on 28/8/2025.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}
