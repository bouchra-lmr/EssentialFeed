//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Bouchra Bekkouche on 4/3/2025.
//

import XCTest

class HTTPClient {
    
    var requestedURL: URL?
    
}

class RemoteFeedLoader {
        
    func load() {
        
    }
}

class RemoteFeeLoaderTests: XCTest {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let client = HTTPClient()
        
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
}
