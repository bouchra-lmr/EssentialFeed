//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Bouchra Bekkouche on 4/3/2025.
//

import XCTest

class HTTPClient {
    
    static let shared = HTTPClient()
    
    var requestedURL: URL?
    
    private init() {}
}

class RemoteFeedLoader {
        
    func load() {
        HTTPClient.shared.requestedURL = URL(string: "https://example.com/feed")
    }
}

class RemoteFeeLoaderTests: XCTest {
    
    func test_init_doesNotRequestDataFromURL() {
        
        let client = HTTPClient.shared
        
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func testLoad_requestDataFromURL() {
        
        let client = HTTPClient.shared
        
        let sut = RemoteFeedLoader()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
        
    }
}
